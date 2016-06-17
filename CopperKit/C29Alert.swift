//
//  C29Alert.swift
//  CopperKit
//
//  Created by Doug Williams on 4/20/16.
//  Copyright © 2016 Doug Williams. All rights reserved.
//

import Foundation

public class C29Alert {
    
    public var title: String?
    public var message: String?
    public var headerImage: UIImage?
    public var image: UIImage?
    public var actions = [C29AlertAction]()
    public var presentingViewController: UIViewController?
    
    public static let DefaultCancelAction = C29AlertAction(title: "Not right now", format: .Inline, handler: nil)
    
    public init(title: String! = nil, message: String! = nil, headerImage: UIImage! = nil, image: UIImage! = nil) {
        self.title = title
        self.message = message
        self.image = image
        self.headerImage = headerImage
    }
    
    public func addAction(action: C29AlertAction) {
        self.actions.append(action)
    }
    
    public func removeAllActions() {
        self.actions = [C29AlertAction]()
    }
    
}

public protocol C29AlertActionDelegate {
    func actionEnabledDidChange(action: C29AlertAction)
}

public class C29AlertAction: Equatable {
    
    public enum C29AlertActionStyle {
        case Default // button/text color per default
        case Destructive // button/text color that says red
        case Suggestive // button/text color that suggests
        case Green
    }
    
    public enum C29AlertActionFormat {
        case Default // black outlined button
        case Inline // smaller, text only
    }
    
    public let title: String
    public let handler: (()->())?
    public let style: C29AlertActionStyle
    public let format: C29AlertActionFormat
    public let closeAfterAction: Bool
    public var repeatable = false
    
    public var delegate: C29AlertActionDelegate?
    
    public var enabled = true {
        didSet {
            self.delegate?.actionEnabledDidChange(self)
        }
    }
    
    public init(title: String, format: C29AlertActionFormat = .Default, style: C29AlertActionStyle = .Default, closeAfterAction: Bool = true, handler: (()->())! = nil) {
        self.title = title
        self.handler = handler
        self.style = style
        self.format = format
        self.closeAfterAction = closeAfterAction
    }
    
    public func perform(completion: (()->())) {
        if let handler = handler {
            handler()
        }
        completion()
    }
}

public func ==(lhs: C29AlertAction, rhs: C29AlertAction) -> Bool {
    return lhs.format == rhs.format && lhs.style == rhs.style && lhs.title == rhs.title
}