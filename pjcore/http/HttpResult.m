//
//  HttpResult.m
//  PJFramework
//
//  Created by 陆振文 on 14-7-29.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "HttpResult.h"


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
@property (nonatomic,WEAK  ) HTTPStatus    statusCode;
@property (nonatomic,STRONG) NSString      *statusText;
@end


@implementation HttpResult

-(id) initWithResponseData:(id)respData andResponseHeaders:(NSDictionary *)header{
    return [self initWithResponseData:respData andResponseHeaders:header andStatusText:nil];
}

-(id) initWithResponseData:(id)respData andResponseHeaders:(NSDictionary *)header andStatusText:(NSString *)st{
    if (self = [self init]) {
        self.statusCode = kHTTPError;
        if (respData && [respData isKindOf:[NSDictionary class]]) {
            
            NSDictionary *header = wrapper.getObjectAndIgnoreList(KEY_HEADER);
            if (header!=null) {
                statusCode=ConvertUtility.parseInt(header.getString(KEY_STATUS_CODE), statusCode);
                if (!StringUtility.isEmpty(header.getString(KEY_STATUS_TEXT))) {
                    statusText=header.getString(KEY_STATUS_TEXT);
                }
            }
        }
    }
    return self;
}

/*!
 @abstract 获取服务器返回的数据
 */
-(NSArray *) dataList;

-(NSInteger) pageCount;

-(NSInteger) currentPage;
-(NSInteger) totalResultsCount;
@end
