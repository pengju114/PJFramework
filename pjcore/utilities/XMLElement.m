//
//  XMLElement.m
//  xml
//
//  Created by 陆振文 on 14-7-9.
//  Copyright (c) 2014年 excelsecu. All rights reserved.
//

#import "XMLElement.h"

#define XMLLog PJLog


/**
 * 保证string不为nil,为nil则返回空字符串
 */
#define str(string)     ((string)==nil?@"":(string))
/**
 * 去除字符串两端空格
 */
#define trim(string)    ((string)==nil?@"":([(string) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]))


@interface XMLElement () <NSXMLParserDelegate>{
    XMLElement          *parent;
    
    NSMutableDictionary *childElements;// elementName -> list<XMLElement>
    NSMutableDictionary *attributes;
}

@property (nonatomic,STRONG) XMLElement     *parent;
@property(nonatomic,STRONG)  NSMutableDictionary *childElements;
@property(nonatomic,STRONG)  NSMutableArray      *sortedChildElements;
@property(nonatomic,STRONG)  NSMutableDictionary *attributes;


@property(nonatomic,STRONG)  NSMutableArray *stack;

@end

@implementation XMLElement

@synthesize type;
@synthesize text;
@synthesize name;
@synthesize parent;
@synthesize childElements;
@synthesize attributes;
@synthesize sortedChildElements;

@synthesize stack;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = kXMLElementNode;
        self.text = @"";
        self.name = @"";
        
        NSMutableDictionary *cd = [[NSMutableDictionary alloc] init];
        self.childElements = cd;
        Release(cd);
        
        NSMutableArray *sortedChildren = [[NSMutableArray alloc] init];
        self.sortedChildElements = sortedChildren;
        Release(sortedChildren);
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        self.attributes = dic;
        Release(dic);
        
        self.stack = nil;
    }
    return self;
}

- (void)dealloc
{
    Release(text);
    Release(childElements);
    Release(attributes);
    Release(stack);
    Release(sortedChildElements);
#ifndef ARC
    [super dealloc];
#endif
}


-(id) initWithFile:(NSString *)path{
    if (self = [self init]) {
        
        [self parseXMLFile:path];
    }
    return self;
}

-(id) initWithStream:(NSInputStream *)stream{
    if (self = [self init]) {
        [self parseStream:stream];
    }
    return self;
}

-(id) initWithXMLData:(NSData *)data{
    if (self = [self init]) {
        [self parseXMLData:data];
    }
    return self;
}

-(void) parseXMLFile:(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        XMLLog(@"xml file not found at %@",path);
    }else{
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        [self parseXMLData:data];
    }
}

-(void) parseXMLData:(NSData *)data{
    if (!data) {
        XMLLog(@"empty xml data");
    }else{
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        id<NSXMLParserDelegate> delegate = self;
        parser.delegate = delegate;
        
        BOOL ret = [parser parse];
        if (!ret) {
            XMLLog(@"parsing config file error :%@",[[parser parserError] description]);
        }
        
        Release(parser);
    }
}

-(void) parseStream:(NSInputStream *)stream{
    if (!stream) {
        XMLLog(@"xml stream empty");
    }else{
        NSXMLParser *parser = [[NSXMLParser alloc] initWithStream:stream];
        id<NSXMLParserDelegate> delegate = self;
        parser.delegate = delegate;
        
        BOOL ret = [parser parse];
        if (!ret) {
            XMLLog(@"parsing config file error :%@",[[parser parserError] description]);
        }
        
        Release(parser);
    }
}


#pragma mark instance methods
-(NSString *)attributeForKey:(NSString *)key{
    return [attributes objectForKey:key];
}
-(NSArray  *)attributeKeys{
    return attributes.allKeys;
}
-(void)setAttribute:(NSString *)value forKey:(NSString *)key{
    [attributes setObject:str(value) forKey:key];
}
-(NSString *)removeAttributeForKey:(NSString *)key{
    NSString *tmp = AutoRelease([attributes objectForKey:key]);
    [attributes removeObjectForKey:key];
    return tmp;
}

-(NSArray * /*XMLElement*/ ) children{
    
    return sortedChildElements;
}
-(NSUInteger) childrenCount{
    return sortedChildElements.count;
}
-(NSArray * /*XMLElement*/ ) childrenForName:(NSString *)elementName{
    return [childElements objectForKey:elementName];
}

-(XMLElement *) childForName:(NSString *)elementName{
    NSArray *list = [self childrenForName:elementName];
    return list.count>0?[list objectAtIndex:0]:nil;
}

-(XMLElement *) childAt:(NSUInteger)index{
    if (index<sortedChildElements.count) {
        return [sortedChildElements objectAtIndex:index];
    }
    return nil;
}

-(void) addChildElement:(XMLElement *)child{
    if (child) {
        NSMutableArray *list = [childElements objectForKey:child.name];
        if (!list) {
            list = AutoRelease([[NSMutableArray alloc] init]);
            [childElements setObject:list forKey:child.name];
        }
        
        child.parent = self;
        [list addObject:child];
        [sortedChildElements addObject:child];
    }
}

-(NSArray *) removeChildrenForName:(NSString *)elementName{
    NSArray *array = AutoRelease([childElements objectForKey:elementName]);
    [childElements removeObjectForKey:elementName];
    [sortedChildElements removeObjectsInArray:array];
    
    if (array) {
        for (XMLElement *elem in array) {
            elem.parent = nil;
        }
    }
    return array;
}

-(void) removeChild:(XMLElement *)element{
    for (NSMutableArray *array in childElements.allValues) {
        [array removeObject:element];
    }
    [sortedChildElements removeObject:element];
    
    if (element) {
        element.parent = nil;
    }
}

-(void) each:(XMLElementIterator) iterator{
    if (iterator) {
        [self each:self iterator:iterator level:0];
    }
}

-(void) each:(XMLElement *)root iterator:(XMLElementIterator) iterator level:(int)level{
    for (int k = 0; k<root.sortedChildElements.count; k++) {
        XMLElement *e = [root.sortedChildElements objectAtIndex:k];
        // invoke handler
        if(!iterator(e,level)){
            return;
        }
        
        [self each:e iterator:iterator level:level+1];
    }
}

#pragma mark NSXMLParser delegate methods

// Document handling methods
// sent when the parser begins parsing of the document.
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    [childElements removeAllObjects];
    [attributes removeAllObjects];
    [sortedChildElements removeAllObjects];
    
    self.name = @"";
    self.text = @"";
    
    NSMutableArray *stk = [[NSMutableArray alloc] init];
    self.stack = stk;
    Release(stk);
    
    [self.stack addObject:self];
}

// sent when the parser has completed parsing. If this is encountered, the parse was successful.
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    XMLLog(@"parserDidEndDocument");
    XMLElement *root = [self.stack lastObject];
    if (root) {
        [self copyFrom:[[root children] lastObject]];
        
        self.parent = nil;
    }
    self.stack = nil;
}

-(void) copyFrom:(XMLElement *)other{
    self.name = other.name;
    self.text = other.text;
    self.type = other.type;
    self.childElements = other.childElements;
    self.attributes = other.attributes;
    self.parent = other.parent;
    self.sortedChildElements = other.sortedChildElements;
}


// sent when the parser finds an element start tag.
// In the case of the cvslog tag, the following is what the delegate receives:
//   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
// In the case of the radar tag, the following is what's passed in:
//    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    XMLElement *elem = AutoRelease([[XMLElement alloc] init]);
    
    elem.name = elementName;
    [elem.attributes addEntriesFromDictionary:attributeDict];
    XMLElement *p = [self.stack lastObject];
    
    [p addChildElement:elem];
    
    [self.stack addObject:elem];
}


// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if (self.stack.count>0) {
        [self.stack removeLastObject];
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    XMLElement *elem = [self.stack lastObject];
    if (elem) {
        NSString *str = [NSString stringWithFormat:@"%@%@",str(elem.text),string];
        elem.text = trim(str);
    }
}


#pragma mark to string methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %@>...has %u child(ren)...</%@>",name,[self attributeString],[self childrenCount],name];
}

-(NSString *)attributeString{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:10*attributes.count];
    
    for (id k in attributes.allKeys) {
        [str appendFormat:@"%@=\"%@\" ",k,[attributes objectForKey:k]];
    }
    
    if (attributes.count>0) {
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    }
    
    return AutoRelease(str);
}

-(NSString *) XMLString:(XMLElement *)elem level:(int)level{
    NSMutableString *buffer = AutoRelease([[NSMutableString alloc] init]);
    
    [buffer appendString:@"\n"];
    [self addGap:buffer count:level];
    [buffer appendFormat:@"<%@",elem.name];
    
    if (elem.attributes.count>0) {
        [buffer appendFormat:@" %@",[elem attributeString]];
    }
    
    if (elem.sortedChildElements.count>0) {
        [buffer appendString:@">"];
        
        for (int k = 0; k<elem.sortedChildElements.count; k++) {
            XMLElement *e = [elem.sortedChildElements objectAtIndex:k];
            // invoke handler
            [buffer appendString:[self XMLString:e level:level+1]];
        }
        
        [self addGap:buffer count:level];
        [buffer appendFormat:@"</%@>\n",elem.name];
        
    }else if(elem.text.length>0){
        [buffer appendString:@">\n"];
        [self addGap:buffer count:level+1];
        [buffer appendFormat:@"%@\n",elem.text];
        
        [self addGap:buffer count:level];
        [buffer appendFormat:@"</%@>\n",elem.name];
    }else{
        [buffer appendFormat:@" />\n"];
    }
    return buffer;
}

-(void) addGap:(NSMutableString *)buffer count:(int)count{
    for (int i=0; i<count; i++) {
        [buffer appendString:@"\t"];
    }
}

-(NSString *)toXMLString{
    return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>%@",[self XMLString:self level:0]];
}

@end


