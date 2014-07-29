//
//  ImageUtility.h
//  Icon
//
//  Created by PENGJU on 13-8-31.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtility : NSObject

+(UIImage *)loadStretchableImage:(NSString *)name withLeftCap:(NSUInteger)left andTopCap:(NSUInteger)top;

@end
