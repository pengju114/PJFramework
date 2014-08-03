//
//  PJCore.h
//  PJFramework
//
//  Created by 陆振文 on 14-7-31.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJCore : NSObject

+(PJCore *)shareInstance;

-(BOOL)initialize;

@end
