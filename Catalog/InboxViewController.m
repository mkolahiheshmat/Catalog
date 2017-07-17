//
//  InboxViewController.m
//  Catalog
//
//  Created by Developer on 1/29/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "InboxViewController.h"
#import "Header.h"
#import "CategoriesViewController.h"
#import "ViewController.h"
#import "AuthorViewController.h"
#import "AboutusViewController.h"
#import "InboxCustomCellTableViewCell.h"
#import "InboxDetailViewController.h"
#import "InboxViewController.h"
#import "PersianDate.h"
#import "ConvertHexToColor.h"

#define MENU_WIDTH  screenWidth/1.5
@interface InboxViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UILabel *titleLabel;
    BOOL isMenuShown;
    UIView *mainView;
    UIView *tranparentView;
    UIView *menuColorView;
    NSString *menuImageURL;
    CGFloat menuImageRatio;
    UIRefreshControl *refreshControl;
    BOOL noMoreData;
    NSString *dateStringTopOfList;
    NSString *dateStringEndOfList;
    UILabel *noResultLabelPost;
    NSString *message_id;
    NSInteger page;
    UILabel *offlineLabel;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;

@end

@implementation InboxViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    page = 1;
    self.tableArray = [[NSMutableArray alloc]init];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [self makeTopBar];
    
    if ([self hasConnectivity]) {
        offlineLabel.hidden = YES;
        [self fetchInbox];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            offlineLabel.hidden = NO;
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, screenWidth ,screenHeight - 64)];
    //self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    offlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, screenWidth-40,  25)];
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
    [self.tableView addSubview:offlineLabel];
    
    [self menuView];
    
    //refreshControl = [[UIRefreshControl alloc]init];
    //[self.tableView addSubview:refreshControl];
    //[refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeHandle:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    //[tranparentView addGestureRecognizer:rightRecognizer];
    
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
    rightEdgeGesture.delegate = self;
    //[self.view addGestureRecognizer:rightEdgeGesture];
}

#pragma mark - TableView DataSource Implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InboxCustomCellTableViewCell *cell = (InboxCustomCellTableViewCell *)[[InboxCustomCellTableViewCell alloc]
                                                            initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
    
    //cell.titleLabel.text = @"عنوان پیام";
    //cell.dateLabel.text = @"تاریخ ۱۰.۱۱.۹۵";
    //cell.contentLabel.text = @"متن خلاصه پیام";
    NSDictionary *dic = [_tableArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = [dic objectForKey:@"title"];
    
    //Change timestamp Date to persianDate
    double dateInMilliSeconds = [[dic objectForKey:@"date"]doubleValue];
    NSDate *normalDate = [NSDate dateWithTimeIntervalSince1970:dateInMilliSeconds];
    NSString *normalDateString = [NSString stringWithFormat:@"%@",normalDate];
    NSArray *dateComponentsArray = [normalDateString componentsSeparatedByString:@" "];
    NSArray *dashComponentsArray = [dateComponentsArray[0] componentsSeparatedByString:@"-"];
    PersianDate *persianDateInstance = [[PersianDate alloc]init];
    NSString *persianDateString = [persianDateInstance ConvertToPersianDateFinalWithYear:[[dashComponentsArray objectAtIndex:0]integerValue] month:[[dashComponentsArray objectAtIndex:1] integerValue]day:[[dashComponentsArray objectAtIndex:2] integerValue]];
    NSString *dateStr = [NSString stringWithFormat:@"%@",persianDateString];
    cell.dateLabel.text = dateStr;

    //cell.contentLabel.text = @"متن خلاصه پیام";
    
    UIView *lineView =[[UIView alloc]initWithFrame:CGRectMake(5, TABLEVIEW_CELL_HEIGHT- 2, screenWidth-10, 1)];
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        lineView.backgroundColor = color;
    } else {
        lineView.backgroundColor = MAIN_COLOR;
    }
    [cell addSubview:lineView];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dic = [_tableArray objectAtIndex:indexPath.row];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InboxDetailViewController *view = (InboxDetailViewController *)[story instantiateViewControllerWithIdentifier:@"InboxDetailViewController"];
    message_id = [dic objectForKey:@"id"];
    NSString *messageTitle = [dic objectForKey:@"title"];
    view.message_Title = messageTitle;
    view.message_id = message_id;
    view.dictionary = dic;
    [self.navigationController pushViewController:view animated:YES];
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
    //[self.view addSubview:menuButton];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = @"صندوق پیام";
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
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 17 , 40, 40)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];}

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

- (void)backButtonAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    menuColorView.backgroundColor = [UIColor whiteColor];   //MAIN_COLOR;
    menuColorView.userInteractionEnabled = NO;
    [mainView addSubview:menuColorView];
    
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
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,inboxButton.frame.origin.y+inboxButton.frame.size.height+10,MENU_WIDTH,0.7)];
    lineView.backgroundColor = [UIColor grayColor];
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

-(NSString*)timestamp2date:(NSString*)timestamp{
    NSString * timeStampString = timestamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue]/1000.0];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"dd/MM/yy"];
    return [_formatter stringFromDate:date];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
            if ([self hasConnectivity]) {
                page += 1;
                [self fetchInbox];
            }
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

- (void)fetchInbox{
    NSDictionary *params = @{
                             @"author_id":CUSTOMER_AUTHOR_ID,
                             @"page":[NSNumber numberWithInteger:page],
                             @"limit":@"20"
                             };
    /*http://catalog2.yarima.co/mobiles/catalog_get_inbox_messages*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_get_inbox_messages", BaseURL3];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        
        [noResultLabelPost removeFromSuperview];
        if (([[tempDic objectForKey:@"data"]count] == 0) && ([self.tableArray count] == 0)) {
            
            noResultLabelPost = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, screenWidth-20,  25)];
            noResultLabelPost.font = FONT_MEDIUM(17);
            noResultLabelPost.text = @"پیامی یافت نشد.";
            noResultLabelPost.minimumScaleFactor = 0.7;
            NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
            if ([customColor length]>0) {
                UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
                noResultLabelPost.textColor = color;
            } else {
                noResultLabelPost.textColor = MAIN_COLOR;
            }
            noResultLabelPost.textAlignment = NSTextAlignmentCenter;
            noResultLabelPost.adjustsFontSizeToFitWidth = YES;
            [_tableView addSubview:noResultLabelPost];
            
            //            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"پیامی یافت نشد." preferredStyle:UIAlertControllerStyleAlert];
            //            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //            }];
            //            [alert addAction:action];
            //            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }

        for (NSDictionary *message in [tempDic objectForKey:@"data"]) {
            [self.tableArray addObject:message];
        }
        
        [noResultLabelPost removeFromSuperview];
        [self.tableView reloadData];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        [ProgressHUD dismiss];
    }];
}
@end
