//
//  AlertViewController.swift
//  Copper
//
//  Created by Doug Williams on 4/17/15.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

import UIKit

public protocol CopperAlertViewControllerDelegate {
    func viewDidLoadFinished()
    func viewDidAppearFinished()
}

protocol CopperAlertControllerDatasource {
    var identifiers: [CopperAlertTableRowConfig] { get }
}

public class CopperAlertViewController: UIViewController {
    
    public class func alertViewController() -> CopperAlertViewController {
        let controller = UIStoryboard(name: "CopperAlert", bundle: CopperKitBundle).instantiateInitialViewController() as! CopperAlertViewController
        return controller
    }

    static var DefaultAccentColor: UIColor { return  UIColor.copper_primaryCopper() }
    let TopMargin: CGFloat = 10.0 // space between the tableview and the top of the card
    let BottomPadding: CGFloat = 30.0 // desired space below the table view and bottom of the card
    @IBOutlet weak var alertView: C29RoundedView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: NetworkActivityIndicatorView!
    
    var alertTableViewManager: CopperAlertViewTableManager?
    
    public var alert: C29Alert? // It is expected that this is set before viewDidLoad() is called!!
    public var delegate: CopperAlertViewControllerDelegate?
    public var closeOnTap = true
    
    var dataSource: CopperAlertControllerDatasource? {
        didSet {
            self.alertTableViewManager?.dataSource = dataSource
        }
    }
    
    var indicate: Bool = false {
        didSet {
            if indicate {
                CopperNetworkActivityRegistry.sharedRegistry.activityBegan()
            } else {
                CopperNetworkActivityRegistry.sharedRegistry.activityEnded()
            }
        }
    }
    
    var closing = false
    
    var MaxPossibleViewHeight: CGFloat {
        return self.view.frame.height - C29Utils.getStatusBarHeight()
    }
    
    var desiredViewHeight: CGFloat {
        return min(TopMargin+tableView.contentSize.height+BottomPadding, MaxPossibleViewHeight)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // ensure our prereqs are met
        guard let alert = alert else {
            C29Log(.Error, "You must set the variable 'alert' before loading the view.")
            return
        }
        self.view.backgroundColor = UIColor.clearColor()
        self.alertTableViewManager = CopperAlertViewTableManager(alert: alert)
        alertTableViewManager?.dataSource = self.dataSource
        alertTableViewManager?.delegate = self
        self.activityIndicator.barColor = CopperAlertViewController.DefaultAccentColor
        activityIndicator.hidden = true
        CopperNetworkActivityRegistry.sharedRegistry.delegate = self
        // Ensure buttons get taps right away
        tableView.delaysContentTouches = false
        for view in self.tableView.subviews {
            if let scroll = view as? UIScrollView {
                scroll.delaysContentTouches = false
            }
            break
        }
        self.tableView.dataSource = alertTableViewManager
        tableView.delegate = alertTableViewManager
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.showsVerticalScrollIndicator = false
        tableView.indicatorStyle = .White
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.alwaysBounceVertical = (tableView.contentSize.height > MaxPossibleViewHeight)
        let tap = UITapGestureRecognizer(target: self, action: #selector(CopperAlertViewController.didTapView))
        self.view.addGestureRecognizer(tap)
        self.reload(false)
        self.delegate?.viewDidLoadFinished()
    }

    override public func viewDidAppear(animated: Bool) {
        activityIndicator.hidden = false
        super.viewDidAppear(animated)
        self.reload(true)
        self.delegate?.viewDidAppearFinished()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        self.activityIndicator.hidden = true
    }
    
    public func reload(animated: Bool = true) {
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.layoutSubviews(animated)
    }
    
    override public func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?){
        super.dismissViewControllerAnimated(flag, completion: {
            completion?()
            // if we are reappearing after presenting a viewcontroller, then we should close
            if self.closing {
                self.close()
            }
        })
    }
    
    func layoutSubviews(animated: Bool = true) {
        let duration = animated ? C29Utils.animationDuration : 0.0
        UIView.animateWithDuration(duration, animations: {
            self.alertViewHeightConstraint.constant = self.desiredViewHeight
            self.view.layoutIfNeeded()
        })
    }
    
    func didTapView() {
        if closeOnTap {
            self.close()
        }
    }
    
    public func close() {
        // if we presented a view in this handler... then we shouldn't close the alert.
        // Instead we skip it here... and catch it in viewDidAppear when we are back on screen
        if self.presentedViewController == nil {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.closing = true
        }
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension CopperAlertViewController: CopperAlertViewTableManagerDelegate {
    func actionWasPressed(action: C29AlertAction) {
        action.perform({
            if action.closeAfterAction {
                self.close()
            }
        })
    }
}

extension CopperAlertViewController: UIViewControllerTransitioningDelegate {
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented == self {
            return ModalCardPresentationController(presentedViewController: presented, presentingViewController: presenting)
        } else {
            return nil
        }
    }
}

extension CopperAlertViewController: CopperNetworkActivityRegistryDelegate {
    public func networkIndicatorShouldIndicate() {
        self.activityIndicator.networkActivityViewStarted = true
    }
    public func networkIndicatorShouldNotIndicate() {
        self.activityIndicator.networkActivityViewStarted = false
    }
}
    
