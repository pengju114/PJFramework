//
//  ImageUtility.m
//  Icon
//
//  Created by PENGJU on 13-8-31.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import "ImageUtility.h"


@implementation ImageUtility

+(UIImage *)loadStretchableImage:(NSString *)name withLeftCap:(NSUInteger)left andTopCap:(NSUInteger)top{
    UIImage *origin=[UIImage imageNamed:name];
    
    if ([origin respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        UIEdgeInsets insets;
        insets.left=left;
        insets.top=top;
        insets.right=left;
        insets.bottom=top;
        UIImage *image=[origin resizableImageWithCapInsets:insets];
        return image;
    }else{
        UIImage *image=[origin stretchableImageWithLeftCapWidth:left topCapHeight:top];
        return image;
    }
}
@end
