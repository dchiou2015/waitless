//
//  UIViewController+SoftModal.h
//  Squawk2
//
//  Created by Nate Parrott on 3/31/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SoftModal)

-(void)presentSoftModalInViewController:(UIViewController*)parent;
-(void)presentSoftModal;
-(void)dismissSoftModal;
- (void)updateFrameWithSoftModalBounds:(CGRect)bounds;

@end
