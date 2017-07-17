//
//  CalendarGeneral.m
//  Roghan Motor
//
//  Created by Nina Yousefi on 4/5/16.
//  Copyright © 2016 sina. All rights reserved.
//

#import "PersianDate.h"

@interface PersianDate()

//-(NSString*)ConvertToPersianDate:(NSDate *) GregorianDateTime;
-(NSString*)ConvertToPersianDateFinalWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
@end

@implementation PersianDate


 -(NSString*)ConvertToPersianDate:(NSDate *) GregorianDateTime
 {
 NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
 NSCalendar * persian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
 NSDate * date = GregorianDateTime;
 NSDateComponents * components = [gregorian
 components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
 NSDate * persianDate = [persian dateFromComponents:components];
 NSDateComponents * persiancomponents = [persian
 components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:persianDate];
 NSLog(@"date: %@", date);
 NSLog(@"hebrew: %@", persianDate);
 NSLog(@"hebrew: %@", persiancomponents);
 
 return [NSString stringWithFormat:@"%@", persianDate];//[NSString stringWithFormat:@"%ld-%ld-%ld", (long)persiancomponents.day, (long)persiancomponents.month, (long)persiancomponents.year];
 }
 
 -(NSString*)ConvertToPersianDate2:(NSString*) GeorgianDateTime
 {
 //========>convert date to persian date===========//
 //NSDate *currDate = [NSDate alloc];
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
 // this is imporant - we set our input date format to match our input string
 // if format doesn't match you'll get nil from your string, so be careful];
 [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
 // NSString *dateString = [dateFormatter stringFromDate:GeorgianDateTime];
 
 // [dateFormatter setCalendar:NSPersianCalendar];
 NSDate *dateFromString = [[NSDate alloc] init];
 // voila!
 //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Iran"]];
 [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
 [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
 
 dateFromString = [dateFormatter dateFromString:GeorgianDateTime];
 ////////////Date////////////
 NSCalendar *persianCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
 unsigned units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitYearForWeekOfYear;
 //        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
 //        [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
 NSDateComponents *componentsNow = [persianCalender components:units fromDate:dateFromString];
 
 //NSString *year = [NSString stringWithFormat:@"%ld", (long)[componentsNow year]];
 NSString *month = [NSString stringWithFormat:@"%ld", (long)[componentsNow month]];
 NSString *day = [NSString stringWithFormat:@"%ld", (long)[componentsNow day]];
 
 NSMutableDictionary *monthToPersianMonth = [[NSMutableDictionary alloc] init];
 [monthToPersianMonth setObject:@"1" forKey:@"1"];
 [monthToPersianMonth setObject:@"2" forKey:@"2"];
 [monthToPersianMonth setObject:@"3" forKey:@"3"];
 [monthToPersianMonth setObject:@"4" forKey:@"4"];
 [monthToPersianMonth setObject:@"5"   forKey:@"5"];
 [monthToPersianMonth setObject:@"6" forKey:@"6"];
 [monthToPersianMonth setObject:@"7" forKey:@"7"];
 [monthToPersianMonth setObject:@"8" forKey:@"8"];
 [monthToPersianMonth setObject:@"9" forKey:@"9"];
 [monthToPersianMonth setObject:@"10" forKey:@"10"];
 [monthToPersianMonth setObject:@"11" forKey:@"11"];
 [monthToPersianMonth setObject:@"12" forKey:@"12"];
 
 
 //    [monthToPersianMonth setObject:@"فروردین" forKey:@"1"];
 //    [monthToPersianMonth setObject:@"اردیبهشت" forKey:@"2"];
 //    [monthToPersianMonth setObject:@"خرداد" forKey:@"3"];
 //    [monthToPersianMonth setObject:@"تیر" forKey:@"4"];
 //    [monthToPersianMonth setObject:@"مرداد"   forKey:@"5"];
 //    [monthToPersianMonth setObject:@"شهریور" forKey:@"6"];
 //    [monthToPersianMonth setObject:@"مهر" forKey:@"7"];
 //    [monthToPersianMonth setObject:@"آبان" forKey:@"8"];
 //    [monthToPersianMonth setObject:@"آذر" forKey:@"9"];
 //    [monthToPersianMonth setObject:@"دی" forKey:@"10"];
 //    [monthToPersianMonth setObject:@"بهمن" forKey:@"11"];
 //    [monthToPersianMonth setObject:@"اسفند" forKey:@"12"];
 //
 month= [monthToPersianMonth objectForKey:month];
 
 NSString *PersianDate = [day stringByAppendingFormat:@"%@", month];
 
 return PersianDate;
 //===============================================//
 }
 
 +(NSString*) GetCurrentYear :(NSString*) GeorgianDateTime
 {
 //NSDate *currDate = [NSDate alloc];
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
 [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
 NSDate *dateFromString = [[NSDate alloc] init];
 [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
 [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"Asia/Tehran"]];
 
 dateFromString = [dateFormatter dateFromString:GeorgianDateTime];
 
 NSCalendar *persianCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
 unsigned units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitYearForWeekOfYear;
 NSDateComponents *componentsNow = [persianCalender components:units fromDate:dateFromString];
 
 NSString *currentYear = [NSString stringWithFormat:@"%ld", (long)[componentsNow year]];
 return currentYear;
 }

 +(NSString*)ConvertToPersianDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
 {
 NSDateComponents *gregoriancomps = [[NSDateComponents alloc] init];
 [gregoriancomps setDay:day];
 [gregoriancomps setMonth:month];
 [gregoriancomps setYear:year];
 NSCalendar*       persianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
 NSDate *date = [persianCal dateFromComponents:gregoriancomps];
 
 NSCalendar *gregorian= [[NSCalendar alloc]
 initWithCalendarIdentifier:NSCalendarIdentifierPersian];
 NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth |
 NSCalendarUnitYear;
 NSDateComponents *components = [gregorian components:unitFlags fromDate:date];
 
 
 NSString *yearstr = [NSString stringWithFormat:@"%ld", (long)[components year]];
 NSString *monthstr = [NSString stringWithFormat:@"%ld", (long)[components month]];
 NSString *daystr = [NSString stringWithFormat:@"%ld", (long)[components day]];
 
 NSMutableDictionary *monthToPersianMonth = [[NSMutableDictionary alloc] init];
 
 //// [monthToPersianMonth setObject:@"فروردین" forKey:@"1"];
 //// [monthToPersianMonth setObject:@"اردیبهشت" forKey:@"2"];
 //// [monthToPersianMonth setObject:@"خرداد" forKey:@"3"];
 //// [monthToPersianMonth setObject:@"تیر" forKey:@"4"];
 //// [monthToPersianMonth setObject:@"مرداد"   forKey:@"5"];
 //// [monthToPersianMonth setObject:@"شهریور" forKey:@"6"];
 //// [monthToPersianMonth setObject:@"مهر" forKey:@"7"];
 //// [monthToPersianMonth setObject:@"آبان" forKey:@"8"];
 //// [monthToPersianMonth setObject:@"آذر" forKey:@"9"];
 //// [monthToPersianMonth setObject:@"دی" forKey:@"10"];
 ////[monthToPersianMonth setObject:@"بهمن" forKey:@"11"];
 //// [monthToPersianMonth setObject:@"اسفند" forKey:@"12"];
 
 [monthToPersianMonth setObject:@"۱" forKey:@"1"];
 [monthToPersianMonth setObject:@"۲" forKey:@"2"];
 [monthToPersianMonth setObject:@"۳" forKey:@"3"];
 [monthToPersianMonth setObject:@"۴" forKey:@"4"];
 [monthToPersianMonth setObject:@"۵"   forKey:@"5"];
 [monthToPersianMonth setObject:@"۶" forKey:@"6"];
 [monthToPersianMonth setObject:@"۷" forKey:@"7"];
 [monthToPersianMonth setObject:@"۸" forKey:@"8"];
 [monthToPersianMonth setObject:@"۹" forKey:@"9"];
 [monthToPersianMonth setObject:@"۱۰" forKey:@"10"];
 [monthToPersianMonth setObject:@"۱۱" forKey:@"11"];
 [monthToPersianMonth setObject:@"۱۲" forKey:@"12"];
 
 monthstr = [monthToPersianMonth objectForKey:monthstr];
 NSString *PersianDate = [daystr stringByAppendingFormat:@" %@ %@", monthstr, yearstr];
 return PersianDate;
 }

-(NSString*)ConvertToPersianDateFinalWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day{
    NSDateComponents *gregoriancomps = [[NSDateComponents alloc] init];
    //[gregoriancomps setMinute:minute];
    //[gregoriancomps setHour:hour];
    [gregoriancomps setDay:day];
    [gregoriancomps setMonth:month];
    [gregoriancomps setYear:year];
    NSCalendar *persianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"GMT"];
    
    [persianCal setTimeZone:tz];
    NSDate *date = [persianCal dateFromComponents:gregoriancomps];
    
    NSCalendar *gregorian= [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    NSTimeZone *tz2 = [NSTimeZone timeZoneWithName:@"GMT"];
    
    [persianCal setTimeZone:tz2];
    NSUInteger unitFlags = NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth |
    NSCalendarUnitYear;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:date];
    
    NSString *yearstr = [NSString stringWithFormat:@"%ld", (long)[components year]];
    NSString *monthstr = [NSString stringWithFormat:@"%ld", (long)[components month]];
    NSString *daystr = [NSString stringWithFormat:@"%ld", (long)[components day]];
    NSMutableString *minutestr = [NSMutableString stringWithFormat:@"%ld", (long)[components minute]];
    NSMutableString *hourstr = [NSMutableString stringWithFormat:@"%ld", (long)[components hour]];
    
    NSMutableDictionary *monthToPersianMonth = [[NSMutableDictionary alloc] init];
    /*
     [monthToPersianMonth setObject:@"فروردین" forKey:@"1"];
     [monthToPersianMonth setObject:@"اردیبهشت" forKey:@"2"];
     [monthToPersianMonth setObject:@"خرداد" forKey:@"3"];
     [monthToPersianMonth setObject:@"تیر" forKey:@"4"];
     [monthToPersianMonth setObject:@"مرداد"   forKey:@"5"];
     [monthToPersianMonth setObject:@"شهریور" forKey:@"6"];
     [monthToPersianMonth setObject:@"مهر" forKey:@"7"];
     [monthToPersianMonth setObject:@"آبان" forKey:@"8"];
     [monthToPersianMonth setObject:@"آذر" forKey:@"9"];
     [monthToPersianMonth setObject:@"دی" forKey:@"10"];
     [monthToPersianMonth setObject:@"بهمن" forKey:@"11"];
     [monthToPersianMonth setObject:@"اسفند" forKey:@"12"];
     */
    
    [monthToPersianMonth setObject:@"۱" forKey:@"1"];
    [monthToPersianMonth setObject:@"۲" forKey:@"2"];
    [monthToPersianMonth setObject:@"۳" forKey:@"3"];
    [monthToPersianMonth setObject:@"۴" forKey:@"4"];
    [monthToPersianMonth setObject:@"۵"   forKey:@"5"];
    [monthToPersianMonth setObject:@"۶" forKey:@"6"];
    [monthToPersianMonth setObject:@"۷" forKey:@"7"];
    [monthToPersianMonth setObject:@"۸" forKey:@"8"];
    [monthToPersianMonth setObject:@"۹" forKey:@"9"];
    [monthToPersianMonth setObject:@"۱۰" forKey:@"10"];
    [monthToPersianMonth setObject:@"۱۱" forKey:@"11"];
    [monthToPersianMonth setObject:@"۱۲" forKey:@"12"];
    
    monthstr = [monthToPersianMonth objectForKey:monthstr];
    
    NSInteger hourLen = [hourstr length];
    if (hourLen<2) {
        [hourstr insertString:@"0" atIndex:0];
    }
    NSInteger minuteLen = [minutestr length];
    if (minuteLen<2){
        [minutestr insertString:@"0" atIndex:0];
    }
    NSString *PersianDate = [NSString stringWithFormat:@" %@.%@.%@",yearstr, monthstr, daystr];
    
    return PersianDate;
}

@end
