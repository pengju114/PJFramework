//
//  ColorUtility.m
//  Icon
//
//  Created by PENGJU on 13-8-20.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import "ColorUtility.h"

@implementation ColorUtility

+(UIColor *)parseColor:(NSString *)hexString{
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //a
    NSString *aString = @"FF";
    if (cString.length==8) {
        aString = [cString substringWithRange:range];
        range.location+=2;
    }
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location += 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location += 2;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b, a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:((float)a/255.0f)];
}

@end
