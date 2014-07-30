//
//  NSObject+ApplicationSession.h
//  PJFramework
//
//  Created by 陆振文 on 14-7-30.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ApplicationSession)


-(void) setSessionId:(NSString *)sessionId;
-(NSString *) sessionId;

-(void) addSessionObject:(id)object forKey:(id<NSCopying>)key;
-(id) sessionObjectForKey:(id<NSCopying>)key;
-(void) removeSessionObjectForKey:(id<NSCopying>)key;


+(void) setSessionId:(NSString *)sessionId;
+(NSString *) sessionId;

+(void) addSessionObject:(id)object forKey:(id<NSCopying>)key;
+(id)   sessionObjectForKey:(id<NSCopying>)key;
+(void) removeSessionObjectForKey:(id<NSCopying>)key;

@end
