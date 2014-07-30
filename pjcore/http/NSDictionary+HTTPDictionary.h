//
//  NSDictionary+HTTPDictionary.h
//  PJFramework
//
//  Created by 陆振文 on 14-7-30.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HTTPDictionary)
/*!
 @abstract 获取一个对象，如果key映射的目标是列表将取第一个对象返回
 */
-(id) singleObjectForKey:(id)key;
@end
