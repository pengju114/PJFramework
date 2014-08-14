//
//  DESUtility.m
//  Icon
//
//  Created by PENGJU on 13-9-17.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import "DESUtility.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonCrypto.h>

#import "core.h"


@implementation DESUtility

+(NSData *)encryptWithData:(NSData *)data{
    //先加密,后Base64
    NSData *result=[DESUtility didOperation:data operation:kCCEncrypt];
    return [GTMBase64 encodeData:result];
}
+(NSData *)decryptWithData:(NSData *)data{
    //先Base64,后解密
    NSData *decodeBase64=[GTMBase64 decodeData:data];
    return [DESUtility didOperation:decodeBase64 operation:kCCDecrypt];
}

+(NSData *)didOperation:(NSData *)data operation:(CCOperation)operation{
    
    //确保字节数为8的倍数
    NSMutableData *md=[NSMutableData dataWithData:data];
    if (data.length%8!=0) {
        int pad=8-data.length%8;
        uint8_t spaces[pad];
        memset(spaces, 32, pad);
        
        [md appendBytes:spaces length:pad];
        data=md;
    }
    
    const void *dataIn=[data bytes];
    size_t dataInLength=[data length];
    /*
     DES加密 ：用CCCrypt函数加密一下，然后用base64编码下，传过去
     DES解密 ：把收到的数据根据base64，decode一下，然后再用CCCrypt函数解密，得到原本的数据
     */
    CCCryptorStatus ccStatus;
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码，比如：一个人用int，一个人用long。最好用typedef来定义）
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
    
    const void *vkey = kEncryptKey;
    const void *iv = NULL;
    
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(operation,//  加密/解密
                       kCCAlgorithmDES,//  加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionECBMode,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                       vkey,  //密钥    加密和解密的密钥必须一致
                       kCCKeySizeDES,//   DES 密钥的大小（kCCKeySizeDES=8）
                       iv, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);
    
    
    NSData *result=[NSData dataWithBytes:dataOut length:dataOutMoved];
    free(dataOut);
    
    return result;
}

+(NSString *)encryptWithMD5:(NSString *)string{
    const char    *characters=[string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    int charCount=strlen(characters);
    
    CC_MD5(characters, charCount, result);
    
    NSMutableString *mstr=AutoRelease([[NSMutableString alloc] init]);
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [mstr appendFormat:@"%02X",result[i]];
    }
    return [mstr lowercaseString];
}

+(NSString *)encryptString:(NSString *)string{
    NSString *enc=nil;
    NSData *d=[self encryptWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    enc=AutoRelease([[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]);
    return enc;
}

+(NSString *)decryptString:(NSString *)string{
    NSData *d=[self decryptWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *dec=AutoRelease([[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding]);
    return trim(dec);
}

@end
