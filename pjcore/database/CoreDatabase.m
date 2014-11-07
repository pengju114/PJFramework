//
//  CoreDatabase.m
//  PJFramework
//
//  Created by 陆振文 on 14-7-29.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "CoreDatabase.h"

@implementation CoreDatabase
@synthesize databaseName;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.databaseName = @"core.db";
    }
    return self;
}

-(NSString *)databasePath{
    return [DocumentPath stringByAppendingPathComponent:self.databaseName];
}


- (void)dealloc
{
    Release(databaseName);
#ifndef ARC
    [super dealloc];
#endif
}


/**
 @method
 @abstract 第一次创建数据库时调用
 */
-(void)onCreateDatabase:(FMDatabase *)db{
    
}

-(void)initialize:(FMDatabase *)db{
    NSArray *sqls = [self createSqls];
    if (![db open]) {
        return;
    }
    for (NSString *sql in sqls) {
        if([db executeUpdate:sql]){
            PJLog(@"\ndatabase: create table success [%@]\n\n",sql);
        }else{
            PJLog(@"\n** database: create table fail [%@]\n\n",sql);
        }
    }
    [db close];
}

/*!
 @abstract 获取创建表的sql语句
 @require implementation
 */
-(NSArray/*NSString*/ *) createSqls{
    return nil;
}

-(FMDatabase *)getFMDatabase{
    //数据库不存在就要初始化
    NSString *path = [self databasePath];
    BOOL needsInit=![[NSFileManager defaultManager] fileExistsAtPath:path];
    FMDatabase *database=[FMDatabase databaseWithPath:path];
    if (database && needsInit) {
        [self initialize:database];
        [self onCreateDatabase:database];
    }
    
    return database;
}


- (BOOL)executeUpdate:(NSString*)sql, ...{
    FMDatabase *db = [self getFMDatabase];
    BOOL ret = NO;
    if ([db open]) {
        
        va_list args;
        va_start(args, sql);
        
        ret = [self executeUpdate:sql withVAList:args];
        
        PJLog(@"\n~ executeUpdate %@ \n\n",sql);
        
        va_end(args);
    }
    [db close];
    return ret;
}

- (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2){
    FMDatabase *db = [self getFMDatabase];
    BOOL ret = NO;
    if ([db open]) {
        
        va_list args;
        va_start(args, format);
        
        NSMutableString *sql      = [NSMutableString stringWithCapacity:[format length]];
        NSMutableArray *arguments = [NSMutableArray array];
        
        [db extractSQL:format argumentsList:args intoString:sql arguments:arguments];
        
        va_end(args);
        
        ret = [db executeUpdate:sql withArgumentsInArray:arguments];
        
        PJLog(@"\n~ executeUpdateWithFormat %@ \n\n",sql);
    }
    [db close];
    return ret;
}

- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments{
    FMDatabase *db = [self getFMDatabase];
    BOOL ret = NO;
    if ([db open]) {
        ret = [db executeUpdate:sql withArgumentsInArray:arguments];
        
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    [db close];
    return ret;
}

- (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments{
    FMDatabase *db = [self getFMDatabase];
    BOOL ret = NO;
    if ([db open]) {
        ret = [db executeUpdate:sql withParameterDictionary:arguments];
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    [db close];
    return ret;
}

- (BOOL)executeUpdate:(NSString*)sql withVAList: (va_list)args{
    FMDatabase *db = [self getFMDatabase];
    BOOL ret = NO;
    if ([db open]) {
        ret = [db executeUpdate:sql withVAList:args];
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    [db close];
    return ret;
}

- (BOOL)executeStatements:(NSString *)sql{
    FMDatabase *db = [self getFMDatabase];
    BOOL ret = NO;
    if ([db open]) {
        ret = [db executeStatements:sql];
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    [db close];
    return ret;
}

- (BOOL)executeStatements:(NSString *)sql withResultBlock:(FMDBExecuteStatementsCallbackBlock)block{
    FMDatabase *db = [self getFMDatabase];
    BOOL ret = NO;
    if ([db open]) {
        ret = [db executeStatements:sql withResultBlock:block];
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    [db close];
    return ret;
}

- (NSArray/*NSDictionary*/ *)executeQuery:(NSString*)sql, ...{
    
    FMDatabase *db = [self getFMDatabase];
    
    NSArray *array = nil;
    
    if ([db open]) {
        va_list args;
        va_start(args, sql);
        
        FMResultSet *set = [db executeQuery:sql withVAList:args];
        
        va_end(args);
        
        if (set) {
            array = [self copyToArrayFromResult:set];
            [set close];
        }
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    
    [db close];
    
    return array;
}

- (NSArray/*NSDictionary*/ *)executeQueryWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2){
    FMDatabase *db = [self getFMDatabase];
    
    NSArray *array = nil;
    
    if ([db open]) {
        va_list args;
        va_start(args, format);
        
        NSMutableString *sql = [NSMutableString stringWithCapacity:[format length]];
        NSMutableArray *arguments = [NSMutableArray array];
        [db extractSQL:format argumentsList:args intoString:sql arguments:arguments];
        
        va_end(args);
        
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:arguments];
        
        if (set) {
            array = [self copyToArrayFromResult:set];
            [set close];
        }
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    
    [db close];
    
    return array;
}

- (NSArray/*NSDictionary*/ *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments{
    FMDatabase *db = [self getFMDatabase];
    
    NSArray *array = nil;
    
    if ([db open]) {
        
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:arguments];
        
        if (set) {
            array = [self copyToArrayFromResult:set];
            [set close];
        }
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    
    [db close];
    
    return array;
}

- (NSArray/*NSDictionary*/ *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments{
    FMDatabase *db = [self getFMDatabase];
    
    NSArray *array = nil;
    
    if ([db open]) {
        
        FMResultSet *set = [db executeQuery:sql withParameterDictionary:arguments];
        
        if (set) {
            array = [self copyToArrayFromResult:set];
            [set close];
        }
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    
    [db close];
    
    return array;
}

- (NSArray/*NSDictionary*/ *)executeQuery:(NSString*)sql withVAList: (va_list)args{
    FMDatabase *db = [self getFMDatabase];
    
    NSArray *array = nil;
    
    if ([db open]) {
        
        FMResultSet *set = [db executeQuery:sql withVAList:args];
        
        if (set) {
            array = [self copyToArrayFromResult:set];
            [set close];
        }
        PJLog(@"\n~ %@ %@ \n\n",NSStringFromSelector(_cmd),sql);
    }
    
    [db close];
    
    return array;
}

-(NSArray *)copyToArrayFromResult:(FMResultSet *)set{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int count = [set columnCount];
    while ([set next]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:count];
        for (int i=0; i<count; i++) {
            [dic setObject:[set objectForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        [array addObject:dic];
        Release(dic);
    }
    return AutoRelease(array);
}

@end
