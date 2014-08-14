//
//  HttpUtility.m
//  Icon
//
//  Created by PENGJU on 13-9-5.
//  Copyright (c) 2013年 estar. All rights reserved.
//

#import "HttpUtility.h"
#import "XMLElement.h"

#import "core.h"

#define NodeListItem             @"item"


@implementation HttpUtility

+(NSDictionary *)parseXML:(NSData *)data{
    XMLElement *xml = [[XMLElement alloc] initWithXMLData:data];
    NSMutableDictionary *target = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *parent = [[NSMutableDictionary alloc] init];
    [self parseNodeTree:parent toTarget:target node:xml];
    Release(xml);
    Release(parent);
    return AutoRelease(target);
}

+(void) parseNodeTree:(NSMutableDictionary *) parent toTarget:(NSMutableDictionary *)element node:(XMLElement *) node {
    // TODO Auto-generated method stub
    
    
    if ([node type] == kXMLElementNode) {
        
        NSArray *list = [node children];
        
        if (list.count>1) {
            for (int i = 0; i < list.count; i++) {
                XMLElement *n = [list objectAtIndex:i];
                if (n.type==kXMLElementText) {
                    continue;
                }
                
                if (![self isMetaItemAndFetch:n toTarget:element]) {
                    NSMutableDictionary *childWrapper = [[NSMutableDictionary alloc] init];
                    [self parseNodeTree:element toTarget:childWrapper node:n];
                    
                    if ([NodeListItem isEqualToString:n.name]) {
                        [self addChildWrapper:parent child:childWrapper key:node.name];
                    }else {
                        [self addChildWrapper:element child:childWrapper key:n.name];
                    }
                    Release(childWrapper);
                }
            }
        }
    }
}

+(BOOL) isMetaItemAndFetch:(XMLElement *) node toTarget:(NSMutableDictionary *) wrapper{
    if (node.type==kXMLElementNode && [node childrenCount]<1) {
        BOOL isMetaItem = YES;
        if (wrapper) {
            NSString *val = node.text;
            [wrapper setObject:val forKey:node.name];
        }
        return isMetaItem;
    }
    return NO;
}

+(void) addChildWrapper:(NSMutableDictionary *) parent child:(NSMutableDictionary *)child key:(id) key{
    if ([child count]<1) {
        return;
    }
    NSMutableArray *array = [parent objectForKey:key];
    if (array == nil) {
        array = AutoRelease([[NSMutableArray alloc] init]);
        [parent setObject:array forKey:key];
    }
    [array addObject:child];
}

+(NSDictionary *)parseJSON:(NSData *)data{
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
}

@end
