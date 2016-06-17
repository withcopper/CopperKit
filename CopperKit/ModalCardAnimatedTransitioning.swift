//
//  ModalCardAnimatedTransitioning
//  Copper
//
//  Created by Doug Williams 3/31/16
//  Copyright (c) 2016 Copper Technologies, Inc. All rights reserved.
//

import UIKit

class ModalCardAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresentation : Bool = false
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return C29Utils.animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromView = fromVC?.view
        let toView = toVC?.view
        let containerView = transitionContext.containerView()
        
        if isPresentation {
            containerView!.addSubview(toView!)
        }
        
        let animatingVC = isPresentation ? toVC : fromVC
        let animatingView = animatingVC?.view
        
        let finalFrameForVC = transitionContext.finalFrameForViewController(animatingVC!)
        var initialFrameForVC = finalFrameForVC
        initialFrameForVC.origin.y += initialFrameForVC.size.height;
        
        let initialFrame = isPresentation ? initialFrameForVC : finalFrameForVC
        let finalFrame = isPresentation ? finalFrameForVC : initialFrameForVC
        
        animatingView?.frame = initialFrame
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options:UIViewAnimationOptions.AllowUserInteraction, animations:{
            animatingView?.frame = finalFrame
            }, completion:{ (value: Bool) in
                if !self.isPresentation {
                    fromView?.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
        })
    }
   
}
