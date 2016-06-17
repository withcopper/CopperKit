//
//  WebKitViewController
//  Copper
//
//  Created by Doug Williams on 5/12/16.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

import Foundation
import WebKit

public class WebKitViewController: UIViewController {
    
    class func webKitViewController() -> WebKitViewController {
        let controller = UIStoryboard(name: "WebKit", bundle: CopperKitBundle).instantiateInitialViewController() as! WebKitViewController
        return controller
    }

    public var application: C29CopperworksApplication? {
        didSet {
           networkActivityIndicator.barColor = application?.color ?? DefaultAccentColor
        }
    }
    
    let DefaultAccentColor = UIColor.copper_primaryCopper()
    let GradientStartColor = UIColor.copper_black20()
    let GradientFadeColor = UIColor.copper_black().colorWithAlphaComponent(0.0)
    let BackgroundColor = UIColor.hexStringToUIColor("#F5F5F5")
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var topGradientView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var networkActivityIndicator: NetworkActivityIndicatorView!
    @IBOutlet weak var bottomGradientView: UIView!

    var c29delegate: C29UserInfoViewControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.modalPresentationStyle = .Custom
        self.view.backgroundColor = UIColor.clearColor()
        self.topGradientView.backgroundColor = UIColor.clearColor()
        topGradientView.addGradient(GradientStartColor, bottomColor: GradientFadeColor)
        self.bottomGradientView.backgroundColor = UIColor.clearColor()
        bottomGradientView.addGradient(GradientFadeColor, bottomColor: GradientStartColor)
        syncGradientViews()
        webView.backgroundColor = BackgroundColor
        webView.opaque = false
        networkActivityIndicator.barColor = DefaultAccentColor
        networkActivityIndicator.alpha = 0.0
        webView.dataDetectorTypes = .None // prevents phone numbers and email addresses from automatically linking, limits to HTTP Links
        webView.delegate = self
        webView.scrollView.delegate = self
        self.closeButton.tintColor = UIColor.self.copper_black92()
        closeButton.setImage(C29ImageAssets.IconClose.image, forState: .Normal)
        closeButton.alpha = 1.0
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                        selector: #selector(WebKitViewController.loginLinkReceived(_:)),
                                                            name: C29ApplicationLinkReceivedNotification,
                                                            object: nil)
    }
    
    override public func viewDidAppear(animated: Bool) {
        networkActivityIndicator.alpha = 1.0
    }
    
    override public func viewWillDisappear(animated: Bool) {
        // prevent the user from pulling down on the view, revealing the webview activity indicator
        webView.scrollView.bounces = false
    }
        
    func loginLinkReceived(notification: NSNotification) {
        c29delegate?.openURLReceived(notification, withViewController: self)
    }

    func loadWebview(url: NSURL, headers: [String:String]! = nil) {
        let request = NSMutableURLRequest(URL: url)
        if let headers = headers {
            for (header, value) in headers {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        self.webView.loadRequest(request)
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.c29delegate?.finish(nil, error: nil)
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func syncGradientViews() {
        updateTopGradientView()
        updateBottomGradientView()
    }
    
    func updateTopGradientView() {
        let y: CGFloat
        if webView.scrollView.contentOffset.y < 50 {
            // we are bear the top so show the button, hide the gradient
            y = 0
        } else {
            // we are not near the top so hide the button, show the gradient
            y = min(100, webView.scrollView.contentOffset.y) - 50
        }
        let topGradientViewAlpha = 1.0 * (y / 50)
        let closeButtonAlpha = 1.0 - topGradientViewAlpha
        self.topGradientView.alpha = topGradientViewAlpha
        self.closeButton.alpha = closeButtonAlpha
    }
    
    func updateBottomGradientView() {
        let y: CGFloat
        let contentOffsetY = webView.scrollView.contentSize.height - webView.scrollView.contentOffset.y - webView.frame.height
        if contentOffsetY < 50 {
            // we are showing the bottom, hide the
            y = 0
        } else {
            // we are not showing the buttom, show the gradient
            y = min(100, contentOffsetY) - 50
        }
        let bottomGradientViewAlpha = 1.0 * (y / 50)
        self.bottomGradientView.alpha = bottomGradientViewAlpha
    }
}

extension WebKitViewController: UIWebViewDelegate {
    public func webViewDidStartLoad(webView: UIWebView) {
        networkActivityIndicator.networkActivityViewStarted = true
        self.c29delegate?.trackEvent(.DialogWebKitPageLoadComplete)
        syncGradientViews()
    }
    public func webViewDidFinishLoad(webView: UIWebView) {
        networkActivityIndicator.networkActivityViewStarted = false
        syncGradientViews()
    }
    public func didFailLoadWithError(webView: UIWebView) {
        networkActivityIndicator.networkActivityViewStarted = false
        syncGradientViews()
    }
}

extension WebKitViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        updateTopGradientView()
        updateBottomGradientView()
    }
}

extension WebKitViewController {
    enum Error: Int {
        case DocumentDidNotLoad = 0
        var reason: String {
            switch self {
            case .DocumentDidNotLoad:
                return "Document Did Not Load"
            }
        }
        var nserror: NSError {
            return NSError(domain: self.domain, code: self.rawValue, userInfo: [NSLocalizedFailureReasonErrorKey: self.reason])
        }
        var domain: String {
            return "\(NSBundle.mainBundle().bundleIdentifier!).WebKitViewController"
        }
    }
}