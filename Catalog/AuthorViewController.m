//
//  AuthorViewController.m
//  Catalog
//
//  Created by Developer on 1/23/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "AuthorViewController.h"
#import "Header.h"
#import "ViewController.h"
#import "CategoriesViewController.h"
#import "AboutusViewController.h"
#import "webViewViewController.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "DocumentDirectoy.h"
#import "InboxViewController.h"
#import "ConvertHexToColor.h"
#import "MapViewController.h"

#define MENU_WIDTH  screenWidth/1.5
@interface AuthorViewController ()<UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate, UIScrollViewDelegate>
{
    BOOL isMenuShown;
    UIView *mainView;
    UIView *tranparentView;
    NSString *coverImageURL;
    NSString *website;
    NSString *instagram;
    NSString *phoneNumber;
    NSString *email;
    NSString *telegram;
    NSString *descriptionText;
    UIScrollView *_scrollView;
    UIView *topView;
    UILabel *titleLabel;
    UIButton *websiteButton;
    UIButton *telegramButton;
    UIButton *mailButton;
    UIButton *instagramButton;
    UIButton *callButton;
    UILabel *offlineLabel;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;
@end

@implementation AuthorViewController

- (void) viewWillAppear:(BOOL)animated{
    
    offlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, screenWidth-40,  25)];
    offlineLabel.font = FONT_MEDIUM(17);
    offlineLabel.text = @"اتصال به اینترنت برقرار نیست.";
    offlineLabel.minimumScaleFactor = 0.7;
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        offlineLabel.textColor = color;
    } else {
        offlineLabel.textColor = MAIN_COLOR;
    }
    offlineLabel.textAlignment = NSTextAlignmentCenter;
    offlineLabel.adjustsFontSizeToFitWidth = YES;
    offlineLabel.hidden = YES;
    [self.view addSubview:offlineLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeTopBar];
    
    [self menuView];
    
    if ([self hasConnectivity]) {
        [self fetchAuthorInfo:self.author_id];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            offlineLabel.hidden = NO;
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSDictionary *tempDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"authorInfoDic"];
        if ([tempDic count] > 1) {
            coverImageURL = [tempDic objectForKey:@"cover"];
            website = [tempDic objectForKey:@"website"];
            email = [tempDic objectForKey:@"email"];
            instagram = [tempDic objectForKey:@"instagram"];
            phoneNumber = [tempDic objectForKey:@"mobile"];
            descriptionText = [tempDic objectForKey:@"description"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self makeScrollView];
            });
        }
    }
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeHandle:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    //[tranparentView addGestureRecognizer:rightRecognizer];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
    rightEdgeGesture.delegate = self;
    //[self.view addGestureRecognizer:rightEdgeGesture];
}

#pragma mark - Custom Methods
-(void) makeTopBar{
    topView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,64)];
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
    UIImage *buttonImageNormal = [UIImage imageNamed:@"backButton"];
    [backButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    //54*39
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-50, 20, 64 * 0.5, 64 * 0.5)];    [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UIImage *menuImageNormal = [UIImage imageNamed:@"menu"];
    [menuButton setBackgroundImage:menuImageNormal forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:menuButton];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = @"درباره ما";
    titleLabel.font = FONT_MEDIUM(20);
    titleLabel.numberOfLines = 1;
    titleLabel.baselineAdjustment = YES;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.clipsToBounds = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];//MAIN_COLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
}

- (void)makeScrollView{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, screenWidth,screenHeight - 64)];
    _scrollView.showsVerticalScrollIndicator=YES;
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView setScrollEnabled:YES];
    _scrollView.delegate = self;
    [_scrollView setContentSize:CGSizeMake(0, 700)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:_scrollView];
    
    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth,screenWidth*0.6)];
    //coverImageView.image = [UIImage imageNamed:@"menuLogo"];
    [coverImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL2,coverImageURL]] placeholderImage:[UIImage imageNamed:@"logo"]];
    coverImageView.backgroundColor = [UIColor whiteColor];
    //coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    coverImageView.userInteractionEnabled = YES;
    [_scrollView addSubview: coverImageView];
    
    websiteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    websiteButton.frame = CGRectMake(0, coverImageView.frame.origin.y+coverImageView.frame.size.height+5, screenWidth, 40);
    [websiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    [websiteButton addTarget:self action:@selector(websiteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [websiteButton setTitle:website forState:UIControlStateNormal];
    //websiteButton.titleLabel.font = FONT_NORMAL(15);
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        websiteButton.backgroundColor = color;
    } else {
        websiteButton.backgroundColor = MAIN_COLOR;
    }
    [_scrollView addSubview:websiteButton];
    
    UIImageView *websiteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 5, 300*0.09,300*0.09)];
    websiteImageView.image = [UIImage imageNamed:@"website"];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        websiteImageView.backgroundColor = color;
    } else {
        websiteImageView.backgroundColor = MAIN_COLOR;
    }
    websiteImageView.contentMode = UIViewContentModeScaleAspectFit;
    websiteImageView.userInteractionEnabled = YES;
    [websiteButton addSubview: websiteImageView];
    if ([website length] == 0) {
        CGRect rect = websiteButton.frame;
        rect.origin.y -= 5;
        rect.size.height = 0;
        [websiteButton setFrame:rect];
        CGRect rect2 = websiteImageView.frame;
        rect2.size.height = 0;
        [websiteImageView setFrame:rect2];
    }
    telegramButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    telegramButton.frame = CGRectMake(0, websiteButton.frame.origin.y+websiteButton.frame.size.height+5, screenWidth, 40);
    [telegramButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    [telegramButton addTarget:self action:@selector(telegramButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [telegramButton setTitle:telegram forState:UIControlStateNormal];
    //telegramButton.titleLabel.font = FONT_NORMAL(15);
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        telegramButton.backgroundColor = color;
    } else {
        telegramButton.backgroundColor = MAIN_COLOR;
    }
    [_scrollView addSubview:telegramButton];
    UIImageView *telegramImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 5, 300*0.09,300*0.09)];
    telegramImageView.image = [UIImage imageNamed:@"telegram"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        telegramImageView.backgroundColor = color;
    } else {
        telegramImageView.backgroundColor = MAIN_COLOR;
    }
    telegramImageView.contentMode = UIViewContentModeScaleAspectFit;
    telegramImageView.userInteractionEnabled = YES;
    [telegramButton addSubview: telegramImageView];
    if ([telegram length] == 0) {
        CGRect rect = telegramButton.frame;
        rect.origin.y -= 5;
        rect.size.height = 0;
        [telegramButton setFrame:rect];
        CGRect rect2 = telegramImageView.frame;
        rect2.size.height = 0;
        [telegramImageView setFrame:rect2];
    }
    instagramButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    instagramButton.frame = CGRectMake(0, telegramButton.frame.origin.y+telegramButton.frame.size.height+5, screenWidth, 40);
    [instagramButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    [instagramButton addTarget:self action:@selector(instagramButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [instagramButton setTitle:instagram forState:UIControlStateNormal];
    //instagramButton.titleLabel.font = FONT_NORMAL(15);
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        instagramButton.backgroundColor = color;
    } else {
        instagramButton.backgroundColor = MAIN_COLOR;
    }
    [_scrollView addSubview:instagramButton];
    
    UIImageView *instagramImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 5, 300*0.09,300*0.09)];    instagramImageView.image = [UIImage imageNamed:@"instagram"];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        instagramImageView.backgroundColor = color;
    } else {
        instagramImageView.backgroundColor = MAIN_COLOR;
    }
    instagramImageView.contentMode = UIViewContentModeScaleAspectFit;
    instagramImageView.userInteractionEnabled = YES;
    [instagramButton addSubview: instagramImageView];
    if ([instagram length] == 0) {
        CGRect rect = instagramButton.frame;
        rect.origin.y -= 5;
        rect.size.height = 0;
        [instagramButton setFrame:rect];
        CGRect rect2 = instagramImageView.frame;
        rect2.size.height = 0;
        [instagramImageView setFrame:rect2];
    }
    mailButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mailButton.frame = CGRectMake(0, instagramButton.frame.origin.y+instagramButton.frame.size.height+5, screenWidth, 40);
    [mailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    [mailButton addTarget:self action:@selector(mailButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [mailButton setTitle:email forState:UIControlStateNormal];
    //mailButton.titleLabel.font = FONT_NORMAL(15);
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        mailButton.backgroundColor = color;
    } else {
        mailButton.backgroundColor = MAIN_COLOR;
    }
    [_scrollView addSubview:mailButton];
    
    UIImageView *mailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 5, 300*0.09,300*0.09)]; mailImageView.image = [UIImage imageNamed:@"email"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        mailImageView.backgroundColor = color;
    } else {
        mailImageView.backgroundColor = MAIN_COLOR;
    }
    mailImageView.contentMode = UIViewContentModeScaleAspectFit;
    mailImageView.userInteractionEnabled = YES;
    [mailButton addSubview: mailImageView];
    if ([email length] == 0) {
        CGRect rect = mailButton.frame;
        rect.origin.y -= 5;
        rect.size.height = 0;
        [mailButton setFrame:rect];
        CGRect rect2 = mailImageView.frame;
        rect2.size.height = 0;
        [mailImageView setFrame:rect2];
    }
    callButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    callButton.frame = CGRectMake(0, mailButton.frame.origin.y+mailButton.frame.size.height+5, screenWidth, 40);
    [callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    [callButton addTarget:self action:@selector(callButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [callButton setTitle:phoneNumber forState:UIControlStateNormal];
    callButton.titleLabel.font = FONT_NORMAL(15);
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        callButton.backgroundColor = color;
    } else {
        callButton.backgroundColor = MAIN_COLOR;
    }
    [_scrollView addSubview:callButton];
    
    UIImageView *callImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 5, 300*0.09,300*0.09)];    callImageView.image = [UIImage imageNamed:@"telephone"];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        callImageView.backgroundColor = color;
    } else {
        callImageView.backgroundColor = MAIN_COLOR;
    }
    callImageView.contentMode = UIViewContentModeScaleAspectFit;
    callImageView.userInteractionEnabled = YES;
    [callButton addSubview: callImageView];
    if ([phoneNumber length] == 0) {
        CGRect rect = callButton.frame;
        rect.origin.y -= 5;
        rect.size.height = 0;
        [callButton setFrame:rect];
        CGRect rect2 = callImageView.frame;
        rect2.size.height = 0;
        [callImageView setFrame:rect2];
    }
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20,callButton.frame.origin.y+callButton.frame.size.height+10,screenWidth-40,0.7)];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        lineView.backgroundColor = color;
    } else {
        lineView.backgroundColor = MAIN_COLOR;
    }
    
    lineView.userInteractionEnabled = NO;
    [_scrollView addSubview:lineView];
    
    //NSString* txt2 = [NSString stringWithFormat:@"%@%@",descriptionText,descriptionText];
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(25,lineView.frame.origin.y+lineView.frame.size.height+10 , screenWidth-50, [self getHeightOfString:descriptionText])];
    
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
    //NSString* txt = [NSString stringWithFormat:@"%@%@",descriptionText,descriptionText];
    NSAttributedString* aString = [[NSAttributedString alloc] initWithString:descriptionText attributes: attributes];
    descriptionLabel.attributedText = aString;
    descriptionLabel.numberOfLines = 0;
    [_scrollView addSubview:descriptionLabel];
    
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mapButton.frame = CGRectMake(0, descriptionLabel.frame.origin.y+descriptionLabel.frame.size.height+15, screenWidth, screenWidth*0.34);
    [mapButton setBackgroundImage:[UIImage imageNamed:@"Map"] forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(mapButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[_scrollView addSubview:mapButton];
    _scrollView.contentSize = CGSizeMake(screenWidth, descriptionLabel.frame.origin.y+descriptionLabel.frame.size.height+100);
    //_scrollView.contentSize = CGSizeMake(screenWidth, mapButton.frame.origin.y+mapButton.frame.size.height+100);
}

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)websiteButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    webViewViewController *view = (webViewViewController *)[story instantiateViewControllerWithIdentifier:@"webViewViewController"];
    view.strURL = website;
    view.topViewTitleText = @"وب سایت";
    [self.navigationController pushViewController:view animated:YES];
}

-(void)telegramButtonAction{
    NSString *telegramURL = [NSString stringWithFormat:@"tg://resolve?domain=%@",telegram];
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:telegramURL]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telegramURL]];
    }else{
        //App not installed.
    }
}

-(void)instagramButtonAction{
    NSString *InstaURL = instagramButton.titleLabel.text;
    InstaURL = [InstaURL stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSString *completeInstaURL = [NSString stringWithFormat:@"instagram://user?username=%@",InstaURL ];
    NSURL *instagramURL = [NSURL URLWithString:completeInstaURL];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }else{
        // [[UIApplication sharedApplication]openURL:@"http://instagram.com"];
    }
}

-(void)mailButtonAction{
    
    //    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    webViewViewController *view = (webViewViewController *)[story instantiateViewControllerWithIdentifier:@"webViewViewController"];
    //    //view.strURL = @"https://www.instagram.com/?hl=en";
    //    view.topViewTitleText = @"ایمیل";
    //    [self.navigationController pushViewController:view animated:YES];
    
    ////solutio1
    //[self launchMailAppOnDevice];
    
    ////solution2
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"عنوان ایمیل"];
        [mailViewController setMessageBody:@"متن پیام" isHTML:NO];
        [mailViewController setToRecipients:@[email]];
        [self presentViewController:mailViewController animated:true completion:nil];
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"لطفا ایمیل خود را در تنظیمات گوشی فعال کنید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)callButtonAction{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phoneNumber]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"متاسفانه امکان برقراری تماس وجود ندارد." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)menuButtonAction{
    if (isMenuShown) {
        CGRect rect2 = tranparentView.frame;
        rect2.origin.x = screenWidth;
        tranparentView.frame = rect2;
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = mainView.frame;
            rect.origin.x = screenWidth;
            mainView.frame = rect;
        }];
        isMenuShown = NO;
    } else {
        CGRect rect2 = tranparentView.frame;
        rect2.origin.x = 0;
        tranparentView.frame = rect2;
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = mainView.frame;
            rect.origin.x = screenWidth-MENU_WIDTH;
            mainView.frame = rect;
        }];
        isMenuShown = YES;
    }
}

-(void)menuView{
    tranparentView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth,0,screenWidth,screenHeight)];
    tranparentView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    tranparentView.userInteractionEnabled = YES;
    [self.view addSubview:tranparentView];
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth,0,MENU_WIDTH,screenHeight)];
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.userInteractionEnabled = YES;
    [self.view addSubview:mainView];
    
    UIView *menuColorView = [[UIView alloc] initWithFrame:CGRectMake(0,0,MENU_WIDTH,screenHeight/3)];
    menuColorView.backgroundColor = [UIColor whiteColor];   //MAIN_COLOR;
    menuColorView.userInteractionEnabled = NO;
    [mainView addSubview:menuColorView];
    
    //165*95
    
    CGFloat menuImageRatio = [[[NSUserDefaults standardUserDefaults]objectForKey:@"menuImageRatio"]floatValue];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, MENU_WIDTH - 60, ((MENU_WIDTH - 60) * menuImageRatio))];
    NSString *tempName = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuImage"];
    logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.userInteractionEnabled = YES;
    [menuColorView addSubview: logoImageView];
    
    UIButton *homeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, menuColorView.frame.size.height, mainView.frame.size.width, 50)];
    [homeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [homeButton addTarget:self action:@selector(homeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [homeButton setTitle:@"خانه" forState:UIControlStateNormal];
    homeButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:homeButton];
    
    //164*143
    UIImageView *homeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(homeButton.frame.size.width-43, 10, 28,25)];
    homeImageView.image = [UIImage imageNamed:@"menuHome"];
    homeImageView.backgroundColor = [UIColor whiteColor];
    homeImageView.contentMode = UIViewContentModeScaleAspectFit;
    homeImageView.userInteractionEnabled = YES;
    [homeButton addSubview: homeImageView];
    
    UIButton *CategoriesButton = [[UIButton alloc]initWithFrame:CGRectMake(-10, homeButton.frame.origin.y+homeButton.frame.size.height, mainView.frame.size.width, 50)];
    [CategoriesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [CategoriesButton addTarget:self action:@selector(categoriesButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [CategoriesButton setTitle:@"دسته بندی ها" forState:UIControlStateNormal];
    CategoriesButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:CategoriesButton];
    
    //164*164
    UIImageView *categoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CategoriesButton.frame.size.width-30, 10, 25,25)];
    categoryImageView.image = [UIImage imageNamed:@"menuCategories"];
    categoryImageView.backgroundColor = [UIColor whiteColor];
    categoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    categoryImageView.userInteractionEnabled = YES;
    [CategoriesButton addSubview: categoryImageView];
    
    UIButton *inboxButton = [[UIButton alloc]initWithFrame:CGRectMake(-10, CategoriesButton.frame.origin.y+CategoriesButton.frame.size.height, mainView.frame.size.width, 50)];
    [inboxButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [inboxButton addTarget:self action:@selector(inboxButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [inboxButton setTitle:@"صندوق پیام" forState:UIControlStateNormal];
    inboxButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:inboxButton];
    
    //164*164
    UIImageView *inboxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(inboxButton.frame.size.width-30, 10, 25,25)];
    inboxImageView.image = [UIImage imageNamed:@"menuCategories"];
    inboxImageView.backgroundColor = [UIColor whiteColor];
    inboxImageView.contentMode = UIViewContentModeScaleAspectFit;
    inboxImageView.userInteractionEnabled = YES;
    [inboxButton addSubview: inboxImageView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,inboxButton.frame.origin.y+inboxButton.frame.size.height+10,MENU_WIDTH,0.7)];    lineView.backgroundColor = [UIColor grayColor];
    lineView.userInteractionEnabled = NO;
    [mainView addSubview:lineView];
    
    UIButton *aboutusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, lineView.frame.origin.y+lineView.frame.size.height,MENU_WIDTH,50)];
    [aboutusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [aboutusButton addTarget:self action:@selector(aboutusButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [aboutusButton setTitle:@"درباره ما" forState:UIControlStateNormal];
    aboutusButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:aboutusButton];
    
    UIImageView *aboutusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(aboutusButton.frame.size.width-40, 10, 30,30)];
    aboutusImageView.image = [UIImage imageNamed:@"menuAboutus"];
    aboutusImageView.backgroundColor = [UIColor whiteColor];
    aboutusImageView.contentMode = UIViewContentModeScaleAspectFit;
    aboutusImageView.userInteractionEnabled = YES;
    [aboutusButton addSubview: aboutusImageView];
    
    UIButton *designTeamButton = [[UIButton alloc]initWithFrame:CGRectMake(0, mainView.frame.size.height - 50,MENU_WIDTH,50)];
    [designTeamButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [designTeamButton addTarget:self action:@selector(designTeamButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [designTeamButton setTitle:@"تیم طراحی و توسعه" forState:UIControlStateNormal];
    designTeamButton.titleLabel.font = FONT_NORMAL(12);
    [mainView addSubview:designTeamButton];
    
    UIImageView *designTeamimageView = [[UIImageView alloc] initWithFrame:CGRectMake(designTeamButton.frame.size.width-40, 15, 100*0.2,99*0.2)];
    designTeamimageView.image = [UIImage imageNamed:@"designTeam"];
    designTeamimageView.backgroundColor = [UIColor whiteColor];
    designTeamimageView.contentMode = UIViewContentModeScaleAspectFit;
    designTeamimageView.userInteractionEnabled = YES;
    [designTeamButton addSubview: designTeamimageView];
}

-(void)homeButtonAction{
    [self menuButtonAction];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *view = (ViewController *)[story instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)categoriesButtonAction{
    [self menuButtonAction];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CategoriesViewController *view = (CategoriesViewController *)[story instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)inboxButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InboxViewController *view = (InboxViewController *)[story instantiateViewControllerWithIdentifier:@"InboxViewController"];
    //view.author_id = [@"1" integerValue];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)aboutusButtonAction{
    [self menuButtonAction];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthorViewController *view = (AuthorViewController *)[story instantiateViewControllerWithIdentifier:@"AuthorViewController"];
    view.author_id = [@"1" integerValue];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)designTeamButtonAction{
    [self menuButtonAction];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AboutusViewController *view = (AboutusViewController *)[story instantiateViewControllerWithIdentifier:@"AboutusViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self menuButtonAction];
}

- (void)handleRightEdgeGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    if(UIGestureRecognizerStateBegan == gesture.state ||
       UIGestureRecognizerStateChanged == gesture.state) {
    } else {// cancel, fail, or ended
        [self menuButtonAction];
    }
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
    CGSize sizeOfText = [aString boundingRectWithSize:CGSizeMake( screenWidth - 50,CGFLOAT_MAX)
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              context:nil].size;
    
    //boundingRectWithSize: CGSizeMake( self.view.bounds.size.width,CGFLOAT_MAX)
    //     options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
    //   context: nil].size;
    CGFloat height = sizeOfText.height;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        height = sizeOfText.height + 10;
    return height;
}

-(void) mapButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapViewController *view = (MapViewController *)[story instantiateViewControllerWithIdentifier:@"MapViewController"];
    //view.branchesArray = branchesArray;
    [self presentViewController:view animated:YES completion:nil];
}

#pragma mark - scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 100) {
        NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
        NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            topView.backgroundColor = color;
        } else {
            topView.backgroundColor = MAIN_COLOR;
        }
        
        titleLabel.textColor = [UIColor whiteColor];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect  =topView.frame;
            rect.size.height = 64;
            rect.origin.y = 0;
            [topView setFrame:rect];
            rect = scrollView.frame;
            rect.origin.y = 64;
            [scrollView setFrame:rect];
            rect = titleLabel.frame;
            rect.origin.y = 25;
            [titleLabel setFrame:rect];
        }];
    }
    else if (scrollView.contentOffset.y >= 100) {
        //NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
        topView.backgroundColor = [UIColor whiteColor];
        NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            titleLabel.textColor = color;
        } else {
            titleLabel.textColor = MAIN_COLOR;
        }
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect  =topView.frame;
            //rect.size.height = 20;
            rect = scrollView.frame;
            rect.origin.y = 20;
            rect.size.height = screenHeight;
            [scrollView setFrame:rect];
            [topView setFrame:rect];
        }];
    }
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

- (void)fetchAuthorInfo:(NSInteger)authorId {
    //   [noResultLabelPost removeFromSuperview];
    [ProgressHUD show:@""];
    
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
        [ProgressHUD dismiss];
        NSDictionary *tempDic = [(NSDictionary *)responseObject objectForKey:@"author"];
        
        [[NSUserDefaults standardUserDefaults]setObject:tempDic forKey:@"authorInfoDic"];
        
        if ([[tempDic allKeys]count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        coverImageURL = [tempDic objectForKey:@"cover"];
        website = [tempDic objectForKey:@"website"];
        email = [tempDic objectForKey:@"email"];
        instagram = [tempDic objectForKey:@"instagram"];
        phoneNumber = [tempDic objectForKey:@"mobile"];
        telegram = [tempDic objectForKey:@"telegram"];
        descriptionText = [tempDic objectForKey:@"description"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self makeScrollView];
        });
    }failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        //isBusyNow = NO;
    }];
}

-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:myemail@gmail.com?subject=subjecthere";
    NSString *body = @"&body=bodyHere";
    
    NSString *email1 = [NSString stringWithFormat:@"%@%@", recipients, body];
    email1 = [email1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email1]];
}
@end
