//
//  calendarGeneral.h
//  HealthCloud
//
//  Created by Aref Abedjooy on 11/10/15.
//  Copyright (c) 2015 Yarima. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersianDate : NSObject

//-(NSString*)ConvertToPersianDate:(NSDate *) GregorianDateTime;
-(NSString*)ConvertToPersianDateFinalWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;


@end
