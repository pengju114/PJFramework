//
//  UIView+Extension.h
//  PJFramework
//
//  Created by 陆振文 on 14-8-9.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

-(BOOL)containsView:(UIView *)view;
-(void)removeAllChildren;

-(CGRect)frameInView:(UIView *)superView;

@end
