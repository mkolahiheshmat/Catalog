//
//  webViewViewController.m
//  Catalog
//
//  Created by Developer on 1/23/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "webViewViewController.h"
#import "Header.h"
#import "AboutusViewController.h"
#import "CategoriesViewController.h"
#import "AboutusViewController.h"
#import "AuthorViewController.h"
#import "ViewController.h"
#import "DocumentDirectoy.h"
#import "InboxViewController.h"
#import "ConvertHexToColor.h"

#define MENU_WIDTH  screenWidth/1.5
@interface webViewViewController ()<UIWebViewDelegate>
{
    BOOL isMenuShown;
    UIView *mainView;
    UIView *tranparentView;
    NSString *url;
}
@end

@implementation webViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeTopBar];
    
    [self menuView];
    
    UIWebView *webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 64, screenWidth,screenHeight-64)];
    webview.delegate = self;
    
    if ([self.strURL containsString:@"http"]) {
        url = self.strURL;
    } else {
        url= [NSString stringWithFormat:@"http://%@", self.strURL];
    }
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webview loadRequest:nsrequest];
    [self.view addSubview:webview];
}
#pragma mark - Custom Methods
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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = self.topViewTitleText;
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

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
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
@end
