//
//  C29RequestStack
//  Copper
//  This class is our basic stack to hold incoming requests
//
//  Created by Doug Williams on 6/18/14.
//  Copyright (c) 2014 Doug Williams. All rights reserved.
//

import UIKit

public let RequestStackNotificationObjectKey = "request"

public protocol C29RequestStackDelegate {
    func requestWasPushed(request: C29RequestDataSource)
    func requestWasDismissed(requestId: String)
    func popRequestStack()
}

public class C29RequestStack: NSObject, NSCoding {
    
    // MARK: FileSaveable
    public static var CacheFile:String = "C29RequestStack"
    static var FileType = FileSystemType.Documents
    
    class var ErrorDoamin: String {
        return "RequestStackError"
    }
    
    enum Keys: String {
        case Stack = "stack"
        case Responded = "responded"
    }
    
    // The limit for the number of requests and responded ids to keep around
    class var MaxStackAndRespondedSize: Int {
        return 16 // reasonably small so we're not storing a bunch of data; security minded, too
    }
    
    // status string to display the health of the stack
    public var status: String {
        var contents = ""
        for (index, request) in stack.enumerate() {
            contents += "\(index): \(request.id). "
        }
        return "\(C29RequestStack.CacheFile) status: total requests \(stack.count); \(contents) with responded size of \(responded.count)"
    }

    // will hold the order of our Records for display, this results in a number of O(n) operations that we may want to avoid in the futures
    var stack = [C29RequestDataSource]()
    // will serve as a FIFO, MaxResponded array of the last requestIds that have been responded too
    var responded = [String]()
    public var session: C29SessionDataSource?
    public var delegate: C29RequestStackDelegate?
    
    // MARK: - NSCoding
    // The following two methods allow serialization, etc...
    convenience required public init?(coder decoder: NSCoder) {
        self.init()
        if let stack = decoder.decodeObjectForKey(Keys.Stack.rawValue) as? [C29RequestDataSource] {
            self.stack = stack
        }
        if let responded = decoder.decodeObjectForKey(Keys.Responded.rawValue) as? [String] {
            self.responded = responded
        }
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        // remove fake requests because they cause problems on save.
        // this can safely be removed when we kill the fake request concept
        var reqsToSave = [C29Request]()
        for request in stack {
            if let request = request as? C29Request {
                reqsToSave.append(request)
            }
        }
        stack = reqsToSave
        coder.encodeObject(stack, forKey: Keys.Stack.rawValue)
        coder.encodeObject(responded, forKey: Keys.Responded.rawValue)
    }
    
    // MARK: - Our custom class stuff
    
    // add a request to the stack, will push to the MainViewController if display == true
    public func push(request: C29RequestDataSource, display: Bool = true) {
        guard !isResponded(request.id) && !request.expired else {
            return
        }
        
        // proactively remove the request if it exists already
        remove(request)
        // then throw it on the top of the stack or display it...
        if !display {
            stack.insert(request, atIndex: 0)
            while stack.count > C29RequestStack.MaxStackAndRespondedSize {
                stack.removeLast()
            }
            save()
        } else {
            self.delegate?.requestWasPushed(request)
        }
    }
    
    public func attemptPop() {
        self.delegate?.popRequestStack()
    }
    
    // get the last request, unanswered or expired, off the top of the stack
    public func pop() -> C29Request? {
        // if we're empty, we're done
        if stack.count == 0 {
            return C29Request?()
        }
        // otherwise let's go on the hunt
        var request = C29Request?()
        repeat {
            if stack.count > 0 {
                request = C29Request(requestData: stack.removeLast())
            } else {
                break
            }
        } while (self.isResponded(request!.id) || request!.expired)
        save()
        return request
    }
    
    // handle the case where the request was actively dismissed, eg. from the server
    public func requestWasDismissed(requestId: String) {
        if let request = getRequest(requestId) {
            // remove it
            remove(request)

        }
        // ensure it doens't ever pop back up
        addResponded(requestId)
        self.delegate?.requestWasDismissed(requestId)
    }
    
    // Remove an object from the cache
    func remove(request: C29RequestDataSource) {
        // remove from stack, if any matches are found
        for (index, stackRequest) in stack.enumerate() {
            if stackRequest.id == request.id {
                stack.removeAtIndex(index)
            }
        }
        save()
    }
    
    // add a request to the responded array to ensure we don't pop it twice or more
    public func addResponded(requestId: String) {
        // add it only if it's not added already
        if !isResponded(requestId) {
            self.responded.insert(requestId, atIndex: 0)
            while responded.count > C29RequestStack.MaxStackAndRespondedSize {
                responded.removeLast()
            }
        }
    }
    
    // returns true if the request has been saved as responded to previously
    public func isResponded(requestId: String) -> Bool {
        for respondedId in responded {
            if respondedId == requestId {
                C29Log(.Debug, "C29RequestStack isResponded query: request \(requestId) true")
                return true
            }
        }
        return false
    }
    
    // returns true if the current stack or responded list contains an request with the id == requestId
    public func getRequest(requestId: String) -> C29RequestDataSource? {
        // check the stack
        for request in stack {
            if request.id == requestId {
                return request
            }
        }
        // check responded
        return C29Request?()
    }
    
    // returns true if the current stack or responded list contains an request with the id == requestId
    public func contains(requestId: String) -> Bool {
        // check responded
        return (self.getRequest(requestId) != nil) || self.isResponded(requestId)
    }
        
    // Note: this only remove local copies -- not on the datastore!
    // This is intended to be used by V29Session.resetUser() which we expect will handle server-side deletion, too.
    public func removeAll() {
        stack.removeAll()
        responded.removeAll()
        save()
    }
    
    // remove any expired requests from the stack
    private func clearExpired() {
        var temp = self.stack
        for request in self.stack {
            if !request.expired {
                temp.append(request)
            }
        }
        self.stack = temp
        save()
    }
    
    public func load() -> Bool {
        if let session = session {
            return load(session.appGroupIdentifier)
        }
        return false
    }
    
    public func deleteFile() {
        if let session = session {
            deleteFile(session.appGroupIdentifier)
        }
    }

    public func save() {
        if let session = session {
            save(session.appGroupIdentifier)
        }
    }
}

extension C29RequestStack:FileSaveable {
    
}

extension C29RequestStack:FileLoadable {
    public func set(stack: C29RequestStack) {
        self.stack = stack.stack
        self.responded = stack.responded
        self.clearExpired()
    }
}