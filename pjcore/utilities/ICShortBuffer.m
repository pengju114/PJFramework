//
//  ICShortBuffer.m
//  Icon
//
//  Created by PENGJU on 13-6-8.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import "ICShortBuffer.h"

@implementation ICShortBuffer
@synthesize originalData,byteLength,currentIndex,count,bitOrder;

-(id)initWithBytes:(const void *)originalBytes bytesCount:(NSUInteger)bc{
    if (self=[super init]) {
        originalData=(const Byte *)originalBytes;
        byteLength=bc;
        currentIndex=-1;
        count=byteLength/2;
        bitOrder=ByteOrderNoEndian;
    }
    return self;
}

-(short)shortValueAtIndex:(NSUInteger)index{
    if (index<self.count) {
        short v=-1;
        NSUInteger i=index*2;//起始字节下标
        if (self.bitOrder==ByteOrderLittleEndian) {
            v=(short)(((int16_t)originalData[i+1])<<8|originalData[i]);
        }else{
            v=(short)(((int16_t)originalData[i])<<8|originalData[i+1]);
        }
        return v;
    }
    return -1;
}

-(short)nextShortValue{
    return [self shortValueAtIndex:++currentIndex];
}

@end

