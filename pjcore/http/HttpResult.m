//
//  HttpResult.m
//  PJFramework
//
//  Created by 陆振文 on 14-7-29.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "HttpResult.h"
#import "NSDictionary+HTTPDictionary.h"


#define kKeyHeader		       @"header"
#define kKeyResult		       @"result"


#define kKeyStatusCode	       @"statusCode"
#define kKeyStatusText		   @"statusText"
#define kKeyTotalResultCount   @"totalResults"
#define kKeyCurrentPage  	   @"pageNumber"
#define kKeyPageCount 	       @"pageCount"



@interface HttpResult ()
@property (nonatomic,STRONG) id            responseData;
@property (nonatomic,STRONG) NSDictionary  *responseHeader;
@property (nonatomic,assign) HTTPStatus    statusCode;
@property (nonatomic,STRONG) NSString      *statusText;
@end


@implementation HttpResult

@synthesize responseData;
@synthesize responseHeader;
@synthesize statusText;
@synthesize statusCode;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.statusCode = kHTTPError;
    }
    return self;
}

- (void)dealloc
{
    Release(self.responseData);
    Release(self.responseHeader);
    Release(self.statusText);
#ifndef ARC
    [super dealloc];
#endif
}

-(id) initWithResponseData:(id)respData andResponseHeaders:(NSDictionary *)header{
    return [self initWithResponseData:respData andResponseHeaders:header andStatusText:nil];
}

-(id) initWithResponseData:(id)respData andResponseHeaders:(NSDictionary *)header andStatusText:(NSString *)st{
    if (self = [self init]) {
        self.statusCode = kHTTPError;
        self.responseData = respData;
        self.responseHeader = header;
        self.statusText = st;
        
        if (respData && [respData isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *httpHeader = [respData singleObjectForKey:kKeyHeader];
            if (header) {
                id sc = [httpHeader objectForKey:kKeyStatusCode];
                self.statusCode=sc?[sc integerValue]:kHTTPError;
                
                st = [httpHeader objectForKey:kKeyStatusText];
                if (isEmptyString(st)) {
                    self.statusText = st;
                }
            }
        }
    }
    return self;
}

/*!
 @abstract 获取服务器返回的数据
 */
-(NSArray *) dataList{
    if (self.responseData && [self.responseData isKindOfClass:[NSDictionary class]]) {
        return [self.responseData objectForKey:kKeyResult];
    }
    return nil;
}

-(NSInteger) pageCount{
    return [self integerValueForHeader:kKeyPageCount];
}

-(NSInteger) currentPage{
    return [self integerValueForHeader:kKeyCurrentPage];
}

-(NSInteger) totalResultsCount{
    return [self integerValueForHeader:kKeyTotalResultCount];
}

-(NSInteger) integerValueForHeader:(id)key{
    if (self.responseData && [self.responseData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *httpHeader = [self.responseData singleObjectForKey:kKeyHeader];
        return [[httpHeader objectForKey:key] integerValue];
    }
    return -1;
}

@end
