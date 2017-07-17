//
//  ConvertHexToColor.h
//  Catalog
//
//  Created by Developer on 4/22/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ConvertHexToColor : NSObject
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
@end
