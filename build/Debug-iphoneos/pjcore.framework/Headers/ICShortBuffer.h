//
//  ICShortBuffer.h
//  Icon
//
//  Created by PENGJU on 13-6-8.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _ByteOrder{
    ByteOrderBigEndian=1<<4,
    ByteOrderLittleEndian,
    ByteOrderNoEndian
}ICByteOrder;



/*!
 @abstract short类型缓冲区类
 @param  originalBytes 字节缓冲区,在使用的时候不要释放
 */
@interface ICShortBuffer : NSObject{
    const Byte   *originalData;
    NSUInteger   byteLength;
    NSUInteger   currentIndex;
    NSUInteger   count;
    ICByteOrder  bitOrder;
}
@property (nonatomic,readonly) const void *originalData;
@property (nonatomic,readonly) NSUInteger byteLength;
@property (nonatomic,readonly) NSUInteger currentIndex;
@property (nonatomic,readonly) NSUInteger count;
@property (nonatomic)          ICByteOrder bitOrder;

-(id)initWithBytes:(const void *)originalBytes bytesCount:(NSUInteger)bc;//不允许修改原来的字节

-(short)shortValueAtIndex:(NSUInteger)index;
-(short)nextShortValue;

@end