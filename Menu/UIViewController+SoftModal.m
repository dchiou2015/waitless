//
//  UIViewController+SoftModal.m
//  Squawk2
//
//  Created by Nate Parrott on 3/31/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "UIViewController+SoftModal.h"
#import "UIImage+ImageEffects.h"

@implementation UIViewController (SoftModal)

-(void)presentSoftModalInViewController:(UIViewController*)parent {
    UIButton* dismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIGraphicsBeginImageContext(parent.view.bounds.size);
    [parent.view drawViewHierarchyInRect:parent.view.bounds afterScreenUpdates:NO];
    UIImage* snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    snapshot = [snapshot applyDarkEffect];
    
    [dismiss setBackgroundImage:snapshot forState:UIControlStateNormal];
    dismiss.adjustsImageWhenHighlighted = NO;
    [dismiss addTarget:self action:@selector(dismissSoftModal) forControlEvents:UIControlEventTouchDown];
    
    dismiss.alpha = 0;
    dismiss.frame = parent.view.bounds;
    [self updateFrameWithSoftModalBounds:parent.view.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    UIImageView *closeButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CloseModal"]];
    [closeButton sizeToFit];
    closeButton.frame = CGRectMake(20, 30, closeButton.frame.size.width, closeButton.frame.size.height);
    closeButton.userInteractionEnabled = NO;
    [dismiss addSubview:closeButton];
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    closeButton.alpha = 0.4;
    
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 5;
    
    dismiss.tag = (int)276435067879564; // hack
    
    [parent addChildViewController:self];
    
    [parent.view addSubview:dismiss];
    [parent.view addSubview:self.view];
    
    self.view.center = CGPointMake(self.parentViewController.view.frame.size.width/2, self.parentViewController.view.frame.size.height+self.view.bounds.size.height/2+100);
    
    [self viewWillAppear:YES];
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        dismiss.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.70 initialSpringVelocity:0 options:0 animations:^{
        [self updateFrameWithSoftModalBounds:parent.view.bounds];
    } completion:^(BOOL finished) {
        
    }];
}
-(void)presentSoftModal {
    UIViewController* root = [[UIApplication sharedApplication].windows.firstObject rootViewController];
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }
    [self presentSoftModalInViewController:root];
}
-(void)dismissSoftModal {
    [self viewWillDisappear:YES];
    UIButton* dismiss = (id)[self.parentViewController.view viewWithTag:(int)276435067879564]; // aaahhh!
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        dismiss.alpha = 0;
        self.view.center = CGPointMake(self.parentViewController.view.frame.size.width/2, self.parentViewController.view.frame.size.height+self.view.bounds.size.height/2+100);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [dismiss removeFromSuperview];
        [self viewDidDisappear:YES];
        [self removeFromParentViewController];
    }];
}
-(CGSize)sizeInSoftModal {
    return CGSizeMake(280, 340);
}
- (void)updateFrameWithSoftModalBounds:(CGRect)bounds {
    self.view.frame = CGRectMake(0, 0, [self sizeInSoftModal].width, [self sizeInSoftModal].height);
    self.view.center = CGPointMake(bounds.size.width/2, bounds.size.height/2);
}

@end
