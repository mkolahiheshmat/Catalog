//
//  AppDelegate.m
//  Catalog
//
//  Created by Developer on 1/18/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "AppDelegate.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    #pragma mark - Comment this Line if Push is not needed
    [self registerForRemoteNotification];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"firstLaunch"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"firstLaunch"];
}

#pragma mark - Remote Notification Delegate // <= iOS 9.x

#pragma mark - Comment up to end of appDelegate(Line before @End) if Push is not needed
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
////    NSString *strDevicetoken = [[NSString alloc]initWithFormat:@"%@",[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
////    NSLog(@"Device Token = %@",strDevicetoken);
////    self.strDeviceToken = strDevicetoken;
////    [[NSUserDefaults standardUserDefaults]setObject:strDevicetoken forKey:@"deviceToken"];
//
//        const void *devTokenBytes = [devToken bytes];
//        NSLog(@"%@", devToken);
//        NSString *processedDeviceTokenString = [[[[devToken description]
//                                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
//                                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
//                                                stringByReplacingOccurrencesOfString: @" " withString: @""];
//        [[NSUserDefaults standardUserDefaults]setObject:processedDeviceTokenString forKey:@"deviceToken"];
//        //[[NSNotificationCenter defaultCenter]postNotificationName:@"registerDeviceTokenOnServer" object:nil];
//}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    //const void *devTokenBytes = [devToken bytes];
    //NSLog(@"%@", devToken);
    NSString *processedDeviceTokenString = [[[[devToken description]
                                              stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                             stringByReplacingOccurrencesOfString: @">" withString: @""]
                                            stringByReplacingOccurrencesOfString: @" " withString: @""];
    [[NSUserDefaults standardUserDefaults]setObject:processedDeviceTokenString forKey:@"deviceToken"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"registerDeviceTokenOnServer" object:nil];
    
    NSLog(@"%@", devToken);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Push Notification Information : %@",userInfo);
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"NavigateToInbox" object:nil];
    switch (application.applicationState) {
        case UIApplicationStateActive:
            //app is currently active, can update badges count here
            break;
        case UIApplicationStateInactive:
            //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NavigateToInbox" object:nil];
            break;
        case UIApplicationStateBackground:
            //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
            [[NSNotificationCenter defaultCenter]postNotificationName:@"NavigateToInbox" object:nil];
            break;
        default:
            break;
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSLog(@"User Info = %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"User Info = %@",response.notification.request.content.userInfo);
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"NavigateToInbox" object:nil];
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

#pragma mark - Class Methods

/**
 Notification Registration
 */
- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }else{
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}
@end
