//
//  ViewController.m
//  Catalog
//
//  Created by Developer on 1/18/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "ViewController.h"
#import "Header.h"
#import "DetailsViewController.h"
#import "LandingPageCustomCell.h"
#import "AboutusViewController.h"
#import "DetailsViewController.h"
#import "CategoriesViewController.h"
#import "AboutusViewController.h"
#import "AuthorViewController.h"
#import "DocumentDirectoy.h"
#import "SplashViewController.h"
#import "InboxViewController.h"
#import "FormViewController.h"
#import "ConvertHexToColor.h"
#import "SignInViewController.h"
#import "ShoppingViewController.h"

#define MENU_WIDTH  screenWidth/1.5
@interface ViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>
{
    BOOL isBusyNow;
    UILabel *titleLabel;
    UIRefreshControl *refreshControl;
    BOOL noMoreData;
    NSString *dateStringTopOfList;
    NSString *dateStringEndOfList;
    BOOL isMenuShown;
    UIView *mainView;
    UIView *backViewForImage;
    UIView *tranparentView;
    UILabel *noResultLabelPost;
    NSString *_categoryId;
    NSString *_categoryName;
    NSString *Title;
    NSMutableArray *categoryArray;
    NSInteger author_id;
    UIView *menuColorView;
    NSString *menuImageURL;
    CGFloat menuImageRatio;
    NSString *entrancePage;
    UIImageView *logoImageView;
    UIButton *newPostCountButton;
    NSString *color1;
    NSString *color2;
    NSString *downloadLink;
    NSArray *objectsToShare;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    //[self refreshTable];
    if ([self hasConnectivity]) {
        if ([dateStringTopOfList length] == 0) {
            [self fetchNewPostCountWithDate:@""];
        } else {
            [self fetchNewPostCountWithDate:dateStringTopOfList];
        }
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    [refreshControl endRefreshing];
}

- (void)viewDidDisappear:(BOOL)animated{
    if (isMenuShown) {
        [self menuButtonAction];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma mark - Comment this Line if Push is not needed
    [self registerDeviceTokenOnServer:nil];
    
    NSString *firstLaunch = [[NSUserDefaults standardUserDefaults]objectForKey:@"firstLaunch"];
    
    if ([firstLaunch length]==0) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SplashViewController *view = (SplashViewController *)[story instantiateViewControllerWithIdentifier:@"SplashViewController"];
        [self presentViewController:view animated:NO completion:nil];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"firstLaunch"];
    }
    
    if ([self hasConnectivity]) {
        
        //        NSString *registerToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
        //
        //        if ([registerToken length] == 0) {
        //            [self registerDeviceTokenOnServer];
        //        }
        
        [self fetchAuthorInfo:[CUSTOMER_AUTHOR_ID integerValue]];
        
        [self fetchCategories];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [self makeTopBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, screenWidth ,screenHeight - 64)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self menuView];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    [self populateTableViewArray];
    
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
    
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchPostForCategory:) name:@"setCategory" object:nil];
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchPostForCategory2:) name:@"setCategory2" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(populateTableViewArray) name:@"reloadTableview" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(NavigateToInboxVC:) name:@"NavigateToInbox" object:nil];
#pragma mark - Comment this Line if Push is not needed
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerDeviceTokenOnServer:) name:@"registerDeviceTokenOnServer" object:nil];
    
    if ([self hasConnectivity]) {
        if ([dateStringTopOfList length] == 0) {
            [self fetchNewPostCountWithDate:@""];
        } else {
            [self fetchNewPostCountWithDate:dateStringTopOfList];
        }
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
    
    //54*39
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-50, 20, 64 * 0.5, 64 * 0.5)];
    [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UIImage *menuImageNormal = [UIImage imageNamed:@"menu"];
    [menuButton setBackgroundImage:menuImageNormal forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuButton];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = @"خانه";
    titleLabel.numberOfLines = 1;
    titleLabel.font = FONT_MEDIUM(20);
    titleLabel.baselineAdjustment = YES;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.clipsToBounds = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    UIButton *categoryButton = [[UIButton alloc]initWithFrame:CGRectMake(18, 20, 64 * 0.5, 64 * 0.5)];
    [categoryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UIImage *buttonImageNormal = [UIImage imageNamed:@"homeCategory"];
    [categoryButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    [categoryButton addTarget:self action:@selector(categoriesButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:categoryButton];
}

-(void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) tapAction:(UIGestureRecognizer *)tap{
    NSDictionary *dic = [_tableArray objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthorViewController *view = (AuthorViewController *)[story instantiateViewControllerWithIdentifier:@"AuthorViewController"];
    author_id = [dic.LPTVUserEntityId integerValue];
    view.author_id = author_id;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)refreshTable{
    //dispatch_async(dispatch_get_main_queue(), ^{
    titleLabel.text = @"خانه";
    ////scrolls to top
    [self.tableView setContentOffset:CGPointZero];
    [newPostCountButton removeFromSuperview];
    //[self fetchCategories];
    [refreshControl endRefreshing];
    if ([dateStringTopOfList length] == 0) {
        [self fetchOLDPostWithCategory:@"" WithRequest:@"" WithDate:@""];
    } else {
        [self fetchNEWPostWithCategory:@"" WithRequest:@"" WithDate:dateStringTopOfList];
    }
}

- (NSArray *)sort:(NSArray *)inputArray{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postId"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [inputArray sortedArrayUsingDescriptors:sortDescriptors];
    return  sortedArray;
}

- (void)populateTableViewArray{
    //datebase
    [Database initDB];
    self.tableArray = [[NSMutableArray alloc]init];
    //self.tableView.dataSource = nil;
    NSArray *array = [Database selectFromLandingPageWithFilePath:[Database getDbFilePath]];
    //array = [self sort:array];
    if ([array count] > 0) {
        for (NSDictionary *dic in array) {
            [self.tableArray addObject:dic];
        }
        dateStringTopOfList = [[self.tableArray firstObject]LPTVPublish_date];
        dateStringEndOfList = [[self.tableArray lastObject]LPTVPublish_date];
        [self.tableView reloadData];
        NSString *selectedRowFromPush = [[NSUserDefaults standardUserDefaults]objectForKey:@"selectedRow"];
        if ([selectedRowFromPush length] > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[selectedRowFromPush integerValue] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"selectedRow"];
        }
        self.tableView.scrollsToTop = YES;
        NSString *isFirstRun = [[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstRun"];
        if ([isFirstRun length] == 0) {
            if ([self hasConnectivity]) {
                if ([dateStringTopOfList length] == 0) {
                    [self fetchOLDPostWithCategory:@"" WithRequest:@"" WithDate:@""];
                } else {
                    [self fetchNEWPostWithCategory:@"" WithRequest:@"" WithDate:dateStringTopOfList];
                }
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else{
            [self.tableView reloadData];
            self.tableView.scrollsToTop = YES;
        }
    }else{
        if ([self hasConnectivity]) {
            [self fetchOLDPostWithCategory:@"" WithRequest:@"" WithDate:@""];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)populateTableViewArrayForCategory{
    //datebase
    [Database initDB];
    self.tableArray = [[NSMutableArray alloc]init];
    //self.tableView.dataSource = nil;
    NSArray *array = [Database selectFromLandingPageWithFilePath:[Database getDbFilePath]];
    array = [self sort:array];
    if ([array count] > 0) {
        for (NSDictionary *dic in array) {
            [self.tableArray addObject:dic];
        }
        [self.tableView reloadData];
        NSString *selectedRowFromPush = [[NSUserDefaults standardUserDefaults]objectForKey:@"selectedRow"];
        if ([selectedRowFromPush length] > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[selectedRowFromPush integerValue] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"selectedRow"];
        }
        self.tableView.scrollsToTop = YES;
        NSString *isFirstRun = [[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstRun"];
        if ([isFirstRun length] == 0) {
            if ([self hasConnectivity]) {
                if ([dateStringTopOfList length] == 0) {
                    [self fetchOLDPostWithCategory:@"" WithRequest:@"" WithDate:@""];
                } else {
                    [self fetchNEWPostWithCategory:@"" WithRequest:@"" WithDate:dateStringTopOfList];
                }
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else{
            [self.tableView reloadData];
            self.tableView.scrollsToTop = YES;
        }
    }else{
        [self.tableView reloadData];
        [noResultLabelPost removeFromSuperview];
        
        if ([self.tableArray count] == 0) {
            noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
            noResultLabelPost.font = FONT_MEDIUM(13);
            noResultLabelPost.text = @"لیست خالی است";
            noResultLabelPost.minimumScaleFactor = 0.7;
            NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
            if ([customColor length]>0) {
                UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
                noResultLabelPost.textColor = color;
            } else {
                noResultLabelPost.textColor = MAIN_COLOR;
            }
            noResultLabelPost.textAlignment = NSTextAlignmentRight;
            noResultLabelPost.adjustsFontSizeToFitWidth = YES;
            [_tableView addSubview:noResultLabelPost];
        }
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
    
    menuColorView = [[UIView alloc] initWithFrame:CGRectMake(0,0,MENU_WIDTH,screenHeight/3)];
    menuColorView.backgroundColor = [UIColor whiteColor];  //MAIN_COLOR;
    menuColorView.userInteractionEnabled = NO;
    [mainView addSubview:menuColorView];
    
    backViewForImage = [[UIView alloc] initWithFrame:CGRectMake((menuColorView.frame.size.width/2)-75,(menuColorView.frame.size.height/2)-75,150,150)];
    backViewForImage.backgroundColor = [UIColor clearColor];
    backViewForImage.userInteractionEnabled = NO;
    [menuColorView addSubview:backViewForImage];
    
    //show native splash for menu image just if connection is broken,instead of showing 2 image cover each other
    if (![self hasConnectivity]) {
        if (logoImageView == nil) {
            logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewForImage.frame.size.width, backViewForImage.frame.size.height)];
            logoImageView.image =[UIImage imageNamed:@"nativeSplash"];
            logoImageView.userInteractionEnabled = YES;
            logoImageView.contentMode = UIViewContentModeScaleAspectFit;
            [backViewForImage addSubview: logoImageView];
        }
    }
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
    
    //164*164
    UIImageView *formImageView = [[UIImageView alloc] initWithFrame:CGRectMake(formButton.frame.size.width-33, 10, 30,30)];
    formImageView.image = [UIImage imageNamed:@"menuCustomerForm"];
    formImageView.backgroundColor = [UIColor whiteColor];
    formImageView.contentMode = UIViewContentModeScaleAspectFit;
    formImageView.userInteractionEnabled = YES;
    //[formButton addSubview: formImageView];
    
    //UIButton *signInButton = [[UIButton alloc]initWithFrame:CGRectMake(0, formButton.frame.origin.y+formButton.frame.size.height,MENU_WIDTH,50)];
    UIButton *signInButton = [[UIButton alloc]initWithFrame:CGRectMake(-10, shareButton.frame.origin.y+shareButton.frame.size.height, mainView.frame.size.width, 50)];
    [signInButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [signInButton addTarget:self action:@selector(signInButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [signInButton setTitle:@"ثبت نام/ورود" forState:UIControlStateNormal];
    signInButton.titleLabel.font = FONT_NORMAL(15);
    [mainView addSubview:signInButton];
    
    UIImageView *signInImageView = [[UIImageView alloc] initWithFrame:CGRectMake(signInButton.frame.size.width-33, 10, 30,30)];
    signInImageView.image = [UIImage imageNamed:@"menuCustomerForm"];
    signInImageView.backgroundColor = [UIColor whiteColor];
    signInImageView.contentMode = UIViewContentModeScaleAspectFit;
    signInImageView.userInteractionEnabled = YES;
    [signInButton addSubview: signInImageView];
    
    //UIButton *shoppingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, formButton.frame.origin.y+formButton.frame.size.height,MENU_WIDTH,50)];
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
    [noResultLabelPost removeFromSuperview];
    [self enablePullToRefresh];
    [self menuButtonAction];
    titleLabel.text = @"خانه";
    //    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    ViewController *view = (ViewController *)[story instantiateViewControllerWithIdentifier:@"ViewController"];
    //    [self.navigationController pushViewController:view animated:YES];
    NSArray *array = [Database selectFromLandingPageWithFilePath:[Database getDbFilePath]];
    self.tableArray = [[NSMutableArray alloc]initWithArray:array];
    [self.tableView reloadData];
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
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SignInViewController *view = (SignInViewController *)[story instantiateViewControllerWithIdentifier:@"SignInViewController"];
    //view.titleText = button.titleLabel.text;
    [self.navigationController pushViewController:view animated:YES];
}

-(void)shoppingButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShoppingViewController *view = (ShoppingViewController *)[story instantiateViewControllerWithIdentifier:@"ShoppingViewController"];
    //view.titleText = button.titleLabel.text;
    [self.navigationController pushViewController:view animated:YES];
}

-(void)shoppingButtonAction2{
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

-(void)moreButtonAction:(UIButton *)button{
    NSDictionary *dic = [_tableArray objectAtIndex:button.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailsViewController *view = (DetailsViewController *)[story instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    view.titleText = dic.LPTVTitle;
    view.dictionary = dic;
    [self.navigationController pushViewController:view animated:YES];
}
#pragma mark  Sharing action for each cell of table view
-(void)shareButtonAction2:(UIButton *)button{
    NSDictionary *dic = [_tableArray objectAtIndex:button.tag];
    NSString *textToShare1 = dic.LPTVTitle;//[NSString stringWithFormat:@"%@\n ",dic.LPTVTitle];
    NSString *textToShare2 = dic.LPTVContent;
    
    UIImageView *imageToShare = [[UIImageView alloc]init];
    imageToShare.contentMode = UIViewContentModeScaleAspectFit;
    NSString *tempName = [dic.LPTVImageUrl lastPathComponent];
    imageToShare.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]];
    //imageToShare.image = [UIImage imageNamed:@"nativeSplash"];
    
    NSString *textToShare3 = [NSString stringWithFormat:@" جهت دریافت اپلیکیشن %@، روی لینک زیر کلیک نمایید. ",App_Name];
    NSString *textToShare4 = [[NSUserDefaults standardUserDefaults]objectForKey:@"downloadLink"];
    NSString *textToShare = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n",textToShare1,textToShare2,textToShare3,textToShare4];
    //Handle crash if image is nil
    if (imageToShare.image != nil) {
        objectsToShare = @[imageToShare.image,textToShare];
    } else {
        objectsToShare = @[textToShare];
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
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

- (void)disablePullToRefresh{
    [refreshControl removeFromSuperview];
}

- (void)enablePullToRefresh{
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}
- (void)fetchPostForCategory:(NSNotification *)notif{
    [self disablePullToRefresh];
    dateStringTopOfList = @"";
    dateStringEndOfList = @"";
    NSLog(@"%@", notif.object);
    _categoryId = [NSString stringWithFormat:@"%ld", (long)[[notif.object objectForKey:@"id"]integerValue]];
    _categoryName = [NSString stringWithFormat:@"%@",[notif.object objectForKey:@"name"]];
    titleLabel.text = _categoryName;
    
    //[Database deleteLandingPageWithFilePath:[Database getDbFilePath]];
    //[self fetchPostWithCategory:catId WithRequest:@"" WithDate:@""];
    NSArray *array = [Database selectFromLandingPageWithTagName:_categoryName filePath:[Database getDbFilePath]];
    self.tableArray = [[NSMutableArray alloc]initWithArray:array];
    [self.tableView reloadData];
    [noResultLabelPost removeFromSuperview];
    if ([self.tableArray count] == 0) {
        noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
        noResultLabelPost.font = FONT_MEDIUM(13);
        noResultLabelPost.text = @"لیست خالی است";
        noResultLabelPost.minimumScaleFactor = 0.7;
        NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            noResultLabelPost.textColor = color;
        } else {
            noResultLabelPost.textColor = MAIN_COLOR;
        }
        noResultLabelPost.textAlignment = NSTextAlignmentRight;
        noResultLabelPost.adjustsFontSizeToFitWidth = YES;
        [_tableView addSubview:noResultLabelPost];
    }
}

- (void)fetchPostForCategory2:(NSNotification *)notif{
    [self disablePullToRefresh];
    dateStringTopOfList = @"";
    dateStringEndOfList = @"";
    NSLog(@"%@", notif.object);
    _categoryId = [NSString stringWithFormat:@"%ld", (long)[[notif.object objectForKey:@"id"]integerValue]];
    _categoryName = [NSString stringWithFormat:@"%@",[notif.object objectForKey:@"name"]];
    titleLabel.text = _categoryName;
    
    //[Database deleteLandingPageWithFilePath:[Database getDbFilePath]];
    //[self fetchPostWithCategory:catId WithRequest:@"" WithDate:@""];
    NSArray *array = [Database selectFromLandingPageWithCategoryID:_categoryId filePath:[Database getDbFilePath]];
    self.tableArray = [[NSMutableArray alloc]initWithArray:array];
    [self.tableView reloadData];
    [noResultLabelPost removeFromSuperview];
    if ([self.tableArray count] == 0) {
        noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 220, 10, 200,  25)];
        noResultLabelPost.font = FONT_MEDIUM(13);
        noResultLabelPost.text = @"لیست خالی است";
        noResultLabelPost.minimumScaleFactor = 0.7;
        NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            noResultLabelPost.textColor = color;
        } else {
            noResultLabelPost.textColor = MAIN_COLOR;
        }
        noResultLabelPost.textAlignment = NSTextAlignmentRight;
        noResultLabelPost.adjustsFontSizeToFitWidth = YES;
        [_tableView addSubview:noResultLabelPost];
    }
}

- (void)NavigateToInboxVC:(NSNotification *)notif{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InboxViewController *view = (InboxViewController *)[story instantiateViewControllerWithIdentifier:@"InboxViewController"];
    [self.navigationController pushViewController:view animated:YES];
}
#pragma mark  download Menu image(native Splash)
- (void)getImageWithURL:(NSString *)url{
    NSString *baseUrl1 = BaseURL4;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl1, url]];
        NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
        if (fileData) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self saveImageIntoDocumetsWithData:fileData withName:[NSString stringWithFormat:@"%@", fileURL]];
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
    
    [[NSUserDefaults standardUserDefaults]setObject:tempName forKey:@"menuImage"];
    
    NSString *imgFileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]stringByAppendingPathComponent:tempName];
    //create the file
    [[NSFileManager defaultManager] createFileAtPath:imgFileName contents:imageData attributes:nil];
    //[self hideHUD];
    
    logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewForImage.frame.size.width, backViewForImage.frame.size.height)];
    // logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, MENU_WIDTH - 60, ((MENU_WIDTH - 60) / menuImageRatio))];
    tempName = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuImage"];
    logoImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.userInteractionEnabled = YES;
    [backViewForImage addSubview: logoImageView];
}

#pragma mark  download post image for sharing
- (void)getPostImageWithURL:(NSString *)url{
    NSString *baseUrl2 = BaseURL4;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSURL *fileURL2 = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl2, url]];
        NSData *fileData2 = [NSData dataWithContentsOfURL:fileURL2];
        if (fileData2) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self savePostImageIntoDocumetsWithData:fileData2 withName:[NSString stringWithFormat:@"%@", fileURL2]];
            });
        }else{
            fileURL2 = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl2, url]];
            fileData2 = [NSData dataWithContentsOfURL:fileURL2];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self savePostImageIntoDocumetsWithData:fileData2 withName:[NSString stringWithFormat:@"%@", fileURL2]];
            });
        }
    });
}

- (void)savePostImageIntoDocumetsWithData:(NSData*)imageData withName:(NSString*)imageName{
    
    NSString *tempName2 = [imageName lastPathComponent];
    NSString *imgFileName2 = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]stringByAppendingPathComponent:tempName2];
    //create the file
    [[NSFileManager defaultManager] createFileAtPath:imgFileName2 contents:imageData attributes:nil];
}

- (void) navigateToCategories{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CategoriesViewController *view = (CategoriesViewController *)[story instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

-(void) navigateToAuthorVC{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthorViewController *view = (AuthorViewController *)[story instantiateViewControllerWithIdentifier:@"AuthorViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (NSArray *)sortCategory:(NSArray *)inputArray{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [inputArray sortedArrayUsingDescriptors:sortDescriptors];
    return  sortedArray;
}

- (NSArray *)sortPost:(NSArray *)inputArray{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [inputArray sortedArrayUsingDescriptors:sortDescriptors];
    return  sortedArray;
}

- (void) newPostCountButtonAction{
    [self refreshTable];
}
#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        if ([_categoryId length] == 0) {
            if ([self hasConnectivity]) {
                // we are at the end
                [self fetchOLDPostWithCategory:@"" WithRequest:@"" WithDate:dateStringEndOfList];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"start drag");
    newPostCountButton.hidden = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"end dragging");
    newPostCountButton.hidden = NO;
}

#pragma mark - TableView DataSource Implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPHONE_5_IOS7||IS_IPHONE_5_IOS8 ) {
        return TABLEVIEW_CELL_HEIGHT-20;
    }
    if (IS_IPHONE_6_IOS7||IS_IPHONE_6_IOS8 ) {
        return TABLEVIEW_CELL_HEIGHT+20;
    }
    if (IS_IPHONE_6P_IOS7||IS_IPHONE_6P_IOS8 ) {
        return TABLEVIEW_CELL_HEIGHT+40;
    }
    
    return TABLEVIEW_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LandingPageCustomCell *cell = (LandingPageCustomCell *)[[LandingPageCustomCell alloc]
                                                            initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    NSDictionary *dic = [_tableArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = dic.LPTVTitle;
    
    cell.placeholderImage.image = [UIImage imageNamed:@"placeholder"];
    
    [cell.postImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2,dic.LPTVImageUrl]] placeholderImage:[UIImage imageNamed:@"placeholder_"]];
    
    [self getPostImageWithURL:dic.LPTVImageUrl];
    
    [cell.shoppingButton addTarget:self action:@selector(shoppingButtonAction2) forControlEvents:UIControlEventTouchUpInside];
    //[cell.shoppingButton setTitle:@"۱۰۰۰۰ تومان" forState:UIControlStateNormal];
    cell.shoppingButton.tag = indexPath.row;
    
    cell.shoppingLabel.text = @"۱۰۰۰۰ تومان";
    
    cell.discountLabel.text = @"50000";

    [cell.authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2,dic.LPTVUserAvatarUrl]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    cell.authorImageView.tag = indexPath.row;
    cell.authorImageView.userInteractionEnabled = YES;
    [cell.authorImageView addGestureRecognizer:tap];
    
    cell.authorNameLabel.text = dic.LPTVUserTitle;
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    cell.authorNameLabel.tag = indexPath.row;
    cell.authorNameLabel.userInteractionEnabled = YES;
    [cell.authorNameLabel addGestureRecognizer:tap2];
    
    [cell.moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.moreButton.tag = indexPath.row;
    
    [cell.shareButton addTarget:self action:@selector(shareButtonAction2:) forControlEvents:UIControlEventTouchUpInside];
    cell.shareButton.tag = indexPath.row;
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineSpacing:10];
    paragraph.alignment = NSTextAlignmentJustified;
    paragraph.baseWritingDirection = NSWritingDirectionRightToLeft;
    paragraph.firstLineHeadIndent = 1.0;
    NSDictionary* attributes = @{
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSParagraphStyleAttributeName: paragraph,
                                 NSFontAttributeName:FONT_NORMAL(13)
                                 };
    NSAttributedString* aString = [[NSAttributedString alloc] initWithString:dic.LPTVContent attributes: attributes];
    cell.contentLabel.attributedText = aString;
    
    UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(15, TABLEVIEW_CELL_HEIGHT- 2, screenWidth - 30, 1)];
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        lineView.backgroundColor = color;
    } else {
        lineView.backgroundColor = MAIN_COLOR;
    }
    [cell addSubview:lineView];
    
    if (IS_IPHONE_5_IOS7||IS_IPHONE_5_IOS8 ) {
        CGRect rect = lineView.frame;
        rect.origin.y = TABLEVIEW_CELL_HEIGHT-20-2;
        lineView.frame = rect;
    }
    if (IS_IPHONE_6_IOS7||IS_IPHONE_6_IOS8 ) {
        CGRect rect = lineView.frame;
        rect.origin.y = TABLEVIEW_CELL_HEIGHT+20-2;
        lineView.frame = rect;
    }
    if (IS_IPHONE_6P_IOS7||IS_IPHONE_6P_IOS8 ) {
        CGRect rect = lineView.frame;
        rect.origin.y = TABLEVIEW_CELL_HEIGHT+40-2;
        lineView.frame = rect;
    }
    
    NSString *iconUrl = @"";
    for (NSInteger i = 0; i < [categoryArray count]; i++) {
        if ([dic.LPTVCategoryId integerValue] == [[[categoryArray objectAtIndex:i]objectForKey:@"id"]integerValue]) {
            iconUrl = [[categoryArray objectAtIndex:i]objectForKey:@"icon"];
            break;
        }
    }
    //[cell.categoryImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2,iconUrl]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    //220x180
    if ([dic.LPTVVideoUrl isEqualToString:@"1"]) {
        cell.videoImageView.image = [UIImage imageNamed:@"has_video"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dic = [_tableArray objectAtIndex:indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailsViewController *view = (DetailsViewController *)[story instantiateViewControllerWithIdentifier:@"DetailsViewController"];
    view.titleText = dic.LPTVTitle;
    view.dictionary = dic;
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
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0){
                // if target host is not reachable
                return NO;
            }
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0){
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)){
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN){
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    return NO;
}

- (void)fetchNEWPostWithCategory:(NSString *)categoryId WithRequest:(NSString *)request WithDate:(NSString *)date{
    if (![self hasConnectivity]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [refreshControl endRefreshing];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [noResultLabelPost removeFromSuperview];
    [ProgressHUD show:@""];
    if ([date length] == 0) {
        date = @"";
    }
    NSDictionary *params = @{
                             @"date":date,
                             @"imei":UDID,
                             @"category_id":categoryId,
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    /*http://catalog2.yarima.co/mobiles/catalog_feeds_new*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_feeds_new", BaseURL3];
    
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
        manager.requestSerializer.timeoutInterval = 45;
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            if ([[tempDic objectForKey:@"feeds"]count] > 0) {//new data
                [Database deleteLandingPageWithFilePath:[Database getDbFilePath]];
            }
            NSInteger counter = 0;
            for (NSDictionary *post in [tempDic objectForKey:@"feeds"]) {
                counter++;
                if (counter == 1) {
                    dateStringTopOfList = post.LPPublish_date;
                }
                
                if (counter == [[tempDic objectForKey:@"feeds"]count]) {
                    dateStringEndOfList = post.LPPublish_date;
                }
                
                [Database insertIntoLandingPageWithFilePath:[Database getDbFilePath] postID:post.LPPostID title:post.LPTitle content:post.LPContent contentSummary:post.LPContentSummary contentHTML:post.LPContentHTML imageUrl:post.LPImageUrl publish_date:post.LPPublish_date categoryId:post.LPCategoryId categoryName:post.LPCategoryName userAvatarUrl:post.LPUserAvatarUrl userTitle:post.LPUserTitle userJobTitle:post.LPUserJobTitle userPageId:post.LPUserPageId userEntity:post.LPUserEntity userEntityId:post.LPUserEntityId likes_count:[NSString stringWithFormat:@"%ld",(long)post.LPLikes_count] recommends_count:post.LPRecommends_count favorites_count:post.LPFavorites_count liked:post.LPLiked favorite:post.LPFavorite recommended:post.LPRecommended tags:post.LPTags postType:post.LPPostType audioUrl:post.LPAudioUrl videoUrl:post.LPVideoUrl audioSize:post.LPAudioSize videoSize:post.LPVideoSize videoSnapShot:@"" votingOptions:nil priority:[[post objectForKey:@"priority"]integerValue]];
            }
            [Database deleteDuplicateDataLandingPageWithFilePath:[Database getDbFilePath]];
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            isBusyNow = NO;
            [self populateTableViewArray];
            if ([[tempDic objectForKey:@"posts"]count] > 0) {
                [self populateTableViewArray];
            }else{
                noMoreData = YES;
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@".خطای سرور٬لطفا دوباره تلاش کنید" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [refreshControl endRefreshing];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
}

- (void)fetchOLDPostWithCategory:(NSString *)categoryId WithRequest:(NSString *)request WithDate:(NSString *)date{
    if (![self hasConnectivity]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [refreshControl endRefreshing];
            //self.tableView.refreshControl = nil;
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [noResultLabelPost removeFromSuperview];
    [ProgressHUD show:@""];
    if ([date length] == 0) {
        date = @"";
    }
    NSDictionary *params = @{
                             @"date":date,
                             @"imei":UDID,
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    
    /*http://catalog2.yarima.co/mobiles/catalog_feeds_old*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_feeds_old", BaseURL3];
    
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
        manager.requestSerializer.timeoutInterval = 45;
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            //if ([date length] == 0) {//new data for first run
            if ([[tempDic objectForKey:@"feeds"]count] > 0 && [date length] == 0) {//new data
                [Database deleteLandingPageWithFilePath:[Database getDbFilePath]];
            }
            NSInteger counter = 0;
            for (NSDictionary *post in [tempDic objectForKey:@"feeds"]) {
                counter++;
                if (counter == 1) {
                    dateStringTopOfList = post.LPPublish_date;
                }
                
                if (counter == [[tempDic objectForKey:@"feeds"]count]) {
                    dateStringEndOfList = post.LPPublish_date;
                }
                
                [Database insertIntoLandingPageWithFilePath:[Database getDbFilePath] postID:post.LPPostID title:post.LPTitle content:post.LPContent contentSummary:post.LPContentSummary contentHTML:post.LPContentHTML imageUrl:post.LPImageUrl publish_date:post.LPPublish_date categoryId:post.LPCategoryId categoryName:post.LPCategoryName userAvatarUrl:post.LPUserAvatarUrl userTitle:post.LPUserTitle userJobTitle:post.LPUserJobTitle userPageId:post.LPUserPageId userEntity:post.LPUserEntity userEntityId:post.LPUserEntityId likes_count:[NSString stringWithFormat:@"%ld",(long)post.LPLikes_count] recommends_count:post.LPRecommends_count favorites_count:post.LPFavorites_count liked:post.LPLiked favorite:post.LPFavorite recommended:post.LPRecommended tags:post.LPTags postType:post.LPPostType audioUrl:post.LPAudioUrl videoUrl:post.LPVideoUrl audioSize:post.LPAudioSize videoSize:post.LPVideoSize videoSnapShot:@"" votingOptions:nil priority:[[post objectForKey:@"priority"]integerValue]];
            }
            [Database deleteDuplicateDataLandingPageWithFilePath:[Database getDbFilePath]];
            [self populateTableViewArray];
            if ([[tempDic objectForKey:@"feeds"]count] > 0) {
                [self populateTableViewArray];
            }else{
                noMoreData = YES;
            }
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            isBusyNow = NO;
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور٬لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [refreshControl endRefreshing];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
}

- (void)fetchPostWithCategory:(NSString *)categoryId WithRequest:(NSString *)request WithDate:(NSString *)date{
    [noResultLabelPost removeFromSuperview];
    [ProgressHUD show:@""];
    if ([date length] == 0) {
        date = @"";
    }
    NSDictionary *params = @{
                             @"date":[NSString stringWithFormat:@"%@", [NSDate date]],
                             @"imei":UDID,
                             @"category_id":categoryId,
                             @"author_id":YARIMA_AUTHOR_ID
                             };
    
    /*http://catalog2.yarima.co/mobiles/catalog_feeds_old*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_feeds_old", BaseURL3];
    
    if (!isBusyNow) {
        isBusyNow = YES;
        [refreshControl endRefreshing];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
        manager.requestSerializer.timeoutInterval = 45;
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
            [ProgressHUD dismiss];
            NSDictionary *tempDic = (NSDictionary *)responseObject;
            if ([[tempDic objectForKey:@"feeds"]count] > 0) {//new data
                [Database deleteLandingPageWithFilePath:[Database getDbFilePath]];
            }
            NSInteger counter = 0;
            for (NSDictionary *post in [tempDic objectForKey:@"feeds"]) {
                counter++;
                if (counter == 1) {
                    dateStringTopOfList = post.LPPublish_date;
                }
                
                if (counter == [[tempDic objectForKey:@"feeds"]count]) {
                    dateStringEndOfList = post.LPPublish_date;
                }
                
                [Database insertIntoLandingPageWithFilePath:[Database getDbFilePath] postID:post.LPPostID title:post.LPTitle content:post.LPContent contentSummary:post.LPContentSummary contentHTML:post.LPContentHTML imageUrl:post.LPImageUrl publish_date:post.LPPublish_date categoryId:post.LPCategoryId categoryName:post.LPCategoryName userAvatarUrl:post.LPUserAvatarUrl userTitle:post.LPUserTitle userJobTitle:post.LPUserJobTitle userPageId:post.LPUserPageId userEntity:post.LPUserEntity userEntityId:post.LPUserEntityId likes_count:[NSString stringWithFormat:@"%ld",(long)post.LPLikes_count] recommends_count:post.LPRecommends_count favorites_count:post.LPFavorites_count liked:post.LPLiked favorite:post.LPFavorite recommended:post.LPRecommended tags:post.LPTags postType:post.LPPostType audioUrl:post.LPAudioUrl videoUrl:post.LPVideoUrl audioSize:post.LPAudioSize videoSize:post.LPVideoSize videoSnapShot:@"" votingOptions:nil priority:[[post objectForKey:@"priority"]integerValue]];
            }
            
            [Database deleteDuplicateDataLandingPageWithFilePath:[Database getDbFilePath]];
            
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            [ProgressHUD dismiss];
            isBusyNow = NO;
            
            //if ([[tempDic objectForKey:@"posts"]count] > 0) {
            [self populateTableViewArrayForCategory];
            //}else{
            noMoreData = YES;
            //}
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور٬لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [refreshControl endRefreshing];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            [ProgressHUD dismiss];
            isBusyNow = NO;
        }];
    }
}

- (void)fetchNewPostCountWithDate:(NSString *)date{
    [noResultLabelPost removeFromSuperview];
    //[ProgressHUD show:@""];
    if ([date length] == 0) {
        date = @"";
    }
    if ([dateStringTopOfList length] == 0) {
        dateStringTopOfList = @"";
    }
    NSDictionary *params = @{
                             //@"date":@"2015-04-12",
                             @"date":dateStringTopOfList,
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    
    /*http://catalog2.yarima.co/Mobiles/catalog_feeds_new_count*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_feeds_new_count", BaseURL3];
    [refreshControl endRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        //[ProgressHUD dismiss];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [newPostCountButton removeFromSuperview];
            newPostCountButton = [[UIButton alloc]initWithFrame:CGRectMake(20, screenHeight-40, 100, 30)];
            [newPostCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
            [newPostCountButton addTarget:self action:@selector(newPostCountButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [newPostCountButton setTitle:[NSString stringWithFormat:@"%@ مطلب جدید",[[tempDic objectForKey:@"count"]stringValue]] forState:UIControlStateNormal];
            //[newPostCountButton setTitle:@"۱۰۰ مطلب جدید" forState:UIControlStateNormal];
            newPostCountButton.titleLabel.font = FONT_NORMAL(13);
            newPostCountButton.backgroundColor = [UIColor darkGrayColor];
            [[newPostCountButton layer] setCornerRadius:15.0f];
            [[newPostCountButton layer] setMasksToBounds:YES];
            [[newPostCountButton layer] setBorderWidth:1.0f];
            [[newPostCountButton layer] setBorderColor:[UIColor darkGrayColor].CGColor];
            newPostCountButton.hidden = NO;
            if ([[tempDic objectForKey:@"count"]integerValue]>0) {
                [self.view addSubview:newPostCountButton];
            }
        });
        
        //[ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور٬لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [refreshControl endRefreshing];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        //[ProgressHUD dismiss];
    }];
}
- (void)fetchCategories{
    NSDictionary *params = @{
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    /*http://catalog2.yarima.co/mobiles/catalog_categories*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_categories", BaseURL3];
    
    [refreshControl endRefreshing];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        if ([tempDic valueForKey:@"category"]) {
            NSMutableArray *categoryArrayTemp = [[NSMutableArray alloc]init];
            for (NSDictionary *category in [tempDic objectForKey:@"category"]) {
                [categoryArrayTemp addObject:category];
            }
            categoryArray = [[NSMutableArray alloc]initWithArray:[self sortCategory:categoryArrayTemp]];
            [self.tableView reloadData];
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
        [ProgressHUD dismiss];
        NSDictionary *tempDic = [(NSDictionary *)responseObject objectForKey:@"author"];
        if ([[tempDic allKeys]count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        menuImageURL = [tempDic objectForKey:@"menu_image"];
        menuImageRatio = [[tempDic objectForKey:@"menu_image_ratio"]floatValue];
        color1 = [NSString stringWithFormat:@"%@", [tempDic objectForKey:@"color1"]];
        color2 = [NSString stringWithFormat:@"%@", [tempDic objectForKey:@"color2"]];
        if ([color1 length]>0) {
            //UIColor *myColor = [ConvertHexToColor colorWithHexString:color1];
            //NSLog(@"myColor = %@",myColor);
            //menuColorView.backgroundColor = myColor;
            [[NSUserDefaults standardUserDefaults]setObject:color1 forKey:@"customColor"];
        }else if ([color2 length]>0) {
            //UIColor *myColor = [ConvertHexToColor colorWithHexString:color2];
            //NSLog(@"myColor = %@",myColor);
            //menuColorView.backgroundColor = myColor;
            [[NSUserDefaults standardUserDefaults]setObject:color2 forKey:@"customColor"];
        }
        
        NSLog(@"menu_Image = %@",menuImageURL);
        NSLog(@"menu_Image_ratio = %f",menuImageRatio);
        NSLog(@"color1 = %@",color1);
        NSLog(@"color2 = %@",color2);
        if ([menuImageURL length]>0) {
            [self getImageWithURL:menuImageURL];
            
        } else {
            logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewForImage.frame.size.width, backViewForImage.frame.size.height)];
            //logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, MENU_WIDTH - 60, ((MENU_WIDTH - 60)))];
            logoImageView.image =[UIImage imageNamed:@"nativeSplash"];
            logoImageView.userInteractionEnabled = YES;
            logoImageView.contentMode = UIViewContentModeScaleAspectFit;
            [backViewForImage addSubview: logoImageView];
        }
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:menuImageRatio] forKey:@"menuImageRatio"];
        
        entrancePage = [[tempDic objectForKey:@"entrance_page"]objectForKey:@"id"];
        NSInteger entrancePageNumber = [entrancePage integerValue];
        
        switch (entrancePageNumber) {
            case 1://navigate Home VC
                //Do nothing because Home VC is showing.
                break;
            case 2://navigate Categories VC
                [self navigateToCategories];
                break;
            case 3://navigate Author VC
                [self navigateToAuthorVC];
                break;
            default:
                break;
        }
        downloadLink = [tempDic objectForKey:@"download_link"];
        NSLog(@"DownLoadLink = %@",downloadLink);
        [[NSUserDefaults standardUserDefaults]setObject:downloadLink forKey:@"downloadLink"];
    
    }failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور٬لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - Comment this Connection if Push is not needed
- (void)registerDeviceTokenOnServer:(NSNotification *)notif{
    //    NSString *isDeviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"registerDeviceToken"];
    //    if ([isDeviceToken isEqualToString:@"YES"]) {
    //        return;
    //    }
    //NSString *deviceToken = @"ksfjsklfjsf-sdf-sdfsdflsdfjdsfsldf";
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    NSInteger userID = [[[NSUserDefaults standardUserDefaults]objectForKey:@"userID"]integerValue];
    if ([deviceToken length] == 0) {
        return;
    }
    if (userID == 0) {
        userID = 0;
    }
    NSDictionary *params = @{@"push_key":deviceToken,
                             @"user_id":[NSNumber numberWithInteger:userID],
                             @"type":@"apple",
                             @"channel_id":@"5",
                             @"version_name":@"1.0",
                             @"imei": UDID
                             };
    NSString *url = @"http://notifpanel.yarima.co/web_services/push_notification/register_device";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 45;;
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        if ([[tempDic objectForKey:@"success"]integerValue] == 1) {
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"registerDeviceToken"];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}
@end
