//
//  UIView+Extension.m
//  PJFramework
//
//  Created by 陆振文 on 14-8-9.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

-(BOOL)containsView:(UIView *)view{
    if (view) {
        UIView *tmp = view.superview;
        while (tmp) {
            if ([self isEqual:tmp]) {
                return YES;
            }
            tmp = tmp.superview;
        }
    }
    return NO;
}

-(void)removeAllChildren{
    for (UIView *v in [self subviews]) {
        [v removeFromSuperview];
    }
}

-(CGRect)frameInView:(UIView *)superView{
    if (superView && [superView containsView:self]) {
        UIView *tmp = self;
        
        CGFloat x = self.frame.origin.x;
        CGFloat y = self.frame.origin.y;
        
        while (![superView isEqual:(tmp = tmp.superview)]) {
            x += tmp.frame.origin.x;
            y += tmp.frame.origin.y;
        }
        
        return CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
    }
    return self.frame;
}

@end
