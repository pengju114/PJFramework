//
//  DeviceUtility.m
//  Icon
//
//  Created by PENGJU on 13-8-13.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import "DeviceUtility.h"

@implementation DeviceUtility

+(BOOL)isPhone{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

+(BOOL)isPad{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+(CGRect)applicationFrame{
    return [UIScreen mainScreen].applicationFrame;
}
+(CGRect)screenBounds{
    return [UIScreen mainScreen].bounds;
}
+(CGFloat)screenWidth{
    UIInterfaceOrientation ortn=[[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(ortn)) {
        return [DeviceUtility screenBounds].size.height;
    }
    return [DeviceUtility screenBounds].size.width;
}
+(CGFloat)screenHeight{
    UIInterfaceOrientation ortn=[[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(ortn)) {
        return [DeviceUtility screenBounds].size.width;
    }
    return [DeviceUtility screenBounds].size.height;
}
+(CGFloat)applicationWidth{
    UIInterfaceOrientation ortn=[[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(ortn)) {
        return [DeviceUtility applicationFrame].size.height;
    }
    return [DeviceUtility applicationFrame].size.width;
}
+(CGFloat)applicationHeight{
    UIInterfaceOrientation ortn=[[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(ortn)) {
        return [DeviceUtility applicationFrame].size.width;
    }
    return [DeviceUtility applicationFrame].size.height;
}

@end
