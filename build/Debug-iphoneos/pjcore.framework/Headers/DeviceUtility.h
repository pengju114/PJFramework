//
//  DeviceUtility.h
//  Icon
//
//  Created by PENGJU on 13-8-13.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtility : NSObject

+(BOOL)isPhone;
+(BOOL)isPad;
+(CGRect)applicationFrame;
+(CGRect)screenBounds;
+(CGFloat)screenWidth;
+(CGFloat)screenHeight;
+(CGFloat)applicationWidth;
+(CGFloat)applicationHeight;

@end
