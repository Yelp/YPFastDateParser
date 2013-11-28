//
//  YPFastDateParser.m
//  YPFastDateParser
//
//  Created by Justin Wienckowski on 11/21/13.
//  Copyright (c) 2013 Yelp, Inc. All rights reserved.
//

#import "YPFastDateParser.h"
#import <sqlite3.h>

static YPFastDateParser *SharedInstance;

@implementation YPFastDateParser {
    sqlite3 *_sqliteDb;
    sqlite3_stmt *_statement;
}

+ (NSDate *)dateFromString:(NSString *)string
{
    return [[self sharedInstance] dateFromString:string];
}

+ (instancetype)sharedInstance
{
    if (!SharedInstance) {
        SharedInstance = [[self alloc] init];
    }
    
    return SharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _sqliteDb = NULL;
        _statement = NULL;
        
        int result = sqlite3_open(":memory:", &_sqliteDb);
        if (result != SQLITE_OK) [self throwSqliteException];
        
        result = sqlite3_prepare_v2(_sqliteDb, "SELECT strftime('%s', ?), strftime('%f', ?);", -1, &_statement, NULL);
        if (result != SQLITE_OK) [self throwSqliteException];
    }
    return self;
}

- (void)throwSqliteException
{
#ifdef DEBUG
    abort();
#endif
    const char *errMsg = sqlite3_errmsg(_sqliteDb);
    @throw [NSException exceptionWithName:@"SMFastDateTimeParserSQLiteFailure"
                                   reason:[NSString stringWithUTF8String:errMsg]
                                 userInfo:nil];
}

- (void)dealloc
{
    sqlite3_finalize(_statement);
    _statement = NULL;
    
    sqlite3_close(_sqliteDb);
    _sqliteDb = NULL;
}

- (NSDate *)dateFromString:(NSString *)string
{
    return [self dateFromString:string timeZoneAdjusted:NO];
}

- (NSDate *)dateFromString:(NSString *)string timeZoneAdjusted:(BOOL)adjusted
{
    NSAssert(_sqliteDb != NULL, @"SQLite db connection is not initialized!");
    if (!string.length) return nil;
    
    // Time zone format common case
    if ([string hasSuffix:@"+00"])
        string = [string stringByReplacingCharactersInRange:NSMakeRange(string.length - 3, 3) withString:@"Z"];
    
    int result;
    
    result = sqlite3_reset(_statement);
    if (result != SQLITE_OK) [self throwSqliteException];
    
    result = sqlite3_clear_bindings(_statement);
    if (result != SQLITE_OK) [self throwSqliteException];
    
    result = sqlite3_bind_text(_statement, 1, [string UTF8String], -1, SQLITE_STATIC);
    if (result != SQLITE_OK) [self throwSqliteException];
    
    result = sqlite3_bind_text(_statement, 2, [string UTF8String], -1, SQLITE_STATIC);
    if (result != SQLITE_OK) [self throwSqliteException];
    
    result = sqlite3_step(_statement);
    if (result != SQLITE_ROW) [self throwSqliteException];
    
    if (sqlite3_column_type(_statement, 0) == SQLITE_NULL) {
        if (adjusted) {
            return nil;
        } else {
            NSString *fixedString = [[self class] fixTimeZoneSpecifier:string];
            return [self dateFromString:fixedString timeZoneAdjusted:YES];
        }
    }
    
    sqlite3_int64 interval = sqlite3_column_int64(_statement, 0);
    double seconds = sqlite3_column_double(_statement, 1);
    
    // Extract the fraction component of the seconds
    double sintegral;
    double sfraction = modf(seconds, &sintegral);
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(double)interval + sfraction];
    
    return date;
}

// Attempts to convert other time zone specifier formats to SQLite-compatible format
+ (NSString *)fixTimeZoneSpecifier:(NSString *)string
{
    static NSRegularExpression *TwoDigitOffset;
    static NSRegularExpression *FourDigitOffset;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        
        TwoDigitOffset = [NSRegularExpression regularExpressionWithPattern:@"[\\+\\-][0-9]{2}"
                                                                   options:0 error:&error];
        if (!TwoDigitOffset) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:error.localizedDescription
                                         userInfo:@{@"error": error}];
        }

        FourDigitOffset = [NSRegularExpression regularExpressionWithPattern:@"([\\+\\-][0-9]{2})([0-9]{2})"
                                                                    options:0 error:&error];
        if (!FourDigitOffset) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:error.localizedDescription
                                         userInfo:@{@"error": error}];
        }
    });
    
    NSTextCheckingResult *match;
    NSString *testStr = [string substringWithRange:NSMakeRange(string.length - 3, 3)];
    
    if ((match = [TwoDigitOffset firstMatchInString:testStr options:0 range:(NSRange){0,3}])) {
        return [string stringByAppendingString:@":00"];
    }
    
    testStr = [string substringWithRange:NSMakeRange(string.length - 5, 5)];
    
    if ((match = [FourDigitOffset firstMatchInString:testStr options:0 range:(NSRange){0, 5}])) {
        NSString *hrPart = [testStr substringWithRange:[match rangeAtIndex:1]];
        NSString *minPart = [testStr substringWithRange:[match rangeAtIndex:2]];
        NSString *newTZSpecifier = [NSString stringWithFormat:@"%@:%@", hrPart, minPart];
        
        return [string stringByReplacingCharactersInRange:NSMakeRange(string.length - 5, 5) withString:newTZSpecifier];
    }
    
    return string;
}

@end
