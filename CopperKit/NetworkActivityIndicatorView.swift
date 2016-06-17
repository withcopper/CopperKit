//
//  NetworkActivityIndicatorView.swift
//  Copper
//
//  Created by Doug Williams on 1/23/16.
//  Copyright © 2016 Copper Technologies, Inc. All rights reserved.
//

import Foundation

public class NetworkActivityIndicatorView: UIView {

    static let NibName = "NetworkActivityIndicatorView"
    
    @IBOutlet weak var networkActivityBar: UIView!
    @IBOutlet weak var networkActivityBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var networkActivityBarLeadingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    
    func xibSetup() {
        let view = loadViewFromNib()
        self.frame = bounds
        self.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        setup()
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = CopperKitBundle // NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: NetworkActivityIndicatorView.NibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        self.setNeedsLayout()
        self.barColor = UIColor.whiteColor()
        self.hidden = true
    }
    
    public var barColor: UIColor? {
        didSet {
            networkActivityBar.backgroundColor = barColor
        }
    }
    
    override public func layoutSubviews() {
        networkActivityBarWidthConstraint.constant = networkActivityBarWidth
    }

    var networkActivityBarWidth: CGFloat {
        return self.frame.size.width
    }

    public var networkActivityViewStarted = false {
        didSet {
            if self.networkActivityViewStarted && self.hidden {
                self.startNetworkActivityIndicator()
            } else if !self.networkActivityViewStarted {
                self.stopNetworkActivityIndicator()
            }
        }
    }

    public func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NetworkActivityIndicatorView.networkActivityBegan(_:)), name: C29NetworkActivityBeganNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NetworkActivityIndicatorView.networkActivityEnded(_:)), name: C29NetworkActivityEndedNotification, object: nil)
    }
    
    public func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: C29NetworkActivityBeganNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: C29NetworkActivityEndedNotification, object: nil)
    }

    public func networkActivityBegan(notification: NSNotification){
        startNetworkActivityIndicator()
    }

    public func networkActivityEnded(notification: NSNotification){
        stopNetworkActivityIndicator()
    }

    private func startNetworkActivityIndicator() {
        // we start it just off screen
        networkActivityBarLeadingConstraint.constant = -networkActivityBarWidth
        self.hidden = false
        self.alpha = 1.0
        self.layoutIfNeeded()
        UIView.animateWithDuration(C29Utils.animationDuration*3, animations: {
            // then animate it across the screen
            self.networkActivityBarLeadingConstraint.constant = self.networkActivityBarWidth
            self.layoutIfNeeded()
            },
            completion: { finished in
                if !self.hidden {
                    self.startNetworkActivityIndicator()
                }
            }
        )
    }

    private func stopNetworkActivityIndicator() {
        if !self.hidden {
            UIView.animateWithDuration(C29Utils.animationDuration,
                animations: {
                    self.alpha = 0.0
                },
                completion: { finished in
                    self.hidden = true
                }
            )
        }
    }
}
