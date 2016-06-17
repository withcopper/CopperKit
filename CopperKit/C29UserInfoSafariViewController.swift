//
//  C29UserInfoSafariViewController
//  Copper
//
//  Created by Doug Williams on 3/2/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import UIKit
import SafariServices

@available(iOS 9.0, *)
public class C29UserInfoSafariViewController: SFSafariViewController, SFSafariViewControllerDelegate {

    var c29delegate: C29UserInfoViewControllerDelegate?

    override public func loadView() {
        super.loadView()
        self.delegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(C29UserInfoSafariViewController.loginLinkReceived(_:)),
            name: C29ApplicationLinkReceivedNotification,
            object: nil)
    }
    
    func loginLinkReceived(notification: NSNotification) {
        c29delegate?.openURLReceived(notification, withViewController: self)
    }
    
    public func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        C29Log(.Debug, "safariViewController didCompleteInitialLoadSuccessfully? \(didLoadSuccessfully)")
        self.c29delegate?.trackEvent(.DialogSafariPageLoadComplete)
    }
    
    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        c29delegate?.finish(nil, error: nil)
    }

    
}