YPFastDateParser
================

An efficient API for parsing string dates, times, and timestamps into NSDate objects.

This API leverages the speed of SQLite's date parsing, resulting in a speed improvement of ~2 orders of magnitude over NSDateFormatter.  In addition, it accomodates some common date formats that SQLite does not directly support.

Based on ideas from (http://vombat.tumblr.com/post/60530544401/date-parsing-performance-on-ios-nsdateformatter-vs)

The API
-------

    NSDate *date = [YPFastDateParser dateFromString:@""];

Date Formats
------------

    yyyy-mm-dd
    yyyy-mm-dd hh:mm
    yyyy-mm-dd hh:mm:ss
    yyyy-mm-dd hh:mm:ss.SSS
    
    yyyy-mm-ddThh:mm          // Note the literal 'T'
    yyyy-mm-ddThh:mm:ss
    yyyy-mm-ddThh:mm:ss.SSS
    
    hh:mm
    hh:mm:ss
    hh:mm:ss.SSS
    
    'now'                     // Literal string
    DDDDDDDDDD                // Julian day number as a float

**Note:** Fractional seconds (.SSS) may contain an arbitrary number of digits.  However, only the first three digits are significant to the result; additional digits are ignored.

Time Zone Specifiers
--------------------

A time zone specifier may be appended to any of the supported date formats.

The following formats are supported natively by SQLite and provide optimal efficiency:

    Z         // GMT
    +00:00    // Hours and minutes offset

The following formats are supported by the API but incur a performance penalty:

    +00       // ~1.8x base speed
    +0000     // ~3x base speed

