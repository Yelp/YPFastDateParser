//
//  YPFastDateParser.h
//  YPFastDateParser
//
//  Created by Justin Wienckowski on 11/21/13.
//  Copyright (c) 2013 Yelp, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Parses strings into NSDate objects much faster than NSDateFormatter, but only
 supports certain string formats.  Uses SQLite for performance.

 Supports strings in the following formats:
 
 YYYY-MM-DD
 YYYY-MM-DD HH:MM
 YYYY-MM-DD HH:MM:SS
 YYYY-MM-DD HH:MM:SS.SSS
 YYYY-MM-DDTHH:MM
 YYYY-MM-DDTHH:MM:SS
 YYYY-MM-DDTHH:MM:SS.SSS
 HH:MM
 HH:MM:SS
 HH:MM:SS.SSS
 'now' (literal)
 DDDDDDDDDD (Julian day number as a floating point value)
 
 Fractional seconds are optional and may include more than 3 digits, but digits in excess 
 of 3 are ignored by sqlite.
 
 A time zone specifier may be appended to any of the first 10 formats.  Supported time zone
 specifiers are (in descending order of efficiency):
    Z
    +00:00  (hours and minutes offset)
    +00
    +0000   (same as previous without colon; this is slower to parse)
**/
@interface YPFastDateParser : NSObject

// Parses a string into an NSDate object.  Returns nil if the string could not be parsed.
+ (NSDate *)dateFromString:(NSString *)string;

// Singleton instance
+ (instancetype)sharedInstance;

// Instance methods
- (instancetype)init;
- (NSDate *)dateFromString:(NSString *)string;

@end
