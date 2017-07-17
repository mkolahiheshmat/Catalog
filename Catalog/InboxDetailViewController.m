//
//  InboxDetailViewController.m
//  Catalog
//
//  Created by Developer on 1/29/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "InboxDetailViewController.h"
#import "Header.h"
#import "ImageViewController.h"
#import "ImageResizer.h"
#import "AboutusViewController.h"
#import "AuthorViewController.h"
#import "DocumentDirectoy.h"
#import "VideoPlayerViewController.h"
#import "ConvertHexToColor.h"
@interface InboxDetailViewController ()
{
    UITableView *tableView;
    UIView *bgViewForListAllType;
    UIImageView *imageViewListMaker;
    UIActivityIndicatorView *activityIndicator;
    NSMutableDictionary *detailDictionary;
    UIScrollView *scrollView;
    NSInteger author_id;
    
}@end

@implementation InboxDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [self makeTopBar];
    
    if ([self hasConnectivity]) {
        [self fetchMessageDetailWithId:self.message_id];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - custom methods

-(void) makeTopBar{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,64)];
    
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        topView.backgroundColor = color;
    } else {
        topView.backgroundColor = MAIN_COLOR;
    }
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 17, 40, 40)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UIImage *buttonImageNormal = [UIImage imageNamed:@"backButton.png"];
    [backButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = [self message_Title];
    titleLabel.font = FONT_MEDIUM(20);
    titleLabel.numberOfLines = 1;
    titleLabel.baselineAdjustment = YES;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.clipsToBounds = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    UIFont *myFont = FONT_MEDIUM(15);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        myFont = FONT_NORMAL(15);
    }
    if (IS_IPAD) {
        myFont = FONT_NORMAL(22);
    }
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineSpacing:11];
    paragraph.alignment = NSTextAlignmentJustified;
    paragraph.baseWritingDirection = NSWritingDirectionRightToLeft;
    paragraph.firstLineHeadIndent = 1.0;
    NSDictionary* attributes = @{
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSParagraphStyleAttributeName: paragraph,
                                 NSFontAttributeName:FONT_NORMAL(15)
                                 };
    NSString* txt = labelText;
    NSAttributedString* aString = [[NSAttributedString alloc] initWithString: txt attributes: attributes];
    CGSize sizeOfText = [aString boundingRectWithSize:CGSizeMake( screenWidth - 40,CGFLOAT_MAX)
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              context:nil].size;
    
    CGFloat height = sizeOfText.height;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        height = sizeOfText.height + 10;
    return height;
}

- (void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)makeScrollView{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, screenWidth,screenHeight - 65)];
    scrollView.showsVerticalScrollIndicator=YES;
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(0, 700)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:scrollView];
    
    UIImageView *productImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth,screenWidth*0.6)];
    
    NSString *tempName = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuImage"];
    [productImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL2, [[[detailDictionary objectForKey:@"data"]objectForKey:@"feeds"]objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]]];
    
    productImageView.userInteractionEnabled = YES;
    [scrollView addSubview: productImageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,productImageView.frame.origin.y+productImageView.frame.size.height+15 , screenWidth-40, 25)];
    titleLabel.text = [[[detailDictionary objectForKey:@"data"]objectForKey:@"feeds"]objectForKey:@"title"];
    titleLabel.font = FONT_NORMAL(20);
    titleLabel.numberOfLines = 1;
    titleLabel.baselineAdjustment = YES;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.clipsToBounds = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:titleLabel];
    
    UIView *horizontalLine1 = [[UIView alloc] initWithFrame:CGRectMake(50,titleLabel.frame.origin.y+titleLabel.frame.size.height+20,screenWidth-100,0.7)];
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        horizontalLine1.backgroundColor = color;
    } else {
        horizontalLine1.backgroundColor = MAIN_COLOR;
    }
    horizontalLine1.userInteractionEnabled = NO;
    [scrollView addSubview:horizontalLine1];
    
    UIImageView *authorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-70,titleLabel.frame.origin.y+titleLabel.frame.size.height+30, 40,40)];
    [authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2,[[[[[detailDictionary objectForKey:@"data"]objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"author_photo"]]] placeholderImage:[UIImage imageNamed:@"logo"]];
    authorImageView.contentMode = UIViewContentModeScaleAspectFit;
    authorImageView.userInteractionEnabled = YES;
    authorImageView.layer.cornerRadius = 40 / 2;
    authorImageView.clipsToBounds = YES;
    [scrollView addSubview: authorImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    authorImageView.userInteractionEnabled = YES;
    [authorImageView addGestureRecognizer:tap];
    
    UILabel *logoDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,titleLabel.frame.origin.y+titleLabel.frame.size.height+40 , screenWidth-80, 25)];
    logoDescLabel.text = [NSString stringWithFormat:@"%@ %@", [[[[[detailDictionary objectForKey:@"data"]objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"firstname"],[[[[[detailDictionary objectForKey:@"data"]objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"lastname"]];
    logoDescLabel.font = FONT_NORMAL(12);
    logoDescLabel.numberOfLines = 2;
    logoDescLabel.baselineAdjustment = YES;
    logoDescLabel.adjustsFontSizeToFitWidth = YES;
    logoDescLabel.minimumScaleFactor = 0.5;
    logoDescLabel.clipsToBounds = YES;
    logoDescLabel.backgroundColor = [UIColor clearColor];
    logoDescLabel.textColor = [UIColor blackColor];
    logoDescLabel.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:logoDescLabel];
    
    UILabel *jobTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,titleLabel.frame.origin.y+titleLabel.frame.size.height+55 , screenWidth-80, 25)];
    jobTitleLabel.text = [NSString stringWithFormat:@"%@",[[[[[detailDictionary objectForKey:@"data"]objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"job_title"]];
    jobTitleLabel.font = FONT_NORMAL(10);
    jobTitleLabel.numberOfLines = 2;
    jobTitleLabel.baselineAdjustment = YES;
    jobTitleLabel.adjustsFontSizeToFitWidth = YES;
    jobTitleLabel.minimumScaleFactor = 0.5;
    jobTitleLabel.clipsToBounds = YES;
    jobTitleLabel.backgroundColor = [UIColor clearColor];
    jobTitleLabel.textColor = [UIColor blackColor];
    jobTitleLabel.textAlignment = NSTextAlignmentRight;
    //[scrollView addSubview:jobTitleLabel];
    
    UIView *horizontalLine2 = [[UIView alloc] initWithFrame:CGRectMake(0,jobTitleLabel.frame.origin.y+jobTitleLabel.frame.size.height,screenWidth,0.7)];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        horizontalLine2.backgroundColor = color;
    } else {
        horizontalLine2.backgroundColor = MAIN_COLOR;
    }

    horizontalLine2.userInteractionEnabled = NO;
    [scrollView addSubview:horizontalLine2];
    
    [self makeListForAllMessageDetailsWithYposition:horizontalLine2.frame.origin.y + horizontalLine2.frame.size.height + 5 arrayElements:[[detailDictionary objectForKey:@"data"]objectForKey:@"fullDescription"]];
    
    author_id = [[[[[[detailDictionary objectForKey:@"data"]objectForKey:@"feeds"]objectForKey:@"author"] objectAtIndex:0]objectForKey:@"profile_id"]integerValue];
    NSLog(@"author_id = %ld",(long)author_id);
}

- (void)makeListForAllMessageDetailsWithYposition:(CGFloat)yPos arrayElements:(NSArray *)array{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat yPosition = yPos;
        [bgViewForListAllType removeFromSuperview];
        bgViewForListAllType = [[UIView alloc]initWithFrame:CGRectMake(0, yPosition, screenWidth, 300)];
        [scrollView addSubview:bgViewForListAllType];
        
        CGFloat ypositionOfRow = 5;
        
        for (int i = 0; i < [array count]; i++) {
            NSString *answerStr = [[array objectAtIndex:i]objectForKey:@"media"];
            NSString *screenshotStr = [[array objectAtIndex:i]objectForKey:@"screenshot"];
            //imageView
            if (([answerStr containsString:@".jpg"]) || ([answerStr containsString:@".png"])) {
                
                UIImageView *placeholderImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-25,ypositionOfRow + 10,50,50 )];
                placeholderImage.image = [UIImage imageNamed:@"placeholder"];
                placeholderImage.contentMode = UIViewContentModeScaleAspectFit;
                placeholderImage.clipsToBounds = YES;
                [bgViewForListAllType addSubview: placeholderImage];
                
                CGFloat ratio = [[[array objectAtIndex:i]objectForKey:@"media_ratio"]floatValue];
                imageViewListMaker = [[UIImageView alloc]initWithFrame:CGRectMake(10, ypositionOfRow + 10, screenWidth - 20, screenWidth / ratio)];
                imageViewListMaker.userInteractionEnabled = YES;
                imageViewListMaker.tag = i;
                UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
                [imageViewListMaker addGestureRecognizer:imageViewTap];
                [imageViewListMaker setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2, answerStr]] placeholderImage:[UIImage imageNamed:@"placeholder_"]];
                [bgViewForListAllType addSubview:imageViewListMaker];
                ypositionOfRow = imageViewListMaker.frame.origin.y + imageViewListMaker.frame.size.height + 20;
                
                //video
            }else if ([answerStr containsString:@"mp4"]) {
                CGFloat ratio = [[[array objectAtIndex:i]objectForKey:@"media_ratio"]floatValue];
                UIImageView *placeholderImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-25,ypositionOfRow + 10,50,50 )];
                placeholderImage.image = [UIImage imageNamed:@"placeholder"];
                placeholderImage.contentMode = UIViewContentModeScaleAspectFit;
                placeholderImage.clipsToBounds = YES;
                [bgViewForListAllType addSubview: placeholderImage];
                
                imageViewListMaker = [[UIImageView alloc]initWithFrame:CGRectMake(10, ypositionOfRow + 10, screenWidth - 20, screenWidth / ratio)];
                imageViewListMaker.userInteractionEnabled = YES;
                imageViewListMaker.tag = i;
                UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideoAction:)];
                [imageViewListMaker addGestureRecognizer:imageViewTap];
                [imageViewListMaker setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2, screenshotStr]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                [bgViewForListAllType addSubview:imageViewListMaker];
                ypositionOfRow = imageViewListMaker.frame.origin.y + imageViewListMaker.frame.size.height + 20;
                
                UIImageView *playImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/2 - 40, 70, 80, 80)];
                playImageView.image = [UIImage imageNamed:@"play_video"];
                [imageViewListMaker addSubview:playImageView];
                
                //text
            }else{
                UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,ypositionOfRow +10, screenWidth - 40, [self getHeightOfString:answerStr])];
                NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
                [paragraph setLineSpacing:10];
                paragraph.alignment = NSTextAlignmentJustified;
                paragraph.baseWritingDirection = NSWritingDirectionRightToLeft;
                paragraph.firstLineHeadIndent = 1.0;
                NSDictionary* attributes = @{
                                             NSForegroundColorAttributeName: [UIColor blackColor],
                                             NSParagraphStyleAttributeName: paragraph,
                                             NSFontAttributeName:FONT_NORMAL(15)
                                             };
                NSAttributedString* aString = [[NSAttributedString alloc] initWithString:answerStr attributes: attributes];
                titleLabel.attributedText = aString;
                titleLabel.numberOfLines = 0;
                [bgViewForListAllType addSubview:titleLabel];
                ypositionOfRow += [self getHeightOfString:answerStr]+20;
            }
        }
        bgViewForListAllType.frame = CGRectMake(0, yPosition, screenWidth, ypositionOfRow + 20);
        scrollView.contentSize = CGSizeMake(screenWidth, bgViewForListAllType.frame.size.height  + bgViewForListAllType.frame.origin.y);
    });
}

- (void)tapImageView:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = [[[detailDictionary objectForKey:@"data"]objectForKey:@"fullDescription"]objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageViewController *view = (ImageViewController *)[story instantiateViewControllerWithIdentifier:@"ImageViewController"];
    NSString *url = [NSString stringWithFormat:@"%@%@", BaseURL2, [tempDic objectForKey:@"media"]];
    view.imageViewURL = url;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)tapVideoAction:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = [[[detailDictionary objectForKey:@"data"]objectForKey:@"fullDescription"]objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VideoPlayerViewController *view = (VideoPlayerViewController *)[story instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    NSString *url = [NSString stringWithFormat:@"%@%@", BaseURL4, [tempDic objectForKey:@"media"]];
    view.urlString = url;
    [self.navigationController pushViewController:view animated:YES];
}

-(void) tapAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthorViewController *view = (AuthorViewController *)[story instantiateViewControllerWithIdentifier:@"AuthorViewController"];
    view.author_id = author_id;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - Connection
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

- (void)fetchMessageDetailWithId:(NSString *)messageID{
    
    [ProgressHUD show:@""];
    NSDictionary *params = @{
                             @"message_id":self.message_id,
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    
    /*http://catalog2.yarima.co/mobiles/catalog_get_message_details*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_get_message_details", BaseURL3];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        if ([[tempDic allKeys]count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"جزییات پیام یافت نشد.خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        
        detailDictionary = [[NSMutableDictionary alloc]initWithDictionary:tempDic];
        if ([[detailDictionary objectForKey:@"success"]integerValue] == 1) {
            [self makeScrollView];
        }
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور٬لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        [ProgressHUD dismiss];
    }];
}
@end
