//
//  C29BrowserLoginViewController
//  Copper
//
//  Created by Doug Williams on 3/2/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import UIKit
import SafariServices

@available(iOS 9.0, *)
public class C29BrowserLoginViewController: SFSafariViewController, SFSafariViewControllerDelegate {

    private var application: C29Application? {
        didSet {
            // no op atm
        }
    }
    
    override public func loadView() {
        self.delegate = self
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

    }
    
    public func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        C29Log(.Debug, "safariViewController didCompleteInitialLoadSuccessfully? \(didLoadSuccessfully)")

    }
    
    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        // no op
    }
    
}