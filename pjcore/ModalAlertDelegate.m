//
//  ModalAlertDelegate.m
//  PJFramework
//
//  Created by 陆振文 on 14-8-5.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "ModalAlertDelegate.h"
#import "DeviceUtility.h"

@interface ModalAlertDelegate ()
@property(nonatomic,assign) CFRunLoopRef currentRunloop;

@end


@implementation ModalAlertDelegate
@synthesize outsideDelegate;
@synthesize index;
@synthesize correctPosition;

-(id)initWithRunloop:(CFRunLoopRef)runloop{
    if (self = [self init]) {
        _currentRunloop = runloop;
    }
    return self;
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    index = buttonIndex;
    
    if (outsideDelegate && [outsideDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [outsideDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
    
    CFRunLoopStop(_currentRunloop);
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView{
    if (outsideDelegate && [outsideDelegate respondsToSelector:@selector(alertViewCancel:)]) {
        [outsideDelegate alertViewCancel:alertView];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView{
    if (outsideDelegate && [outsideDelegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [outsideDelegate willPresentAlertView:alertView];
    }
}
- (void)didPresentAlertView:(UIAlertView *)alertView{
    if (outsideDelegate && [outsideDelegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [outsideDelegate didPresentAlertView:alertView];
    }
    
    if (correctPosition) {
        [self performSelector:@selector(correctPosition:) withObject:alertView afterDelay:0.1];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (outsideDelegate && [outsideDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [outsideDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (outsideDelegate && [outsideDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [outsideDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
    
    [self performSelector:@selector(dispatchReleaseNotification) withObject:nil afterDelay:1];
}

-(void)dispatchReleaseNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:kModalAlertDelegateShouldReleaseNotification object:self userInfo:[NSDictionary dictionaryWithObject:self forKey:kModalAlertDelegate]];
}


-(void)correctPosition:(UIAlertView *)dialog{
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.35];
    
    CGPoint center = CGPointMake([DeviceUtility applicationWidth]*0.5f, [DeviceUtility applicationHeight]*0.25f);
    
    dialog.center = center;
    
    [UIView commitAnimations];
}

@end
