//
//  NSDictionary+HTTPDictionary.m
//  PJFramework
//
//  Created by 陆振文 on 14-7-30.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "NSDictionary+HTTPDictionary.h"

@implementation NSDictionary (HTTPDictionary)

-(id)singleObjectForKey:(id)key{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        obj = [((NSArray *)obj) firstObject];
    }else if ([obj isKindOfClass:[NSSet class]]){
        obj = [((NSSet *)obj) anyObject];
    }
    return obj;
}

@end
