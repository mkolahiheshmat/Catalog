//
//  AboutusViewController.m
//  Catalog
//
//  Created by Developer on 1/21/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "AboutusViewController.h"
#import "Header.h"
#import "ViewController.h"
#import "AboutusViewController.h"
#import "CategoriesViewController.h"
#import "AuthorViewController.h"
#import "DocumentDirectoy.h"
#import "webViewViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "InboxViewController.h"
#import "ConvertHexToColor.h"

#define MENU_WIDTH  screenWidth/1.5
@interface AboutusViewController ()<UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate>
{
    UILabel *titleLabel;
    BOOL isMenuShown;
    UIView *mainView;
    UIView *tranparentView;
    UIScrollView *scrollView;
    UIButton *websiteButton;
    UIButton *mailButton;
    UIButton *instagramButton;
    UIButton *callButton;
}
@end

@implementation AboutusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [self makeTopBar];
    
    [self makeScrollView];
    
    [self menuView];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeHandle:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    //[tranparentView addGestureRecognizer:rightRecognizer];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
    rightEdgeGesture.delegate = self;
    //[self.view addGestureRecognizer:rightEdgeGesture];
}

#pragma mark - custom methods

-(void)makeTopBar{
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
    titleLabel.text = @"یاریما";
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

-(void)makeScrollView{
    NSString *answerStr = @"شرکت فناوری اطلاعات و ارتباطات هوشمند یاریما، مفتخر است به یاری حق تعالی و بهره گیری از نیروهای مجرب و با استعداد در سطوح مختلف و همچنین بکارگیری استانداردهای روز جهانی، به این مهم نائل آید که ظرف مدتی کوتاه، میان برترین شرکت های ارائه دهنده خدمات فن آوری اطلاعات و ارتباطات قرار گیرد.این مجموعه می کوشد، با استفاده از تخصص های درونی خود، کسب کار مشتریانش را به عنوان شرکای تجاری خود توسعه دهد و از هیچ کوششی برای اعتلای کسب و کار و موقعیت شرکای تجاری خود دریغ نخواهد نمود.اعتقاد ما بر آن است که آنچه در توان داریم را در جهت اعتلای اهداف مشتریان خود بگماریم تا بواسطه پیشرفت آنها و نزدیکی هرچه بیشتر آنها به اهدافشان ما نیز بتوانیم به اهداف خود نائل آییم. کوشش ما آن است تا به مسائل از نگاه مشتری بنگریم.";
    
    //CGFloat *labelHeight = [self getHeightOfString:answerStr];
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, screenWidth,screenHeight-64)];
    scrollView.showsVerticalScrollIndicator=YES;
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(0, 700)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:scrollView];
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(40,30 , screenWidth-80, [self getHeightOfString:answerStr])];
    descLabel.font = FONT_NORMAL(15);
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
    NSString* txt = answerStr;
    NSAttributedString* aString = [[NSAttributedString alloc] initWithString: txt attributes: attributes];
    descLabel.attributedText = aString;
    descLabel.numberOfLines = 0;
    [scrollView addSubview:descLabel];
    
    UILabel *emailLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2,descLabel.frame.origin.y+descLabel.frame.size.height+20 , screenWidth/2, 25)];
    emailLabel.text = @"ایمیل:";
    emailLabel.font = FONT_NORMAL(12);
    emailLabel.numberOfLines = 2;
    emailLabel.baselineAdjustment = YES;
    emailLabel.adjustsFontSizeToFitWidth = YES;
    emailLabel.minimumScaleFactor = 0.5;
    emailLabel.clipsToBounds = YES;
    emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.textColor = [UIColor blackColor];
    emailLabel.textAlignment = NSTextAlignmentCenter;
    emailLabel.userInteractionEnabled = YES;
    [scrollView addSubview:emailLabel];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emailTapAction)];
    [emailLabel addGestureRecognizer:tap2];

    UILabel *emailDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(30,descLabel.frame.origin.y+descLabel.frame.size.height+20 , screenWidth/2, 25)];
    emailDescLabel.text = @"info@yarima.co";
    emailDescLabel.font = FONT_NORMAL(12);
    emailDescLabel.numberOfLines = 2;
    emailDescLabel.baselineAdjustment = YES;
    emailDescLabel.adjustsFontSizeToFitWidth = YES;
    emailDescLabel.minimumScaleFactor = 0.5;
    emailDescLabel.clipsToBounds = YES;
    emailDescLabel.backgroundColor = [UIColor clearColor];
    emailDescLabel.textColor = [UIColor blueColor];
    emailDescLabel.textAlignment = NSTextAlignmentCenter;
    emailDescLabel.userInteractionEnabled = YES;
    [scrollView addSubview:emailDescLabel];
    [emailDescLabel addGestureRecognizer:tap2];

    UILabel *websiteLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2,emailLabel.frame.origin.y+emailLabel.frame.size.height+5 , screenWidth/2, 25)];
    websiteLabel.text = @"وب سایت:";
    websiteLabel.font = FONT_NORMAL(12);
    websiteLabel.numberOfLines = 2;
    websiteLabel.baselineAdjustment = YES;
    websiteLabel.adjustsFontSizeToFitWidth = YES;
    websiteLabel.minimumScaleFactor = 0.5;
    websiteLabel.clipsToBounds = YES;
    websiteLabel.backgroundColor = [UIColor clearColor];
    websiteLabel.textColor = [UIColor blackColor];
    websiteLabel.textAlignment = NSTextAlignmentCenter;
    websiteLabel.userInteractionEnabled = YES;
    [scrollView addSubview:websiteLabel];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(websiteTapAction)];
    [websiteLabel addGestureRecognizer:tap3];

    UILabel *websiteDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(30,emailLabel.frame.origin.y+emailLabel.frame.size.height+5 , screenWidth/2, 25)];
    websiteDescLabel.text = @"www.yarima.co";
    websiteDescLabel.font = FONT_NORMAL(12);
    websiteDescLabel.numberOfLines = 2;
    websiteDescLabel.baselineAdjustment = YES;
    websiteDescLabel.adjustsFontSizeToFitWidth = YES;
    websiteDescLabel.minimumScaleFactor = 0.5;
    websiteDescLabel.clipsToBounds = YES;
    websiteDescLabel.backgroundColor = [UIColor clearColor];
    websiteDescLabel.textColor = [UIColor blueColor];
    websiteDescLabel.textAlignment = NSTextAlignmentCenter;
    websiteDescLabel.userInteractionEnabled = YES;
    [scrollView addSubview:websiteDescLabel];

    [websiteDescLabel addGestureRecognizer:tap3];

    UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2,websiteLabel.frame.origin.y+websiteLabel.frame.size.height+5 , screenWidth/2, 25)];
    phoneLabel.text = @"شماره تماس :";
    phoneLabel.font = FONT_NORMAL(12);
    phoneLabel.numberOfLines = 2;
    phoneLabel.baselineAdjustment = YES;
    phoneLabel.adjustsFontSizeToFitWidth = YES;
    phoneLabel.minimumScaleFactor = 0.5;
    phoneLabel.clipsToBounds = YES;
    phoneLabel.backgroundColor = [UIColor clearColor];
    phoneLabel.textColor = [UIColor blackColor];
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    phoneLabel.userInteractionEnabled = YES;
    [scrollView addSubview:phoneLabel];
    
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(phoneTapAction)];
    [phoneLabel addGestureRecognizer:tap4];

    UILabel *phoneNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(30,websiteLabel.frame.origin.y+websiteLabel.frame.size.height+5 , screenWidth/2, 25)];
    phoneNumberLabel.text = @"۰۲۱۶۶۱۵۸۷۳۹";
    phoneNumberLabel.font = FONT_NORMAL(12);
    phoneNumberLabel.numberOfLines = 2;
    phoneNumberLabel.baselineAdjustment = YES;
    phoneNumberLabel.adjustsFontSizeToFitWidth = YES;
    phoneNumberLabel.minimumScaleFactor = 0.5;
    phoneNumberLabel.clipsToBounds = YES;
    phoneNumberLabel.backgroundColor = [UIColor clearColor];
    phoneNumberLabel.textColor = [UIColor blueColor];
    phoneNumberLabel.textAlignment = NSTextAlignmentCenter;
    phoneNumberLabel.userInteractionEnabled = YES;
    [scrollView addSubview:phoneNumberLabel];
    [phoneNumberLabel addGestureRecognizer:tap4];

    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-100, phoneLabel.frame.origin.y+phoneLabel.frame.size.height+30,200,40)];
    logoImageView.image = [UIImage imageNamed:@"menuLogo"];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.userInteractionEnabled = YES;
    logoImageView.layer.cornerRadius = 40 / 2;
    logoImageView.clipsToBounds = YES;
    [scrollView addSubview: logoImageView];
    
    UIView *horizontalLine2 = [[UIView alloc] initWithFrame:CGRectMake(30,logoImageView.frame.origin.y+logoImageView.frame.size.height+20,screenWidth-60,0.7)];
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        horizontalLine2.backgroundColor = color;
    } else {
        horizontalLine2.backgroundColor = MAIN_COLOR;
    }
    horizontalLine2.userInteractionEnabled = NO;
    [scrollView addSubview:horizontalLine2];
    
    UILabel *versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2-30,logoImageView.frame.origin.y+logoImageView.frame.size.height+30 , 60, 30)];
    versionLabel.text = @"نسخه ۱.۰.۰";
    versionLabel.font = FONT_NORMAL(12);
    versionLabel.numberOfLines = 2;
    versionLabel.baselineAdjustment = YES;
    versionLabel.adjustsFontSizeToFitWidth = YES;
    versionLabel.minimumScaleFactor = 0.5;
    versionLabel.clipsToBounds = YES;
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.textColor = [UIColor blackColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:versionLabel];
    
    scrollView.contentSize = CGSizeMake(screenWidth, descLabel.frame.origin.y+descLabel.frame.size.height+300);
}

-(void)websiteTapAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    webViewViewController *view = (webViewViewController *)[story instantiateViewControllerWithIdentifier:@"webViewViewController"];
    view.strURL = @"www.yarima.co";
    view.topViewTitleText = @"وب سایت";
    [self.navigationController pushViewController:view animated:YES];
}

-(void)emailTapAction{
    
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
        [mailViewController setToRecipients:@[@"info@yarima.co"]];
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
-(void)phoneTapAction{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",@"02166158739"]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"امکان برقراری تماس وجود ندارد." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
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
        // Animate back to center x
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
    CGSize sizeOfText = [aString boundingRectWithSize:CGSizeMake( screenWidth - 80,CGFLOAT_MAX)
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              context:nil].size;
    
    CGFloat height = sizeOfText.height;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        height = sizeOfText.height + 10;
    return height;
}
@end
