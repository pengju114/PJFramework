//
//  HttpUtility.h
//  Icon
//
//  Created by PENGJU on 13-9-5.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HttpUtility : NSObject

+(NSDictionary *)parseXML:(NSData *)data;

+(NSDictionary *)parseJSON:(NSData *)data;

@end
