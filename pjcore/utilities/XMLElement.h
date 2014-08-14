//
//  XMLElement.h
//  xml
//
//  Created by 陆振文 on 14-7-9.
//  Copyright (c) 2014年 excelsecu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "core.h"

// 暂时不使用
typedef enum XMLElementType{
    kXMLElementNode,
    kXMLElementText
}XMLElementType;

@class XMLElement;

/*!
 元素遍历器
 遍历整个DOM树，直到返回NO停止
 */
typedef BOOL (^XMLElementIterator) (XMLElement *element,int level) ;

@interface XMLElement : NSObject
@property (nonatomic,assign) XMLElementType type;
@property (nonatomic,copy) NSString       *text;
@property (nonatomic,copy) NSString       *name;
@property (nonatomic,STRONG, readonly) XMLElement     *parent;

-(id) initWithXMLData:(NSData *) data;
-(id) initWithFile:(NSString *)  path;
-(id) initWithStream:(NSInputStream *)  stream;

-(NSString *)attributeForKey:(NSString *)key;
-(NSArray  *)attributeKeys;
-(void)setAttribute:(NSString *)value forKey:(NSString *)key;
-(NSString *)removeAttributeForKey:(NSString *)key;


-(NSArray * /*XMLElement*/ ) children;
-(NSUInteger) childrenCount;
/*!
 @abstract 根据节点名获取子节点列表
 */
-(NSArray * /*XMLElement*/ ) childrenForName:(NSString *)elementName;
/*!
 @abstract 根据节点名获取一个子节点（即使有多个）
 */
-(XMLElement *) childForName:(NSString *)elementName;
-(XMLElement *) childAt:(NSUInteger)index;
-(void) addChildElement:(XMLElement *)child;
-(NSArray *) removeChildrenForName:(NSString *)elementName;
-(void) removeChild:(XMLElement *)element;

-(void) each:(XMLElementIterator) iterator;
-(NSString *)toXMLString;


@end

