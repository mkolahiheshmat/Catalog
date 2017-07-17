//
//  CategoriesViewController.m
//  Catalog
//
//  Created by Developer on 1/21/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Header.h"
#import "ViewController.h"
#import "AboutusViewController.h"
#import "CategoriesViewController.h"
#import "CategoriesCustomCell.h"
#import "AuthorViewController.h"
#import "DocumentDirectoy.h"
#import "InboxViewController.h"
#import "CategoriesLandingPageViewController.h"
#import "ConvertHexToColor.h"

#define MENU_WIDTH  screenWidth/1.5
@interface CategoriesViewController ()<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UILabel *titleLabel;
    BOOL isMenuShown;
    UIView *mainView;
    UIView *tranparentView;
    UIView *bgViewForListAllType;
    NSInteger selectedSection;
    NSString *CategoriesLandingTitleStr;
    NSMutableArray *expandStatusArray;
}
@property(nonatomic, retain)UITableView *tableView;
@property(nonatomic, retain)NSMutableArray *tableArray;
@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    expandStatusArray = [[NSMutableArray alloc]init];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    selectedSection = 1000;
    [self makeTopBar];
    _tableArray = [[NSMutableArray alloc]initWithArray:[Database selectFromCategoriesWithFilePath:[Database getDbFilePath]]];
    if ([_tableArray count] == 0) {
        if ([self hasConnectivity]) {
            [self fetchCategories];
            //            _tableArray = [[NSMutableArray alloc]initWithArray:[self sortCategory:[Database selectFromCategoriesWithFilePath:[Database getDbFilePath]]]];
            //            [self.tableView reloadData];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            _tableArray = [[NSMutableArray alloc]initWithArray:[self sortCategory:[Database selectFromCategoriesWithFilePath:[Database getDbFilePath]]]];
        }
        
    }else{
        if ([self hasConnectivity]) {
            
            [self fetchCategories];
            //        _tableArray = [[NSMutableArray alloc]initWithArray:[self sortCategory:[Database selectFromCategoriesWithFilePath:[Database getDbFilePath]]]];
            //        [self.tableView reloadData];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            _tableArray = [[NSMutableArray alloc]initWithArray:[self sortCategory:[Database selectFromCategoriesWithFilePath:[Database getDbFilePath]]]];
        }
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, screenWidth ,screenHeight - 69)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
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

#pragma mark - TableView DataSource Implementation
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;//[[[_tableArray objectAtIndex:indexPath.section]objectForKey:@"tags"]count] * 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (selectedSection >= 0 && selectedSection < [_tableArray count]) {
        if (section == selectedSection) {
            NSString *tagsStr = [[_tableArray objectAtIndex:section]objectForKey:@"tags"];
            NSArray *tagArr = [tagsStr componentsSeparatedByString:@",,,"];
            return [tagArr count] - 1;
        }
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_tableArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[_tableArray objectAtIndex:section]objectForKey:@"name"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    headerView.backgroundColor = [UIColor whiteColor];
    NSDictionary *dic = [_tableArray objectAtIndex:section];
    
    UILabel* headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(5, 8, tableView.frame.size.width - 45, 18);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = FONT_NORMAL(17);
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.text = [dic objectForKey:@"name"];
    CategoriesLandingTitleStr = headerLabel.text;
    headerLabel.textAlignment = NSTextAlignmentRight;
    headerLabel.userInteractionEnabled = YES;
    [headerView addSubview:headerLabel];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 30, 5, 20, 20)];
    [imageView setImageWithURL:[NSURL URLWithString:
                                [NSString stringWithFormat:@"%@%@",
                                 BaseURL2,[dic objectForKey:@"icon"]]]placeholderImage:[UIImage imageNamed:@"categoryPlaceholder"]];
    
    [headerView addSubview:imageView];
    headerView.tag = section;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    headerView.userInteractionEnabled = YES;
    [headerView addGestureRecognizer:tapGesture];
    
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(30, 5, 20, 20)];
    imageView2.image = [UIImage imageNamed:@"down"];
    if (selectedSection != 1000) {
        if (selectedSection == section) {
            imageView2.image = [UIImage imageNamed:@"up"];
        } else {
            imageView2.image = [UIImage imageNamed:@"down"];
        }
    }
    [headerView addSubview:imageView2];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CategoriesCustomCell *cell = (CategoriesCustomCell *)[[CategoriesCustomCell alloc]
                                                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    
    cell.categoryImageView.image = [UIImage imageNamed:@"left"];
    NSDictionary *dic = [_tableArray objectAtIndex:indexPath.section];
    NSString *tagsStr = [dic objectForKey:@"tags"];
    if ([tagsStr length] > 0) {
        NSArray *tagArr = [tagsStr componentsSeparatedByString:@",,,"];
        if (indexPath.row < [tagArr count]) {
            tagsStr = [tagArr objectAtIndex:indexPath.row];
            if ([tagsStr length] > 0) {
                NSArray *arr = [tagsStr componentsSeparatedByString:@","];
                cell.categoryTitleLabel.text = [arr objectAtIndex:1];
                //CategoriesLandingTitleStr = cell.categoryTitleLabel.text;
            }
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dic;
    NSString *tagsStr = [[_tableArray objectAtIndex:indexPath.section]objectForKey:@"tags"];
    NSArray *tagArr = [tagsStr componentsSeparatedByString:@",,,"];
    tagsStr = [tagArr objectAtIndex:indexPath.row];
    NSArray *arr = [tagsStr componentsSeparatedByString:@","];
    dic = [[NSDictionary alloc]initWithObjectsAndKeys:[arr objectAtIndex:0], @"id", [arr objectAtIndex:1], @"name", nil];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CategoriesLandingPageViewController *view = (CategoriesLandingPageViewController *)[story instantiateViewControllerWithIdentifier:@"CategoriesLandingPageViewController"];
    view.titleText = CategoriesLandingTitleStr;
    view.dictionary = dic;
    [self.navigationController pushViewController:view animated:YES];
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"FetchTagDescription" object:dic];
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"setCategoryLanding" object:dic];
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
    UIImage *buttonImageNormal = [UIImage imageNamed:@"backButton.png"];
    [backButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = @"دسته بندی ها";
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
    
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-50, 20, 64 * 0.5, 64 * 0.5)];
    [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UIImage *menuImageNormal = [UIImage imageNamed:@"menu"];
    [menuButton setBackgroundImage:menuImageNormal forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:menuButton];
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
- (NSArray *)sortCategory:(NSArray *)inputArray{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"catPriority"
                                                 ascending:NO];
    NSSortDescriptor *sortDescriptor2;
    sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"catId"
                                                  ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor,sortDescriptor2, nil];
    NSArray *sortedArray = [inputArray sortedArrayUsingDescriptors:sortDescriptors];
    return [self sortSamePriority:sortedArray];
}

- (NSArray *)sortSamePriority:(NSArray *)inputArray{
    NSMutableArray *sortedIDArray = [NSMutableArray arrayWithArray:inputArray];
    for (int k=0; k<[sortedIDArray count]; k++) {
        for (int i=0; i<[sortedIDArray count]; i++) {
            for(int j=i;j<[sortedIDArray count];j++){
                if(j+1<[sortedIDArray count]){
                    if ([[[sortedIDArray objectAtIndex:j]objectForKey:@"priority"]integerValue]==[[[sortedIDArray objectAtIndex:j+1]objectForKey:@"priority"]integerValue]) {
                        NSLog(@"%@---%@",[[sortedIDArray objectAtIndex:j] objectForKey:@"name"],[[sortedIDArray objectAtIndex:j+1] objectForKey:@"name"]);
                        if ([[[sortedIDArray objectAtIndex:j]objectForKey:@"id"]integerValue]>[[[sortedIDArray objectAtIndex:j+1]objectForKey:@"id"]integerValue]) {
                            // [sortedIDArray replaceObjectAtIndex:j withObject:[sortedIDArray objectAtIndex:j+1]];
                            [sortedIDArray exchangeObjectAtIndex:j withObjectAtIndex:j+1];
                        }
                    }
                }
            }
        }
    }
    return sortedIDArray;
    //    return inputArray;
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}
- (void)tapGestureAction:(UITapGestureRecognizer*)gestureRecognizer
{
    if ([[[_tableArray objectAtIndex:gestureRecognizer.view.tag]objectForKey:@"tags"]length] == 0) {
        NSDictionary *dic = [_tableArray objectAtIndex:gestureRecognizer.view.tag];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CategoriesLandingPageViewController *view = (CategoriesLandingPageViewController *)[story instantiateViewControllerWithIdentifier:@"CategoriesLandingPageViewController"];
        view.dictionary = dic;
        view.titleText = CategoriesLandingTitleStr;
        [self.navigationController pushViewController:view animated:YES];
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"reloadCategoriesTableview" object:nil];
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"setCategory2" object:dic];
        
    } else {
        if ([expandStatusArray count] == 0){
            for (NSDictionary *dictionary in  _tableArray) {
                NSLog(@"%@",dictionary);
                [expandStatusArray addObject:[NSNumber numberWithInteger:0]];
            }
        }
        if ([[expandStatusArray objectAtIndex:gestureRecognizer.view.tag]integerValue] == 1/*1000*/) {//open sub categories
            [expandStatusArray replaceObjectAtIndex:gestureRecognizer.view.tag
                                         withObject:[NSNumber numberWithInteger:0]];
            NSDictionary *dic = [_tableArray objectAtIndex:gestureRecognizer.view.tag];
            //[self.navigationController popViewControllerAnimated:YES];
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CategoriesLandingPageViewController *view = (CategoriesLandingPageViewController *)[story instantiateViewControllerWithIdentifier:@"CategoriesLandingPageViewController"];
            view.dictionary = dic;
            view.titleText = CategoriesLandingTitleStr;
            [self.navigationController pushViewController:view animated:YES];
            
            
        } else {//go to landingpage
            selectedSection = gestureRecognizer.view.tag;
            for (NSInteger i = 0; i < [expandStatusArray count]; i++) {
                [expandStatusArray replaceObjectAtIndex:i
                                             withObject:[NSNumber numberWithInteger:0]];
            }
            [expandStatusArray replaceObjectAtIndex:gestureRecognizer.view.tag
                                         withObject:[NSNumber numberWithInteger:1]];
            [self.tableView reloadData];
            
            //[[NSNotificationCenter defaultCenter]postNotificationName:@"reloadCategoriesTableview" object:nil];
            //[[NSNotificationCenter defaultCenter]postNotificationName:@"setCategory2" object:dic];
            
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

- (void)fetchCategories{
    NSDictionary *params = @{
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    /*http://catalog2.yarima.co/mobiles/catalog_categories*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_categories", BaseURL3];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        
        if ([[tempDic allKeys]count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        [Database deleteCategoriesWithFilePath:[Database getDbFilePath]];
        if (![[tempDic valueForKey:@"category"] isEqual:[NSNull null]]) {
            for (NSDictionary *category in [tempDic objectForKey:@"category"]) {
                [expandStatusArray addObject:[NSNumber numberWithInteger:0]];
                [Database insertIntoCategoriesWithFilePath:[Database getDbFilePath] catID:[category objectForKey:@"id"] catName:[category objectForKey:@"name"] catIcon:[category objectForKey:@"icon"] catPriority:[category objectForKey:@"priority"] catTags:[category objectForKey:@"tags"]];
            }
            _tableArray = [[NSMutableArray alloc]initWithArray:[self sortCategory:[Database selectFromCategoriesWithFilePath:[Database getDbFilePath]]]];
            [self.tableView reloadData];
        }
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
