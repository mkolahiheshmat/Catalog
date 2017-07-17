//
//  SplashViewController.m
//  Catalog
//
//  Created by Developer on 1/25/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "SplashViewController.h"
#import "Header.h"
#import "DocumentDirectoy.h"
#import "ViewController.h"

@interface SplashViewController ()
{
    NSString *splashImageURL;
    UIImageView *logoImageView;
    CGFloat splashImageRatio;
    UIView *backViewForImage;
}
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    backViewForImage = [[UIView alloc] initWithFrame:CGRectMake((screenWidth/2)-100,(screenHeight/2)-100,200,200)];
    backViewForImage.backgroundColor = [UIColor whiteColor];
    backViewForImage.userInteractionEnabled = NO;
    [self.view addSubview:backViewForImage];
    
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstRun"];
    if ([str length] == 0) {
        splashImageRatio = 1.0;
        [self fetchAuthorInfo:[CUSTOMER_AUTHOR_ID integerValue]];
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isFirstRun"];
         logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewForImage.frame.size.width,backViewForImage.frame.size.width)];
        //logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (screenHeight/2)-(((screenWidth-40)*splashImageRatio)/2), screenWidth-40,(screenWidth-40)*splashImageRatio)];
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        logoImageView.image = [UIImage imageNamed:@"nativeSplash"];
        [backViewForImage addSubview: logoImageView];
        [self performSelector:@selector(navigateToLandingPage) withObject:nil afterDelay:3.0];
    }else{
        //        if ([self hasConnectivity]) {
        //
        //            [self fetchAuthorInfo:[CUSTOMER_AUTHOR_ID integerValue]];
        //
        //        }else{
        [self fetchAuthorInfo:[CUSTOMER_AUTHOR_ID integerValue]];
        splashImageRatio = [[[NSUserDefaults standardUserDefaults]objectForKey:@"splashImageRatio"]floatValue];
        NSString *tempName = [[NSUserDefaults standardUserDefaults]objectForKey:@"splashImage"];
        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewForImage.frame.size.width,backViewForImage.frame.size.width)];
        //logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (screenHeight/2)-(((screenWidth-40)*splashImageRatio)/2), screenWidth-40,(screenWidth-40)*splashImageRatio)];
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]];
        [backViewForImage addSubview: logoImageView];
        [self performSelector:@selector(navigateToLandingPage) withObject:nil afterDelay:3.0];
        //        }
    }
}

#pragma mark - custom methods
- (void)getImageWithURL:(NSString *)url{
    NSString *baseUrl1 = @"http://catalog2.yarima.co";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl1, url]];
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
        if (fileData) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                logoImageView.image = [UIImage imageWithData:fileData];
                
                [self saveImageIntoDocumetsWithData:fileData withName:[NSString stringWithFormat:@"%@", fileURL]];
                [self performSelector:@selector(navigateToLandingPage) withObject:nil afterDelay:3.0];
            });
        }else{
            fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl1, url]];
            fileData = [NSData dataWithContentsOfURL:fileURL];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self saveImageIntoDocumetsWithData:fileData withName:[NSString stringWithFormat:@"%@", fileURL]];
            });
        }
    });
}

- (void)saveImageIntoDocumetsWithData:(NSData*)imageData withName:(NSString*)imageName{
    
    NSString *tempName = [imageName lastPathComponent];
    [[NSUserDefaults standardUserDefaults]setObject:tempName forKey:@"splashImage"];
    NSString *imgFileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]stringByAppendingPathComponent:tempName];
    //create the file
    [[NSFileManager defaultManager] createFileAtPath:imgFileName contents:imageData attributes:nil];
    //[self hideHUD];
}
-(void) navigateToLandingPage{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Connection
- (void)fetchAuthorInfo:(NSInteger)authorId {
    //   [noResultLabelPost removeFromSuperview];
    //[ProgressHUD show:@""];
    
    NSDictionary *params = @{
                             //@"author_id":[NSNumber numberWithInteger:self.author_id]
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    
    //NSLog(@"params = %@",params);
    /*http://catalog2.yarima.co/mobiles/catalog_get_author*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_get_author", BaseURL3];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        // [ProgressHUD dismiss];
        NSDictionary *tempDic = [(NSDictionary *)responseObject objectForKey:@"author"];
        if ([[tempDic allKeys]count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        
        splashImageURL = [tempDic objectForKey:@"image"];
        splashImageRatio = [[tempDic objectForKey:@"image_ratio"]floatValue];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:splashImageRatio] forKey:@"splashImageRatio"];
        NSLog(@"splash_Image = %@",splashImageURL);
        NSLog(@"Image_ratio = %f",splashImageRatio);
        //[self getImageWithURL:splashImageURL];
        
        if ([splashImageURL isEqualToString:@""]) {
            logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewForImage.frame.size.width,backViewForImage.frame.size.width)];
            //logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (screenHeight/2)-(((screenWidth-40)*splashImageRatio)/2), screenWidth-40,(screenWidth-40)*splashImageRatio)];
            logoImageView.contentMode = UIViewContentModeScaleAspectFit;
            logoImageView.image = [UIImage imageNamed:@"nativeSplash"];
            [backViewForImage addSubview: logoImageView];
        }else{
            [self getImageWithURL:splashImageURL];
        }
        
        //logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (screenHeight/2)-(((screenWidth-40)*splashImageRatio)/2), screenWidth-40,(screenWidth-40)*splashImageRatio)];
        // logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        // [self.view addSubview: logoImageView];
        
    }failure:^(NSURLSessionTask *operation, NSError *error) {
        // [ProgressHUD dismiss];
        //        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
        //        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //        }];
        //        [alert addAction:action];
        //        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    return NO;
}
@end
