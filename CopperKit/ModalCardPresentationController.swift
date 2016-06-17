//
//  ModalCardPresentationController
//  Copper
//
//  Created by Doug Williams 3/31/16
//  Copyright (c) 2016 Copper Technologies, Inc. All rights reserved.
//

import UIKit

class ModalCardPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    
    var chromeView: UIView = UIView()
    var tapToCloseEnabled = true
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController:presentedViewController, presentingViewController:presentingViewController)
        chromeView.backgroundColor = UIColor.copper_ModalCardChromeBackgroundColor()
        chromeView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ModalCardPresentationController.chromeViewTapped(_:)))
        chromeView.addGestureRecognizer(tap)
    }
    
    func chromeViewTapped(gesture: UIGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Ended) {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        let containerBounds = containerView!.bounds
        presentedViewFrame.size = sizeForChildContentContainer(presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin = containerBounds.origin
    
        return presentedViewFrame
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return parentSize
    }
    
    override func presentationTransitionWillBegin() {
        chromeView.frame = self.containerView!.bounds
        chromeView.alpha = 0.0
        containerView!.insertSubview(chromeView, atIndex:0)
        let coordinator = presentedViewController.transitionCoordinator()
        if (coordinator != nil) {
            coordinator!.animateAlongsideTransition({
                (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 1.0
            }, completion:nil)
        } else {
            chromeView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator()
        if (coordinator != nil) {
            coordinator!.animateAlongsideTransition({
                (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 0.0
            }, completion:nil)
        } else {
            chromeView.alpha = 0.0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        chromeView.frame = containerView!.bounds
        presentedView()!.frame = frameOfPresentedViewInContainerView()
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return true
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
    
//    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
//        return UIModalPresentationStyle.OverFullScreen
//    }
   
}
