//
//  DESUtility.h
//  Icon
//
//  Created by PENGJU on 13-9-17.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEncryptKey "3desApp_"


@interface DESUtility : NSObject

+(NSData *)encryptWithData:(NSData *)data;
+(NSData *)decryptWithData:(NSData *)data;
+(NSString *)encryptWithMD5:(NSString *)string;

+(NSString *)encryptString:(NSString *)string;
+(NSString *)decryptString:(NSString *)string;

@end
