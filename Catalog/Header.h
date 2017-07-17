//
//  Header.h
//  MSN
//
//  Created by Yarima on 4/12/16.
//  Copyright © 2016 Arash. All rights reserved.
//

//view.transform = CGAffineTransformMakeScale(-1.0, 1.0);

#import <sys/socket.h>
#import <netinet/in.h>
#import "Database.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+AFNetworking.h>
#import "NSDictionary+LandingPageTableView.h"
#import "NSDictionary+LandingPage.h"
#import "ProgressHUD.h"

#ifndef Header_h
#define Header_h
//client_id: 1
//client_secret: kce0FrFNCGwa2XGBdMWyMpCbXwX9ejgmfXtXWnMy

//#define BaseURL @"http://medicalsn.com/"
#define BaseURL2 @"http://catalog2.yarima.co/"
#define BaseURL3 @"http://catalog2.yarima.co/mobiles/"
#define BaseURL4 @"http://catalog2.yarima.co"
#define FONT_LIGHT(s) [UIFont fontWithName:@"B Yekan" size:s]
#define FONT_MEDIUM(s) [UIFont fontWithName:@"B Yekan" size:s]
#define FONT_ULTRALIGHT(s) [UIFont fontWithName:@"B Yekan" size:s]
#define FONT_NORMAL(s) [UIFont fontWithName:@"B Yekan" size:s]
#define FONT_BOLD(s) [UIFont fontWithName:@"B Yekan" size:s]

#define YARIMA_AUTHOR_ID @"1"
#pragma mark - Change Author_ID 
#define CUSTOMER_AUTHOR_ID @"1"
#define App_Name @"یاریما"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and       iPod touch style UI

#define IS_IPHONE_5_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0f)

#define IS_IPHONE_5_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 568.0f)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 568.0f)

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define screenWidth  [[UIScreen mainScreen]bounds].size.width
#define screenHeight [[UIScreen mainScreen]bounds].size.height

#define MAIN_COLOR [UIColor colorWithRed:62/255.0 green:190/255.0 blue:240/255.0 alpha:1.0]
#define COLOR_1 [UIColor colorWithRed:0.102 green:0.722 blue:0.706 alpha:1.0]
#define COLOR_2 [UIColor colorWithRed:0.05 green:0.422 blue:0.406 alpha:1.0]
#define COLOR_3 [UIColor colorWithRed:0.321 green:0.6 blue:0.874 alpha:1.0]
#define COLOR_4 [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.1]
#define COLOR_5 [UIColor colorWithRed:0.294 green:0.682 blue:0.972 alpha:1.0]
#define TABBAR_SELECTED [UIColor colorWithRed:164/255.0 green:206/255.0 blue:236/255.0 alpha:1.0]
#define TABBAR [UIColor colorWithRed:98/255.0 green:171/255.0 blue:230/255.0 alpha:1.0]
#define WHITE_COLOR [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
#define GREEN_COLOR [UIColor colorWithRed:129/255.0 green:182/255.0 blue:73/255.0 alpha:1.0]
#define GRAY_COLOR [UIColor grayColor]
#define GRADIENT_COLOR_1 [UIColor colorWithRed:73/255.0 green:191/255.0 blue:203/255.0 alpha:1.0]
#define GRADIENT_COLOR_2 [UIColor colorWithRed:96/255.0 green:147/255.0 blue:220/255.0 alpha:1.0]

#define UDID  [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#endif /* Header_h */
