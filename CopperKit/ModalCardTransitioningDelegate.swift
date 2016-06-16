//
//  ModalCardTransitioningDelegate
//  Copper
//
//  Created by Doug Williams 3/31/16
//  Copyright (c) 2016 Copper Technologies, Inc. All rights reserved.
//

import UIKit

public class ModalCardTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = ModalCardPresentationController(presentedViewController:presented, presentingViewController:presenting)
        return presentationController
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = ModalCardAnimatedTransitioning()
        animationController.isPresentation = true
        return animationController
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = ModalCardAnimatedTransitioning()
        animationController.isPresentation = false
        return animationController
    }
   
}
