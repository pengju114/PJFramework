//
//  CoreDatabase.h
//  PJFramework
//
//  Created by 陆振文 on 14-7-29.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface CoreDatabase : NSObject
@property (nonatomic, STRONG) NSString *databaseName;

/**
 @method
 @abstract 第一次创建数据库时调用
 */
-(void)onCreateDatabase:(FMDatabase *)db;
-(NSString *)databasePath;

/*!
 @abstract 获取创建表的sql语句
 @require implementation
 */
-(NSArray/*NSString*/ *) createSqls;




///----------------------
/// @name Perform updates
///----------------------

/** Execute single update statement
 
 This method executes a single SQL update statement (i.e. any SQL that does not return results, such as `UPDATE`, `INSERT`, or `DELETE`. This method employs [`sqlite3_prepare_v2`](http://sqlite.org/c3ref/prepare.html), [`sqlite3_bind`](http://sqlite.org/c3ref/bind_blob.html) to bind values to `?` placeholders in the SQL with the optional list of parameters, and [`sqlite_step`](http://sqlite.org/c3ref/step.html) to perform the update.
 
 The optional values provided to this method should be objects (e.g. `NSString`, `NSNumber`, `NSNull`, `NSDate`, and `NSData` objects), not fundamental data types (e.g. `int`, `long`, `NSInteger`, etc.). This method automatically handles the aforementioned object types, and all other object types will be interpreted as text values using the object's `description` method.
 
 @param sql The SQL to be performed, with optional `?` placeholders.
 
 @param ... Optional parameters to bind to `?` placeholders in the SQL statement. These should be Objective-C objects (e.g. `NSString`, `NSNumber`, etc.), not fundamental C data types (e.g. `int`, `char *`, etc.).
 
 @return `YES` upon success; `NO` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see lastError
 @see lastErrorCode
 @see lastErrorMessage
 @see [`sqlite3_bind`](http://sqlite.org/c3ref/bind_blob.html)
 
 @note This technique supports the use of `?` placeholders in the SQL, automatically binding any supplied value parameters to those placeholders. This approach is more robust than techniques that entail using `stringWithFormat` to manually build SQL statements, which can be problematic if the values happened to include any characters that needed to be quoted.
 */

- (BOOL)executeUpdate:(NSString*)sql, ...;

/** Execute single update statement
 
 This method executes a single SQL update statement (i.e. any SQL that does not return results, such as `UPDATE`, `INSERT`, or `DELETE`. This method employs [`sqlite3_prepare_v2`](http://sqlite.org/c3ref/prepare.html) and [`sqlite_step`](http://sqlite.org/c3ref/step.html) to perform the update. Unlike the other `executeUpdate` methods, this uses printf-style formatters (e.g. `%s`, `%d`, etc.) to build the SQL. Do not use `?` placeholders in the SQL if you use this method.
 
 @param format The SQL to be performed, with `printf`-style escape sequences.
 
 @param ... Optional parameters to bind to use in conjunction with the `printf`-style escape sequences in the SQL statement.
 
 @return `YES` upon success; `NO` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see executeUpdate:
 @see lastError
 @see lastErrorCode
 @see lastErrorMessage
 
 @note This method does not technically perform a traditional printf-style replacement. What this method actually does is replace the printf-style percent sequences with a SQLite `?` placeholder, and then bind values to that placeholder. Thus the following command
 
 [db executeUpdateWithFormat:@"INSERT INTO test (name) VALUES (%@)", @"Gus"];
 
 is actually replacing the `%@` with `?` placeholder, and then performing something equivalent to `<executeUpdate:>`
 
 [db executeUpdate:@"INSERT INTO test (name) VALUES (?)", @"Gus"];
 
 There are two reasons why this distinction is important. First, the printf-style escape sequences can only be used where it is permissible to use a SQLite `?` placeholder. You can use it only for values in SQL statements, but not for table names or column names or any other non-value context. This method also cannot be used in conjunction with `pragma` statements and the like. Second, note the lack of quotation marks in the SQL. The `VALUES` clause was _not_ `VALUES ('%@')` (like you might have to do if you built a SQL statement using `NSString` method `stringWithFormat`), but rather simply `VALUES (%@)`.
 */

- (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/** Execute single update statement
 
 This method executes a single SQL update statement (i.e. any SQL that does not return results, such as `UPDATE`, `INSERT`, or `DELETE`. This method employs [`sqlite3_prepare_v2`](http://sqlite.org/c3ref/prepare.html) and [`sqlite3_bind`](http://sqlite.org/c3ref/bind_blob.html) binding any `?` placeholders in the SQL with the optional list of parameters.
 
 The optional values provided to this method should be objects (e.g. `NSString`, `NSNumber`, `NSNull`, `NSDate`, and `NSData` objects), not fundamental data types (e.g. `int`, `long`, `NSInteger`, etc.). This method automatically handles the aforementioned object types, and all other object types will be interpreted as text values using the object's `description` method.
 
 @param sql The SQL to be performed, with optional `?` placeholders.
 
 @param arguments A `NSArray` of objects to be used when binding values to the `?` placeholders in the SQL statement.
 
 @return `YES` upon success; `NO` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see lastError
 @see lastErrorCode
 @see lastErrorMessage
 */

- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;

/** Execute single update statement
 
 This method executes a single SQL update statement (i.e. any SQL that does not return results, such as `UPDATE`, `INSERT`, or `DELETE`. This method employs [`sqlite3_prepare_v2`](http://sqlite.org/c3ref/prepare.html) and [`sqlite_step`](http://sqlite.org/c3ref/step.html) to perform the update. Unlike the other `executeUpdate` methods, this uses printf-style formatters (e.g. `%s`, `%d`, etc.) to build the SQL.
 
 The optional values provided to this method should be objects (e.g. `NSString`, `NSNumber`, `NSNull`, `NSDate`, and `NSData` objects), not fundamental data types (e.g. `int`, `long`, `NSInteger`, etc.). This method automatically handles the aforementioned object types, and all other object types will be interpreted as text values using the object's `description` method.
 
 @param sql The SQL to be performed, with optional `?` placeholders.
 
 @param arguments A `NSDictionary` of objects keyed by column names that will be used when binding values to the `?` placeholders in the SQL statement.
 
 @return `YES` upon success; `NO` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see lastError
 @see lastErrorCode
 @see lastErrorMessage
 */

- (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;


/** Execute single update statement
 
 This method executes a single SQL update statement (i.e. any SQL that does not return results, such as `UPDATE`, `INSERT`, or `DELETE`. This method employs [`sqlite3_prepare_v2`](http://sqlite.org/c3ref/prepare.html) and [`sqlite_step`](http://sqlite.org/c3ref/step.html) to perform the update. Unlike the other `executeUpdate` methods, this uses printf-style formatters (e.g. `%s`, `%d`, etc.) to build the SQL.
 
 The optional values provided to this method should be objects (e.g. `NSString`, `NSNumber`, `NSNull`, `NSDate`, and `NSData` objects), not fundamental data types (e.g. `int`, `long`, `NSInteger`, etc.). This method automatically handles the aforementioned object types, and all other object types will be interpreted as text values using the object's `description` method.
 
 @param sql The SQL to be performed, with optional `?` placeholders.
 
 @param args A `va_list` of arguments.
 
 @return `YES` upon success; `NO` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see lastError
 @see lastErrorCode
 @see lastErrorMessage
 */

- (BOOL)executeUpdate:(NSString*)sql withVAList: (va_list)args;

/** Execute multiple SQL statements
 
 This executes a series of SQL statements that are combined in a single string (e.g. the SQL generated by the `sqlite3` command line `.dump` command). This accepts no value parameters, but rather simply expects a single string with multiple SQL statements, each terminated with a semicolon. This uses `sqlite3_exec`.
 
 @param  sql  The SQL to be performed
 
 @return      `YES` upon success; `NO` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see executeStatements:withResultBlock:
 @see [sqlite3_exec()](http://sqlite.org/c3ref/exec.html)
 
 */

- (BOOL)executeStatements:(NSString *)sql;

/** Execute multiple SQL statements with callback handler
 
 This executes a series of SQL statements that are combined in a single string (e.g. the SQL generated by the `sqlite3` command line `.dump` command). This accepts no value parameters, but rather simply expects a single string with multiple SQL statements, each terminated with a semicolon. This uses `sqlite3_exec`.
 
 @param sql       The SQL to be performed.
 @param block     A block that will be called for any result sets returned by any SQL statements.
 Note, if you supply this block, it must return integer value, zero upon success (this would be a good opportunity to use SQLITE_OK),
 non-zero value upon failure (which will stop the bulk execution of the SQL).  If a statement returns values, the block will be called with the results from the query in NSDictionary *resultsDictionary.
 This may be `nil` if you don't care to receive any results.
 
 @return          `YES` upon success; `NO` upon failure. If failed, you can call `<lastError>`,
 `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see executeStatements:
 @see [sqlite3_exec()](http://sqlite.org/c3ref/exec.html)
 
 */

- (BOOL)executeStatements:(NSString *)sql withResultBlock:(FMDBExecuteStatementsCallbackBlock)block;



///-------------------------
/// @name Retrieving results
///-------------------------

/** Execute select statement
 
 Executing queries returns an `<FMResultSet>` object if successful, and `nil` upon failure.  Like executing updates, there is a variant that accepts an `NSError **` parameter.  Otherwise you should use the `<lastErrorMessage>` and `<lastErrorMessage>` methods to determine why a query failed.
 
 In order to iterate through the results of your query, you use a `while()` loop.  You also need to "step" (via `<[FMResultSet next]>`) from one record to the other.
 
 This method employs [`sqlite3_bind`](http://sqlite.org/c3ref/bind_blob.html) for any optional value parameters. This  properly escapes any characters that need escape sequences (e.g. quotation marks), which eliminates simple SQL errors as well as protects against SQL injection attacks. This method natively handles `NSString`, `NSNumber`, `NSNull`, `NSDate`, and `NSData` objects. All other object types will be interpreted as text values using the object's `description` method.
 
 @param sql The SELECT statement to be performed, with optional `?` placeholders.
 
 @param ... Optional parameters to bind to `?` placeholders in the SQL statement. These should be Objective-C objects (e.g. `NSString`, `NSNumber`, etc.), not fundamental C data types (e.g. `int`, `char *`, etc.).
 
 @return A `<FMResultSet>` for the result set upon success; `nil` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see FMResultSet
 @see [`FMResultSet next`](<[FMResultSet next]>)
 @see [`sqlite3_bind`](http://sqlite.org/c3ref/bind_blob.html)
 */

- (NSArray/*NSDictionary*/ *)executeQuery:(NSString*)sql, ...;

/** Execute select statement
 
 Executing queries returns an `<FMResultSet>` object if successful, and `nil` upon failure.  Like executing updates, there is a variant that accepts an `NSError **` parameter.  Otherwise you should use the `<lastErrorMessage>` and `<lastErrorMessage>` methods to determine why a query failed.
 
 In order to iterate through the results of your query, you use a `while()` loop.  You also need to "step" (via `<[FMResultSet next]>`) from one record to the other.
 
 @param format The SQL to be performed, with `printf`-style escape sequences.
 
 @param ... Optional parameters to bind to use in conjunction with the `printf`-style escape sequences in the SQL statement.
 
 @return A `<FMResultSet>` for the result set upon success; `nil` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see executeQuery:
 @see FMResultSet
 @see [`FMResultSet next`](<[FMResultSet next]>)
 
 @note This method does not technically perform a traditional printf-style replacement. What this method actually does is replace the printf-style percent sequences with a SQLite `?` placeholder, and then bind values to that placeholder. Thus the following command
 
 [db executeQueryWithFormat:@"SELECT * FROM test WHERE name=%@", @"Gus"];
 
 is actually replacing the `%@` with `?` placeholder, and then performing something equivalent to `<executeQuery:>`
 
 [db executeQuery:@"SELECT * FROM test WHERE name=?", @"Gus"];
 
 There are two reasons why this distinction is important. First, the printf-style escape sequences can only be used where it is permissible to use a SQLite `?` placeholder. You can use it only for values in SQL statements, but not for table names or column names or any other non-value context. This method also cannot be used in conjunction with `pragma` statements and the like. Second, note the lack of quotation marks in the SQL. The `WHERE` clause was _not_ `WHERE name='%@'` (like you might have to do if you built a SQL statement using `NSString` method `stringWithFormat`), but rather simply `WHERE name=%@`.
 
 */

- (NSArray/*NSDictionary*/ *)executeQueryWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);

/** Execute select statement
 
 Executing queries returns an `<FMResultSet>` object if successful, and `nil` upon failure.  Like executing updates, there is a variant that accepts an `NSError **` parameter.  Otherwise you should use the `<lastErrorMessage>` and `<lastErrorMessage>` methods to determine why a query failed.
 
 In order to iterate through the results of your query, you use a `while()` loop.  You also need to "step" (via `<[FMResultSet next]>`) from one record to the other.
 
 @param sql The SELECT statement to be performed, with optional `?` placeholders.
 
 @param arguments A `NSArray` of objects to be used when binding values to the `?` placeholders in the SQL statement.
 
 @return A `<FMResultSet>` for the result set upon success; `nil` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see FMResultSet
 @see [`FMResultSet next`](<[FMResultSet next]>)
 */

- (NSArray/*NSDictionary*/ *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;

/** Execute select statement
 
 Executing queries returns an `<FMResultSet>` object if successful, and `nil` upon failure.  Like executing updates, there is a variant that accepts an `NSError **` parameter.  Otherwise you should use the `<lastErrorMessage>` and `<lastErrorMessage>` methods to determine why a query failed.
 
 In order to iterate through the results of your query, you use a `while()` loop.  You also need to "step" (via `<[FMResultSet next]>`) from one record to the other.
 
 @param sql The SELECT statement to be performed, with optional `?` placeholders.
 
 @param arguments A `NSDictionary` of objects keyed by column names that will be used when binding values to the `?` placeholders in the SQL statement.
 
 @return A `<FMResultSet>` for the result set upon success; `nil` upon failure. If failed, you can call `<lastError>`, `<lastErrorCode>`, or `<lastErrorMessage>` for diagnostic information regarding the failure.
 
 @see FMResultSet
 @see [`FMResultSet next`](<[FMResultSet next]>)
 */

- (NSArray/*NSDictionary*/ *)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary *)arguments;


// Documentation forthcoming.
- (NSArray/*NSDictionary*/ *)executeQuery:(NSString*)sql withVAList: (va_list)args;

@end
