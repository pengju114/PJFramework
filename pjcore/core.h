//
//  core.h
//  core
//
//  Created by PENGJU on 14-2-10.
//  Copyright (c) 2014年 pengju. All rights reserved.
//

#ifndef core_core_h
#define core_core_h

// 日志开关
#define debug 1

#if debug
#define PJLog(...) NSLog(__VA_ARGS__)
#else
#define PJLog(...)
#endif


/**
 * ARC支持
 */
#if __has_feature(objc_arc)

#define ARC_SUPPORT
#define ARC
#define STRONG strong

#if __has_feature(objc_arc_weak)
#define WEAK weak
#else 
#define WEAK unsafe_unretained
#endif

#define Retain(x)      (x)
#define Release(x)
#define AutoRelease(x) (x)

#else

#define STRONG retain
#define WEAK   assign

#define Retain(x)      [(x) retain]
#define Release(x)     [(x) release]
#define AutoRelease(x) [(x) autorelease]

#endif


/**
 * 常用快捷方式
 */

#define DocumentPath ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0])

/**
 * 加载资源图片
 */
#define loadImage(name) ([UIImage imageNamed:(name)])
/**
 * 保证string不为nil,为nil则返回空字符串
 */
#define str(string)     ((string)==nil?@"":(string))
/**
 * 去除字符串两端空格
 */
#define trim(string)    ((string)==nil?@"":([(string) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]))
/**
 * 去除字符串所以空格
 */
#define trimAll(string) ([[NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:nil] stringByReplacingMatchesInString:(string) options:0 range:NSMakeRange(0, (string).length) withTemplate:@""])
/**
 * 判断字符串是否为空
 */
#define isEmptyString(string)  ((string)==nil || [[(string) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]<1)
/**
 * 判断字符串是否不为空
 */
#define notEmptyString(string) (!isEmptyString(string))

/**
 * 将对象转换为字符串
 */
#define objectString(val)  ((val)==nil?@"":[NSString stringWithFormat:@"%@",(val)])

#define intString(val)      [NSString stringWithFormat:@"%d",(val)]
#define floatString(val)    [NSString stringWithFormat:@"%.2f",(val)]
#define longString(val)     [NSString stringWithFormat:@"%ld",(val)]
#define charString(val)     [NSString stringWithFormat:@"%c",(val)]

#endif
