//
//  NSObject+ApplicationSession.m
//  PJFramework
//
//  Created by 陆振文 on 14-7-30.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "NSObject+ApplicationSession.h"


static NSMutableDictionary *sessionDict = nil;
static id sessionLock = @"session.lock";


#define kSessionKey @"session.id"


@implementation NSObject (ApplicationSession)


+(NSMutableDictionary *)sessionDictionary{
    if (!sessionDict) {
        @synchronized(sessionLock){
            if (!sessionDict) {
                sessionDict = [[NSMutableDictionary alloc] init];
            }
        }
    }
    return sessionDict;
}


-(void) setSessionId:(NSString *)sessionId{
    [NSObject setSessionId:sessionId];
}
-(NSString *) sessionId{
    return [NSObject sessionId];
}

-(void) addSessionObject:(id)object forKey:(id<NSCopying>)key{
    [NSObject addSessionObject:object forKey:key];
}

-(id) sessionObjectForKey:(id<NSCopying>)key{
    return [NSObject sessionObjectForKey:key];
}

-(void) removeSessionObjectForKey:(id<NSCopying>)key{
    [NSObject removeSessionObjectForKey:key];
}


+(void) setSessionId:(NSString *)sessionId{
    [[self sessionDictionary] setObject:sessionId forKey:kSessionKey];
}
+(NSString *) sessionId{
    return [[self sessionDictionary] objectForKey:kSessionKey];
}

+(void) addSessionObject:(id)object forKey:(id<NSCopying>)key{
    [[self sessionDictionary] setObject:object forKey:key];
}
+(id)   sessionObjectForKey:(id<NSCopying>)key{
    return [[self sessionDictionary] objectForKey:key];
}
+(void) removeSessionObjectForKey:(id<NSCopying>)key{
    [[self sessionDictionary] removeObjectForKey:key];
}

@end
