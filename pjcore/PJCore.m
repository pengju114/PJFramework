//
//  PJCore.m
//  PJFramework
//
//  Created by 陆振文 on 14-7-31.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "PJCore.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"

#define notify_func(name) -(void) application##name

#define HttpTestUrl @"http://www.baidu.com"

static BOOL didInitialize = NO;

static PJCore *coreInstance = nil;

extern NetworkStatus networkStatus;

Reachability * reachability = nil;


@implementation PJCore

+(PJCore *)shareInstance{
    if (coreInstance == nil) {
        @synchronized(self){
            if (coreInstance == nil) {
                id tmp = [[self alloc] init];
                NSLog(@"%@",tmp);
            }
        }
    }
    return coreInstance;
}

+(id)allocWithZone:(struct _NSZone *)zone{
    if (coreInstance == nil) {
        @synchronized(self){
            if (coreInstance == nil) {
                coreInstance = [super allocWithZone:zone];
            }
        }
    }
    return coreInstance;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

#ifndef ARC

-(id)autorelease{
    return self;
}

-(id)retain{
    return self;
}

-(unsigned)retainCount{
    return NSIntegerMax;
}

-(oneway void)release{
    //do notthing
}

#endif


-(BOOL)initialize{
    BOOL ret = !didInitialize;
    if (ret) {
        didInitialize = YES;
        
        [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
        
        // handle application lifecycle
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [center addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [center addObserver:self selector:@selector(applicationDidFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [center addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [center addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [center addObserver:self selector:@selector(applicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [center addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    }
    return ret;
}

notify_func(DidEnterBackground){
    PJLog(@"framework %@",NSStringFromSelector(_cmd));
}
notify_func(WillEnterForeground){
    PJLog(@"framework %@",NSStringFromSelector(_cmd));
}
notify_func(DidFinishLaunching){
    PJLog(@"framework %@",NSStringFromSelector(_cmd));
    //网络监听部分
    networkStatus=NotReachable;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChanged:) name:kReachabilityChangedNotification object:nil];
    reachability=[Reachability reachabilityWithHostName:HttpTestUrl];
    [reachability startNotifier];
    [self performSelectorInBackground:@selector(chenckNetworkState) withObject:nil];
}
notify_func(DidBecomeActive){
    PJLog(@"framework %@",NSStringFromSelector(_cmd));
}
notify_func(WillResignActive){
    PJLog(@"framework %@",NSStringFromSelector(_cmd));
}
notify_func(DidReceiveMemoryWarning){
    PJLog(@"framework %@",NSStringFromSelector(_cmd));
}
notify_func(WillTerminate){
    PJLog(@"framework %@",NSStringFromSelector(_cmd));
    NSArray *array = [NSArray arrayWithObjects:
                      UIApplicationDidEnterBackgroundNotification ,
                      UIApplicationWillEnterForegroundNotification ,
                      UIApplicationDidFinishLaunchingNotification,
                      UIApplicationDidBecomeActiveNotification,
                      UIApplicationWillResignActiveNotification,
                      UIApplicationDidReceiveMemoryWarningNotification,
                      UIApplicationWillTerminateNotification, nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (NSString *notify in array) {
        [center removeObserver:self name:notify object:nil];
    }
}


-(void)networkStateChanged:(NSNotification *)n{
    PJLog(@"framework %@",NSStringFromSelector(_cmd));
    networkStatus=[reachability currentReachabilityStatus];
}

-(void)chenckNetworkState{
    networkStatus=[reachability currentReachabilityStatus];
}

@end
