//
//  YPFastDateParserTests.m
//  YPFastDateParser
//
//  Created by Justin Wienckowski on 11/21/13.
//  Copyright (c) 2013 Yelp, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YPFastDateParser.h"


@interface YPFastDateParserTests : XCTestCase
@end

@implementation YPFastDateParserTests

- (void)testNilString
{
    XCTAssertNil([YPFastDateParser dateFromString:nil], @"Nil string should return nil");
}

- (void)testBlankString
{
    XCTAssertNil([YPFastDateParser dateFromString:@""], @"Blank string should return nil");
}

- (void)testInvalidStrings
{
    XCTAssertNil([YPFastDateParser dateFromString:@"abc123"], @"Invalid string should return nil");
    XCTAssertNil([YPFastDateParser dateFromString:@"123abc"], @"Invalid string should return nil");
    XCTAssertNil([YPFastDateParser dateFromString:@"01-01-1980"], @"Invalid string should return nil");
    XCTAssertNil([YPFastDateParser dateFromString:@"12h30"], @"Invalid string should return nil");
}

- (void)testFractionalSeconds
{
    // 1351321200 == 2012-10-27 07:00:00 UTC
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00"], @"Fractional seconds are optional");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200.123],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00.123"], @"Fractional seconds are honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200.123],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00.123456"], @"Fractional seconds in excess of 3 are ignored");
}

- (void)testValidStrings
{
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00"], @"Valid string should return date");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00"], @"Valid string should return date");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200.123],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00.123"], @"Valid string should return date");

    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00Z"], @"Valid string should return date");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00Z"], @"Valid string should return date");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200.123],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00.123Z"], @"Valid string should return date");

    
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27T07:00"], @"Valid string should return date");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27T07:00:00"], @"Valid string should return date");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200.123],
                         [YPFastDateParser dateFromString:@"2012-10-27T07:00:00.123"], @"Valid string should return date");

    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27T07:00Z"], @"Valid string should return date");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27T07:00:00Z"], @"Valid string should return date");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200.123],
                         [YPFastDateParser dateFromString:@"2012-10-27T07:00:00.123Z"], @"Valid string should return date");

    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351296000],
                         [YPFastDateParser dateFromString:@"2012-10-27"], @"2012-10-27 converts to 2012-10-27 00:00:00.000");
    
    XCTAssertEqual((double)946722600.0,
                   (double)[[YPFastDateParser dateFromString:@"10:30"] timeIntervalSince1970],
                   @"10:30 converts to 2000-01-01 10:30:00.000");
    XCTAssertEqual((double)946722623.0,
                   (double)[[YPFastDateParser dateFromString:@"10:30:23"] timeIntervalSince1970],
                   @"10:30:23 converts to 2000-01-01 10:30:23.000");
    XCTAssertEqual((double)946722623.543,
                   (double)[[YPFastDateParser dateFromString:@"10:30:23.543"] timeIntervalSince1970],
                   @"10:30:23.543 converts to 2000-01-01 10:30:23.543");

    XCTAssertEqualWithAccuracy((double)[[NSDate date] timeIntervalSince1970],
                               (double)[[YPFastDateParser dateFromString:@"now"] timeIntervalSince1970],
                               0.000999f, @"'now' converts to now with 3 decimal precision");
}

- (void)testTimeZones
{
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00Z"], @"Zulu time zone suffix honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00+00:00"], @"+00:00 time zone specifier honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 08:30:00+01:30"], @"+01:30 time zone specifier honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 04:30:00-02:30"], @"-02:30 time zone specifier honored");
}

- (void)testFixesMalformedTimeZones
{
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00+00"], @"+00 time zone suffix honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 11:00:00+04"], @"+04 time zone suffix honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 00:00:00.000-07"], @"-07 time zone suffix honored");
    
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 09:00:00+0200"], @"+0200 time zone suffix honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 09:34:00+0234"], @"+0234 time zone suffix honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 05:00:00-0200"], @"-0200 time zone suffix honored");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 04:26:00-0234"], @"-0234 time zone suffix honored");
    

    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 05:00:00.000 -02"], @"-02 time zone suffix honored with space");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00.000 +00"], @"+00 time zone suffix honored with space");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200],
                         [YPFastDateParser dateFromString:@"2012-10-27 07:00:00.000 +0000"], @"+0000 time zone suffix honored with space");
    XCTAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1351321200.876],
                         [YPFastDateParser dateFromString:@"2012-10-27 00:00:00.876 -0700"], @"-0700 time zone suffix honored with space");
}

- (void)testPerformance
{
    // Fast case
    NSDate *start = [NSDate date];
    for (int n = 0; n < 50000; n++) {
        [YPFastDateParser dateFromString:@"2012-10-27 07:00:00+00"];
    }
    NSDate *end = [NSDate date];
    NSTimeInterval duration = [end timeIntervalSinceDate:start];
    NSLog(@"Fast case duration: %f", duration);
    XCTAssertTrue(duration < 0.4f, @"Fast case duration %f is too slow!", duration);
    
    // Medium case
    start = [NSDate date];
    for (int n = 0; n < 50000; n++) {
        [YPFastDateParser dateFromString:@"2012-10-27 07:00:00+01"];
    }
    end = [NSDate date];
    duration = [end timeIntervalSinceDate:start];
    NSLog(@"Medium case duration: %f", duration);
    XCTAssertTrue(duration < 0.8f, @"Medium case duration %f too slow!", duration);

    // Slow case
    start = [NSDate date];
    for (int n = 0; n < 50000; n++) {
        [YPFastDateParser dateFromString:@"2012-10-27 07:00:00+0130"];
    }
    end = [NSDate date];
    duration = [end timeIntervalSinceDate:start];
    NSLog(@"Slow case duration: %f", duration);
    XCTAssertTrue(duration < 1.2f, @"Slow case duration %f too slow!", duration);
}

@end
