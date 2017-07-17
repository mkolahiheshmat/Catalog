//
//  SignInViewController.m
//  Catalog
//
//  Created by Developer on 7/9/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "SignInViewController.h"
#import "Header.h"
#import "ConvertHexToColor.h"
#import "ReplacerEngToPer.h"
#import "CategoriesViewController.h"
#import "InboxViewController.h"
#import "AboutViewController.h"
#import "FormViewController.h"
#import "AuthorViewController.h"
#import "AboutusViewController.h"
#import "EnterCodViewController.h"
#import "ShakeAnimation.h"
#import "ImageResizer.h"
#import "ViewController.h"
#import "DocumentDirectoy.h"
#import "ShoppingViewController.h"

#define MENU_WIDTH  screenWidth/1.5
@interface SignInViewController ()<UITextFieldDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UILabel *titleLabel;
    UIScrollView *_scrollView;
    UIPageControl *pageControl;
    UIImageView *logoImageView;
    UITextField *phoneTextField;
    UIView *tranparentView;
    BOOL isMenuShown;
    UIView *mainView;
    UIView *menuColorView;
    NSString *menuImageURL;
    CGFloat menuImageRatio;
    UIView *backViewForImage;
    UIScrollView *menuScrollView;
}
@end

@implementation SignInViewController

- (void)viewDidDisappear:(BOOL)animated{
    if (isMenuShown) {
        [self menuButtonAction];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissTextField)];
    [self.view addGestureRecognizer:imageViewTap];
    
//    logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-75, 64, 150,150)];
//    logoImageView.image = [UIImage imageNamed:@"nativeSplash"];
//    logoImageView.backgroundColor = [UIColor whiteColor];
//    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
//    logoImageView.userInteractionEnabled = YES;
//    [self.view addSubview: logoImageView];
    logoImageView = [ImageResizer resizeImageWithImage:[UIImage imageNamed:@"nativeSplash"] withWidth:150 withPoint:CGPointMake(screenWidth/2-75, 150)];
    [self.view addSubview:logoImageView];
    //loginTozih
    UILabel *tozihLabel =[[UILabel alloc]initWithFrame:CGRectMake(20, logoImageView.frame.origin.y + logoImageView.frame.size.height + 20, screenWidth - 40, 60)];
    tozihLabel.font = FONT_NORMAL(15);
    tozihLabel.text = @"کاربر گرامی برای استفاده از امکانات اپلیکیشن شماره ی تلفن همراه خود را وارد کنید";
    tozihLabel.textColor = [UIColor blackColor];
    tozihLabel.numberOfLines = 2;
    tozihLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tozihLabel];
    
    phoneTextField = [[UITextField alloc]initWithFrame:CGRectMake(screenWidth/2 - 100, tozihLabel.frame.origin.y + tozihLabel.frame.size.height + 30, 200, 30)];
    phoneTextField.placeholder = @"شماره موبایل خود را واردکنید";
    phoneTextField.tag = 354;
    phoneTextField.layer.cornerRadius = 15;
    phoneTextField.backgroundColor = [UIColor whiteColor];
    phoneTextField.clipsToBounds = YES;
    phoneTextField.font = FONT_NORMAL(15);
    phoneTextField.textAlignment = NSTextAlignmentCenter;
    phoneTextField.delegate = self;
    phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [phoneTextField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:phoneTextField];
    
    UIButton *sendButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, phoneTextField.frame.origin.y + phoneTextField.frame.size.height + 30, 160, 30)];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitle:@"تایید" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    sendButton.titleLabel.font = FONT_NORMAL(17);
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        sendButton.backgroundColor = color;
    } else {
        sendButton.backgroundColor = MAIN_COLOR;
    }
    [[sendButton layer] setCornerRadius:10.0f];
    [[sendButton layer] setMasksToBounds:YES];
    [[sendButton layer] setBorderWidth:1.0f];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        [[sendButton layer] setBorderColor:color.CGColor];
    } else {
        [[sendButton layer] setBorderColor:MAIN_COLOR.CGColor];
    }
    //sendButton.alpha = 0.0;
    [self.view addSubview:sendButton];
    
    NSString *mobileString = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobile"];
    if ([mobileString length] == 11) {
//        UIButton *codeTaeedButton = [CustomButton
//                                     initButtonWithTitle:NSLocalizedString(@"entercode", @"")
//                                     withTitleColor:MAIN_COLOR
//                                     withBackColor:[UIColor clearColor]
//                                     withFrame:CGRectMake(screenWidth/2 - 80, logoImageView.frame.size.height + 260, 160, 30)];
//        codeTaeedButton.titleLabel.font = FONT_NORMAL(15);
//        [codeTaeedButton addTarget:self action:@selector(codeTaeedButtonAction) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:codeTaeedButton];
        UIButton *codeTaeedButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth/2 - 80, sendButton.frame.origin.y + sendButton.frame.size.height + 20, 160, 30)];
        [codeTaeedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [codeTaeedButton setTitle:@"واردکردن کد تایید" forState:UIControlStateNormal];
        [codeTaeedButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
        codeTaeedButton.titleLabel.font = FONT_NORMAL(17);
        NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            codeTaeedButton.backgroundColor = color;
        } else {
            codeTaeedButton.backgroundColor = MAIN_COLOR;
        }
        [[codeTaeedButton layer] setCornerRadius:10.0f];
        [[codeTaeedButton layer] setMasksToBounds:YES];
        [[codeTaeedButton layer] setBorderWidth:1.0f];
        //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            [[codeTaeedButton layer] setBorderColor:color.CGColor];
        } else {
            [[codeTaeedButton layer] setBorderColor:MAIN_COLOR.CGColor];
        }
        //sendButton.alpha = 0.0;
        [self.view addSubview:codeTaeedButton];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backButtonImgAction) name:@"dimissLoginView" object:nil];
    
    [self makeTopBar];
    [self menuView];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeHandle:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    [tranparentView addGestureRecognizer:rightRecognizer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    tranparentView.userInteractionEnabled = YES;
    [tranparentView addGestureRecognizer:tapGesture];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
    rightEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:rightEdgeGesture];
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
    
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-50, 20, 64 * 0.5, 64 * 0.5)];    [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UIImage *menuImageNormal = [UIImage imageNamed:@"menu"];
    [menuButton setBackgroundImage:menuImageNormal forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuButton];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = @"ثبت نام/ورود";
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

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)menuButtonAction{
    [self dismissTextField];
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
    menuImageRatio = [[[NSUserDefaults standardUserDefaults]objectForKey:@"menuImageRatio"]floatValue];
    tranparentView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth,0,screenWidth,screenHeight)];
    tranparentView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    tranparentView.userInteractionEnabled = YES;
    [self.view addSubview:tranparentView];
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth,0,MENU_WIDTH,screenHeight)];
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.userInteractionEnabled = YES;
    [self.view addSubview:mainView];
    
    menuColorView = [[UIView alloc] initWithFrame:CGRectMake(0,0,MENU_WIDTH,screenHeight/3)];
    menuColorView.backgroundColor = [UIColor whiteColor];   //MAIN_COLOR;
    menuColorView.userInteractionEnabled = NO;
    [mainView addSubview:menuColorView];
    
    backViewForImage = [[UIView alloc] initWithFrame:CGRectMake((menuColorView.frame.size.width/2)-75,(menuColorView.frame.size.height/2)-75,150,150)];
    backViewForImage.backgroundColor = [UIColor clearColor];
    backViewForImage.userInteractionEnabled = NO;
    [menuColorView addSubview:backViewForImage];
    
    //show native splash for menu image just if connection is broken,instead of showing 2 image cover each other
    logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewForImage.frame.size.width, backViewForImage.frame.size.height)];
    NSString *tempName = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuImage"];
    if ([tempName length] > 0) {
        logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]];
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [backViewForImage addSubview: logoImageView];
    }else{
        //if (![self hasConnectivity]) {
        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewForImage.frame.size.width, backViewForImage.frame.size.height)];
        logoImageView.image =[UIImage imageNamed:@"nativeSplash"];
        logoImageView.userInteractionEnabled = YES;
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [backViewForImage addSubview: logoImageView];
    }
//    menuScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, screenHeight/3, MENU_WIDTH, screenHeight-50-(screenHeight/3))];
//    menuScrollView.showsVerticalScrollIndicator = NO;
//    menuScrollView.showsHorizontalScrollIndicator = NO;
//    menuScrollView.backgroundColor = [UIColor clearColor];
//    menuScrollView.scrollEnabled = YES;
//    [mainView addSubview:menuScrollView];
//    menuScrollView.contentSize = CGSizeMake(MENU_WIDTH, 8 * 60);
    
    //UIButton *homeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, mainView.frame.size.width, 50)];
    UIButton *homeButton = [[UIButton alloc]initWithFrame:CGRectMake(0,menuColorView.frame.size.height, mainView.frame.size.width, 50)];
    [homeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [homeButton addTarget:self action:@selector(homeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [homeButton setTitle:@"خانه" forState:UIControlStateNormal];
    homeButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:homeButton];
    //[menuScrollView addSubview:homeButton];
    
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
    //[menuScrollView addSubview:CategoriesButton];
    
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
    //[menuScrollView addSubview:inboxButton];
    
    //164*164
    UIImageView *inboxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(inboxButton.frame.size.width-33, 10, 30,30)];
    inboxImageView.image = [UIImage imageNamed:@"menuInbox"];
    inboxImageView.backgroundColor = [UIColor whiteColor];
    inboxImageView.contentMode = UIViewContentModeScaleAspectFit;
    inboxImageView.userInteractionEnabled = YES;
    [inboxButton addSubview: inboxImageView];
    
    UILabel *badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,10,25, 25)];
    badgeLabel.text = @"۱";
    badgeLabel.font = FONT_NORMAL(12);
    badgeLabel.numberOfLines = 1;
    badgeLabel.layer.cornerRadius = 10;
    badgeLabel.baselineAdjustment = YES;
    badgeLabel.adjustsFontSizeToFitWidth = YES;
    badgeLabel.minimumScaleFactor = 0.5;
    badgeLabel.clipsToBounds = YES;
    badgeLabel.backgroundColor = [UIColor redColor];
    badgeLabel.textColor = [UIColor whiteColor];
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    badgeLabel.userInteractionEnabled = YES;
    //[inboxButton addSubview:badgeLabel];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(-10, inboxButton.frame.origin.y+inboxButton.frame.size.height, mainView.frame.size.width, 50)];
    [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setTitle:@"معرفی به دوستان" forState:UIControlStateNormal];
    shareButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:shareButton];
    //[menuScrollView addSubview:shareButton];
    
    //164*164
    UIImageView *shareImageView = [[UIImageView alloc] initWithFrame:CGRectMake(shareButton.frame.size.width-33, 10, 30,30)];
    shareImageView.image = [UIImage imageNamed:@"menuShare"];
    shareImageView.backgroundColor = [UIColor whiteColor];
    shareImageView.contentMode = UIViewContentModeScaleAspectFit;
    shareImageView.userInteractionEnabled = YES;
    [shareButton addSubview: shareImageView];
    
    UIButton *formButton = [[UIButton alloc]initWithFrame:CGRectMake(-10, shareButton.frame.origin.y+shareButton.frame.size.height, mainView.frame.size.width, 50)];
    [formButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [formButton addTarget:self action:@selector(formButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [formButton setTitle:@"فرم تخفیف" forState:UIControlStateNormal];
    formButton.titleLabel.font = FONT_NORMAL(15);
    //[mainView addSubview:formButton];
    //[menuScrollView addSubview:formButton];
    
    //164*164
    UIImageView *formImageView = [[UIImageView alloc] initWithFrame:CGRectMake(formButton.frame.size.width-33, 10, 30,30)];
    formImageView.image = [UIImage imageNamed:@"menuCustomerForm"];
    formImageView.backgroundColor = [UIColor whiteColor];
    formImageView.contentMode = UIViewContentModeScaleAspectFit;
    formImageView.userInteractionEnabled = YES;
    //[formButton addSubview: formImageView];
    
    //UIButton *signInButton = [[UIButton alloc]initWithFrame:CGRectMake(-10, formButton.frame.origin.y+formButton.frame.size.height,MENU_WIDTH,50)];
    UIButton *signInButton = [[UIButton alloc]initWithFrame:CGRectMake(-10, shareButton.frame.origin.y+shareButton.frame.size.height, mainView.frame.size.width, 50)];
    [signInButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [signInButton addTarget:self action:@selector(signInButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [signInButton setTitle:@"ثبت نام/ورود" forState:UIControlStateNormal];
    signInButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:signInButton];
    //[menuScrollView addSubview:signInButton];
    
    UIImageView *signInImageView = [[UIImageView alloc] initWithFrame:CGRectMake(signInButton.frame.size.width-33, 10, 30,30)];
    signInImageView.image = [UIImage imageNamed:@"menuCustomerForm"];
    signInImageView.backgroundColor = [UIColor whiteColor];
    signInImageView.contentMode = UIViewContentModeScaleAspectFit;
    signInImageView.userInteractionEnabled = YES;
    [signInButton addSubview: signInImageView];//UIButton *shoppingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, formButton.frame.origin.y+formButton.frame.size.height,MENU_WIDTH,50)];
    //UIButton *shoppingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, shareButton.frame.origin.y+shareButton.frame.size.height,MENU_WIDTH,50)];
    
    UIButton *shoppingButton = [[UIButton alloc]initWithFrame:CGRectMake(-10, signInButton.frame.origin.y+signInButton.frame.size.height, mainView.frame.size.width, 50)];
    [shoppingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [shoppingButton addTarget:self action:@selector(shoppingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [shoppingButton setTitle:@"سبد خرید" forState:UIControlStateNormal];
    shoppingButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:shoppingButton];
    
    UIImageView *shoppingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(formButton.frame.size.width-33, 10, 30,30)];
    shoppingImageView.image = [UIImage imageNamed:@"menuCustomerForm"];
    shoppingImageView.backgroundColor = [UIColor whiteColor];
    shoppingImageView.contentMode = UIViewContentModeScaleAspectFit;
    shoppingImageView.userInteractionEnabled = YES;
    [shoppingButton addSubview: shoppingImageView];
    
    //UIButton *aboutusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, formButton.frame.origin.y+formButton.frame.size.height,MENU_WIDTH,50)];
    //UIButton *aboutusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, shareButton.frame.origin.y+shareButton.frame.size.height,MENU_WIDTH,50)];
    //UIButton *aboutusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, signInButton.frame.origin.y+signInButton.frame.size.height,MENU_WIDTH,50)];
    UIButton *aboutusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, shoppingButton.frame.origin.y+shoppingButton.frame.size.height,MENU_WIDTH,50)];
    [aboutusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [aboutusButton addTarget:self action:@selector(aboutusButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [aboutusButton setTitle:@"درباره ما" forState:UIControlStateNormal];
    aboutusButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:aboutusButton];
    //[menuScrollView addSubview:aboutusButton];
    
    UIImageView *aboutusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(aboutusButton.frame.size.width-45, 7.5, 35,35)];
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

#pragma mark  Sharing action of menu item
-(void)shareButtonAction:(UIButton *)button{
    NSString *textToShare1 = App_Name;
    NSString *textToShare2 = @"\nبا نصب این اپلیکیشن همواره از آخرین مطالب آن آگاه باشید";
    NSString *textToShare3 = [[NSUserDefaults standardUserDefaults]objectForKey:@"downloadLink"];
    NSString *textToShare = [NSString stringWithFormat:@"%@\n%@\n%@\n",textToShare1,textToShare2,textToShare3];
    NSArray *objectsToShare2 = @[textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare2 applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(void)formButtonAction:(UIButton *)button{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FormViewController *view = (FormViewController *)[story instantiateViewControllerWithIdentifier:@"FormViewController"];
    view.titleText = button.titleLabel.text;
    [self.navigationController pushViewController:view animated:YES];
}

-(void)signInButtonAction{
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    SignInViewController *view = (SignInViewController *)[story instantiateViewControllerWithIdentifier:@"SignInViewController"];
//    //view.titleText = button.titleLabel.text;
//    [self.navigationController pushViewController:view animated:YES];
    [self menuButtonAction];
}

-(void)shoppingButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShoppingViewController *view = (ShoppingViewController *)[story instantiateViewControllerWithIdentifier:@"ShoppingViewController"];
    //view.titleText = button.titleLabel.text;
    [self.navigationController pushViewController:view animated:YES];
}

-(void)aboutusButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthorViewController *view = (AuthorViewController *)[story instantiateViewControllerWithIdentifier:@"AuthorViewController"];
    view.author_id = [@"1" integerValue];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)designTeamButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AboutusViewController *view = (AboutusViewController *)[story instantiateViewControllerWithIdentifier:@"AboutusViewController"];
    [self.navigationController pushViewController:view animated:YES];
}


- (void)backButtonImgAction{
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"dismissIntroView"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"dismissIntroView" object:nil];
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self menuButtonAction];
}

- (void)tapGestureAction:(UITapGestureRecognizer*)gestureRecognizer
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

- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTimeLine" object:nil];
}

- (void)sendButtonAction{
    [self dismissTextField];
    if (![self isNumeric:phoneTextField.text] ||
        [phoneTextField.text length] != 11) {
        [ShakeAnimation startShake:phoneTextField];
        return;
    }
    
    if ([self hasConnectivity]) {
        [self loginConnection];
       // [self pushToEnterCode];
    }else{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@""
                                      message:@"شما در حالت آفلاین هستید. ابتدا آیفون را به اینترنت متصل کنید."
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"بستن"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)codeTaeedButtonAction{
    [self pushToEnterCode];
}

- (void)dismissTextField{
    if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8 || IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8){
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = 0;
            [self.view setFrame:rect];
            
        }];
    }
    if(IS_IPHONE_6_IOS7 || IS_IPHONE_6_IOS8){
        [UIView animateWithDuration:0.4 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = 0;
            [self.view setFrame:rect];
            
        }];
    }
    
    [phoneTextField resignFirstResponder];
}

-(BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    if ([inputString length] > 0) {
        NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
        isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    }
    
    return isValid;
}

- (void)pushToEnterCode{
    //[self dismissViewControllerAnimated:YES completion:nil];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EnterCodViewController *view = (EnterCodViewController *)[story instantiateViewControllerWithIdentifier:@"EnterCodViewController"];
    view.mobileString = [[NSUserDefaults standardUserDefaults]objectForKey:@"mobile"];
    [self.navigationController pushViewController:view animated:YES];
    //[self presentViewController:view animated:YES completion:nil];
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 354) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 11;
    }else{
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y -= 50;
            [self.view setFrame:rect];
            
        }];
    }
    if (IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8 || IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y -= 170;
            [self.view setFrame:rect];
            
        }];
    }
    if(IS_IPHONE_6_IOS7 || IS_IPHONE_6_IOS8){
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y -= 120;
            [self.view setFrame:rect];
            
        }];
    }

}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [self dismissTextField];
    return YES;
}

-(void)textFieldDidChange :(UITextField *)textField{
    if ([textField.text length] >=2) {
        textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"09"];
    }
    
    phoneTextField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneTextField.text = [textField.text stringByReplacingOccurrencesOfString:@"0098" withString:@"0"];
    phoneTextField.text = [textField.text stringByReplacingOccurrencesOfString:@"+98" withString:@"0"];
    phoneTextField.text = phoneTextField.text;
}

#pragma mark - connection
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

- (void)loginConnection{
    if ([phoneTextField.text length] != 11) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"شماره موبایل باید ۱۱ رقم باشد" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [ProgressHUD show:@"در حال دریافت اطلاعات..." Interaction:NO];
    NSDictionary *params = @{@"username":[ReplacerEngToPer replacer:phoneTextField.text]
                             };
    NSString *url = @"http://catalogtest.yarima.co/mobiles/register";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *dict = responseObject;
        NSString *success =  [dict objectForKey:@"success"];
        if ([success integerValue] == 1) {
            NSInteger userID = [[[responseObject objectForKey:@"data"]objectForKey:@"id"]integerValue];
            NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
            [defualt setObject:phoneTextField.text forKey:@"mobile"];
            [defualt setObject:@"YES" forKey:@"waitForEnterCode"];
            [defualt setObject:[NSNumber numberWithInteger:userID] forKey:@"userID"];
            [self pushToEnterCode];
        } else {
            NSString *alertMessage = [responseObject objectForKey:@"message"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"") message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:NSLocalizedString(@"errorinData", @"")
                                      message:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", @"")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
}
@end
