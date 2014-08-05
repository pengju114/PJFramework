//
//  ModalAlertDelegate.h
//  PJFramework
//
//  Created by 陆振文 on 14-8-5.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate>
@property(nonatomic,WEAK) id<UIAlertViewDelegate> outsideDelegate;
@property(nonatomic,assign,readonly) NSInteger index;
@property(nonatomic,assign)  BOOL  correctPosition;

-(id)initWithRunloop:(CFRunLoopRef) runloop;

@end
