//
//  DetailsViewController.m
//  Catalog
//
//  Created by Developer on 1/21/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "DetailsViewController.h"
#import "Header.h"
#import "ImageViewController.h"
#import "ImageResizer.h"
#import "AboutusViewController.h"
#import "AuthorViewController.h"
#import "DocumentDirectoy.h"
#import "VideoPlayerViewController.h"
#import "ConvertHexToColor.h"
#import "ShoppingViewController.h"

@interface DetailsViewController ()
{
    UITableView *tableView;
    UIView *bgViewForListAllType;
    UIImageView *imageViewListMaker;
    UIActivityIndicatorView *activityIndicator;
    NSMutableDictionary *detailDictionary;
    UIScrollView *scrollView;
    NSInteger author_id;
    NSString *_postID;
    NSString *imageURL;
    NSMutableArray  *imagesArray;
    UILabel *descriptionLabel;
    UITextView *descriptionText;
    UIImageView *productImageView;
    NSArray *objectsToShare;
}
//@property(nonatomic, retain) NSDictionary *tempDic;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [self makeTopBar];
    
    if ([self hasConnectivity]) {
        [self fetchPostDetailWithId:_dictionary.LPTVPostID];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSDictionary *tempDic = [Database selectFromDetailWithID:[self.dictionary objectForKey:@"postId"] WithFilePath:[Database getDbFilePath]];
        detailDictionary = [[NSMutableDictionary alloc]initWithDictionary:tempDic];
        if ([detailDictionary count] > 1) {
            [self makeScrollViewOffline];
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
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 17, 40, 40)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UIImage *buttonImageNormal = [UIImage imageNamed:@"backButton"];
    [backButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = self.titleText;
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

- (void)makeScrollView{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, screenWidth,screenHeight - 65)];
    scrollView.showsVerticalScrollIndicator=YES;
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(0, 700)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:scrollView];
    
    UIImageView *placeholderImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-35,((screenWidth*0.6)/2)-35,70,70 )];
    placeholderImage.image = [UIImage imageNamed:@"placeholder"];
    placeholderImage.contentMode = UIViewContentModeScaleAspectFit;
    placeholderImage.clipsToBounds = YES;
    [scrollView addSubview: placeholderImage];
    
    productImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth,screenWidth*0.6)];
    
    //NSString *tempName = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuImage"];
    //[productImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL2, [[detailDictionary objectForKey:@"feeds"]objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]]];
    
    [productImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL2, [[detailDictionary objectForKey:@"feeds"]objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"placeholder_"]];
    productImageView.userInteractionEnabled = YES;
    productImageView.contentMode = UIViewContentModeScaleAspectFill;
    productImageView.clipsToBounds = YES;
    [scrollView addSubview: productImageView];
    
    UIButton *shoppingButton = [[UIButton alloc]initWithFrame:CGRectMake(15,productImageView.frame.origin.y+productImageView.frame.size.height+10 , 130, 30)];
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    //        if ([customColor length]>0) {
    //            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
    //            [self.shoppingButton setTitleColor:color forState:UIControlStateNormal ];
    //        } else {
    //            [self.shoppingButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    //        }
    
    [shoppingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shoppingButton setTitle:@"" forState:UIControlStateNormal];
    shoppingButton.titleLabel.font = FONT_NORMAL(11);
    [[shoppingButton layer] setCornerRadius:10.0f];
    [[shoppingButton layer] setMasksToBounds:YES];
    [[shoppingButton layer] setBorderWidth:1.0f];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    //        if ([customColor length]>0) {
    //            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
    //            [[self.shoppingButton layer] setBorderColor:color.CGColor];
    //        } else {
    //            [[self.shoppingButton layer] setBorderColor:MAIN_COLOR.CGColor];
    //        }
    [[shoppingButton layer] setBorderColor:[UIColor colorWithRed:0/255.0 green:189/255.0 blue:69/255.0 alpha:1.0].CGColor];
    shoppingButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:189/255.0 blue:69/255.0 alpha:1.0];
    [shoppingButton addTarget:self action:@selector(shoppingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:shoppingButton];
    
    UIImageView *shoppingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 5, 20,20)];    shoppingImageView.image = [UIImage imageNamed:@"shoppingImage"];
    //shoppingImageView.backgroundColor = [UIColor redColor];
    shoppingImageView.contentMode = UIViewContentModeScaleAspectFit;
    shoppingImageView.userInteractionEnabled = YES;
    [shoppingButton addSubview: shoppingImageView];
    
    UILabel *shoppingLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    shoppingLabel.textColor = [UIColor whiteColor];
    shoppingLabel.text = @"۱۰۰۰۰ تومان";
    shoppingLabel.font = FONT_NORMAL(15);
    //shoppingLabel.backgroundColor = [UIColor yellowColor];
    shoppingLabel.textAlignment = NSTextAlignmentCenter;
    [shoppingButton addSubview:shoppingLabel];
    
    UILabel *discountLabel =[[UILabel alloc]initWithFrame:CGRectMake(150,productImageView.frame.origin.y+productImageView.frame.size.height+10 , 100, 30)];
    discountLabel.textColor = [UIColor redColor];
    discountLabel.font = FONT_NORMAL(15);
    //discountLabel.backgroundColor = [UIColor yellowColor];
    discountLabel.text = @"50000";
    discountLabel.textAlignment = NSTextAlignmentCenter;
    //[scrollView addSubview:discountLabel];

    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,productImageView.frame.origin.y+productImageView.frame.size.height+50 , screenWidth-40, 25)];
    titleLabel.text = self.titleText;
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
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        horizontalLine1.backgroundColor = color;
    } else {
        horizontalLine1.backgroundColor = MAIN_COLOR;
    }
    horizontalLine1.userInteractionEnabled = NO;
    [scrollView addSubview:horizontalLine1];
    
    UIImageView *authorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-70,titleLabel.frame.origin.y+titleLabel.frame.size.height+30, 40,40)];
    [authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2,[[[[detailDictionary objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"author_photo"]]] placeholderImage:[UIImage imageNamed:@"logo"]];
    authorImageView.contentMode = UIViewContentModeScaleAspectFit;
    authorImageView.userInteractionEnabled = YES;
    authorImageView.layer.cornerRadius = 40 / 2;
    authorImageView.clipsToBounds = YES;
    [scrollView addSubview: authorImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    authorImageView.userInteractionEnabled = YES;
    [authorImageView addGestureRecognizer:tap];
    
    UILabel *logoDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(75,titleLabel.frame.origin.y+titleLabel.frame.size.height+30 , screenWidth-150, 40)];
    logoDescLabel.text = [NSString stringWithFormat:@"%@ %@", [[[[detailDictionary objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"firstname"],[[[[detailDictionary objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"lastname"]];
    logoDescLabel.font = FONT_NORMAL(12);
    logoDescLabel.numberOfLines = 2;
    logoDescLabel.baselineAdjustment = YES;
    logoDescLabel.adjustsFontSizeToFitWidth = YES;
    logoDescLabel.minimumScaleFactor = 0.5;
    logoDescLabel.clipsToBounds = YES;
    logoDescLabel.backgroundColor = [UIColor clearColor];
    logoDescLabel.textColor = [UIColor blackColor];
    logoDescLabel.textAlignment = NSTextAlignmentRight;
    //logoDescLabel.backgroundColor = [UIColor yellowColor];
    [scrollView addSubview:logoDescLabel];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    logoDescLabel.userInteractionEnabled = YES;
    [logoDescLabel addGestureRecognizer:tap2];
    
    UILabel *jobTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,titleLabel.frame.origin.y+titleLabel.frame.size.height+55 , screenWidth-80, 25)];
    jobTitleLabel.text = [NSString stringWithFormat:@"%@",[[[[detailDictionary objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"job_title"]];
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
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(15,titleLabel.frame.origin.y+titleLabel.frame.size.height+37 , 50, 25)];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        [shareButton setTitleColor:color forState:UIControlStateNormal ];
    } else {
        [shareButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    }
    [shareButton setTitle:@"اشتراک" forState:UIControlStateNormal];
    shareButton.titleLabel.font = FONT_NORMAL(11);
    [[shareButton layer] setCornerRadius:10.0f];
    [[shareButton layer] setMasksToBounds:YES];
    [[shareButton layer] setBorderWidth:1.0f];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        [[shareButton layer] setBorderColor:color.CGColor];
    }else{
        [[shareButton layer] setBorderColor:MAIN_COLOR.CGColor];
    }
    [shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:shareButton];
    
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
    
    [self makeListForAllAnswerTypesWithYposition:horizontalLine2.frame.origin.y + horizontalLine2.frame.size.height + 5 arrayElements:[detailDictionary objectForKey:@"fullDescription"]];
    
    author_id = [[[[[detailDictionary objectForKey:@"feeds"]objectForKey:@"author"] objectAtIndex:0]objectForKey:@"profile_id"]integerValue];
    NSLog(@"author_id = %ld",(long)author_id);
}

- (void)makeListForAllAnswerTypesWithYposition:(CGFloat)yPos arrayElements:(NSArray *)array{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat yPosition = yPos;
        [bgViewForListAllType removeFromSuperview];
        bgViewForListAllType = [[UIView alloc]initWithFrame:CGRectMake(0, yPosition, screenWidth, 300)];
        [scrollView addSubview:bgViewForListAllType];
        
        CGFloat ypositionOfRow = 5;
        imagesArray = [[NSMutableArray alloc] init];
        
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
                //imageURL = [NSString stringWithFormat:@"%@%@", BaseURL2, answerStr];
                [imagesArray addObject:[array objectAtIndex:i]];
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
                //                descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,ypositionOfRow +10, screenWidth - 40, [self getHeightOfString:answerStr])];
                //                NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
                //                [paragraph setLineSpacing:10];
                //                paragraph.alignment = NSTextAlignmentJustified;
                //                paragraph.baseWritingDirection = NSWritingDirectionRightToLeft;
                //                paragraph.firstLineHeadIndent = 1.0;
                //                NSDictionary* attributes = @{
                //                                             NSForegroundColorAttributeName: [UIColor blackColor],
                //                                             NSParagraphStyleAttributeName: paragraph,
                //                                             NSFontAttributeName:FONT_NORMAL(15)
                //                                             };
                //                NSAttributedString* aString = [[NSAttributedString alloc] initWithString:answerStr attributes: attributes];
                //                descriptionLabel.attributedText = aString;
                //                descriptionLabel.numberOfLines = 0;
                
                descriptionText = [[UITextView alloc]initWithFrame:CGRectMake(20,ypositionOfRow +10, screenWidth - 40, [self getHeightOfString:answerStr]+40)];
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
                descriptionText.attributedText = aString;
                descriptionText.editable = NO;
                descriptionText.dataDetectorTypes = UIDataDetectorTypeAll;
                //descriptionText.scrollEnabled = NO;
                //descriptionText.numberOfLines = 0;
                //descriptionText.contentSize = CGSizeMake(descriptionText.frame.size.width, descriptionText.frame.size.height) ;
//                descriptionText.alwaysBounceHorizontal = NO;
//                descriptionText.bounces = NO;
//                descriptionText.showsHorizontalScrollIndicator = NO;
                [bgViewForListAllType addSubview:descriptionText];
                ypositionOfRow += [self getHeightOfString:answerStr]+40;
            }
        }
        bgViewForListAllType.frame = CGRectMake(0, yPosition, screenWidth, ypositionOfRow + 40);
        scrollView.contentSize = CGSizeMake(screenWidth, bgViewForListAllType.frame.size.height  + bgViewForListAllType.frame.origin.y);
    });
}

- (void)makeScrollViewOffline{
    //_postID = [[self.dictionary objectForKey:@"feeds"]objectForKey:@"id"];
    
    //    NSDictionary *tempDic = [Database selectFromDetailWithID:_postID WithFilePath:[Database getDbFilePath]];
    //    NSLog(@"%@",tempDic);
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, screenWidth,screenHeight - 65)];
    scrollView.showsVerticalScrollIndicator=YES;
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(0, 700)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:scrollView];
    
    UIImageView *placeholderImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-35,((screenWidth*0.6)/2)-35,70,70 )];
    placeholderImage.image = [UIImage imageNamed:@"placeholder"];
    placeholderImage.contentMode = UIViewContentModeScaleAspectFit;
    placeholderImage.clipsToBounds = YES;
    [scrollView addSubview: placeholderImage];
    
    productImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth,screenWidth*0.6)];
    
    //NSString *tempName = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuImage"];
    //[productImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL2, [[detailDictionary objectForKey:@"feeds"]objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]]];
    
    [productImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseURL2, [[detailDictionary objectForKey:@"feeds"]objectForKey:@"photo"]]] placeholderImage:[UIImage imageNamed:@"placeholder_"]];
    productImageView.contentMode = UIViewContentModeScaleAspectFill;
    productImageView.clipsToBounds = YES;
    productImageView.userInteractionEnabled = YES;
    [scrollView addSubview: productImageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,productImageView.frame.origin.y+productImageView.frame.size.height+15 , screenWidth-40, 25)];
    titleLabel.text = [detailDictionary objectForKey:@"title"];
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
    [authorImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2,[detailDictionary objectForKey:@"logoImage"]]] placeholderImage:[UIImage imageNamed:@"logo"]];
    authorImageView.contentMode = UIViewContentModeScaleAspectFit;
    authorImageView.userInteractionEnabled = YES;
    authorImageView.layer.cornerRadius = 40 / 2;
    authorImageView.clipsToBounds = YES;
    [scrollView addSubview: authorImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    authorImageView.userInteractionEnabled = YES;
    [authorImageView addGestureRecognizer:tap];
    
    UILabel *logoDescLabel = [[UILabel alloc]initWithFrame:CGRectMake(75,titleLabel.frame.origin.y+titleLabel.frame.size.height+30 , screenWidth-150, 40)];
    logoDescLabel.text = [NSString stringWithFormat:@"%@ %@",[detailDictionary objectForKey:@"logoFirstName"],[ detailDictionary objectForKey:@"logoLastName"]];
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
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    logoDescLabel.userInteractionEnabled = YES;
    [logoDescLabel addGestureRecognizer:tap2];
    
    UILabel *jobTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,titleLabel.frame.origin.y+titleLabel.frame.size.height+55 , screenWidth-80, 25)];
    jobTitleLabel.text = [NSString stringWithFormat:@"%@",[[[[detailDictionary objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"job_title"]];
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
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(15,titleLabel.frame.origin.y+titleLabel.frame.size.height+37 , 50, 25)];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        [shareButton setTitleColor:color forState:UIControlStateNormal ];
    } else {
        [shareButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    }
    [shareButton setTitle:@"اشتراک" forState:UIControlStateNormal];
    shareButton.titleLabel.font = FONT_NORMAL(11);
    [[shareButton layer] setCornerRadius:10.0f];
    [[shareButton layer] setMasksToBounds:YES];
    [[shareButton layer] setBorderWidth:1.0f];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        [[shareButton layer] setBorderColor:color.CGColor];
    }else{
        [[shareButton layer] setBorderColor:MAIN_COLOR.CGColor];
    }
    [shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:shareButton];
    
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
    
    [self makeListForAllAnswerTypesWithYpositionOffline:horizontalLine2.frame.origin.y + horizontalLine2.frame.size.height + 5 arrayElements:[detailDictionary objectForKey:@"elements"]];
    
    //author_id = [[[[[detailDictionary objectForKey:@"feeds"]objectForKey:@"author"] objectAtIndex:0]objectForKey:@"profile_id"]integerValue];
    //NSLog(@"author_id = %ld",(long)author_id);
}

- (void)makeListForAllAnswerTypesWithYpositionOffline:(CGFloat)yPos arrayElements:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat yPosition = yPos;
        NSLog(@"Text = %@", text);
        [bgViewForListAllType removeFromSuperview];
        bgViewForListAllType = [[UIView alloc]initWithFrame:CGRectMake(0, yPosition, screenWidth, 300)];
        [scrollView addSubview:bgViewForListAllType];
        
        CGFloat ypositionOfRow = 5;
        NSArray *arrayCount = [text componentsSeparatedByString:@",,,"];
        
        for (int i = 0; i < arrayCount.count-1; i++) {
            NSString *tempStr = [arrayCount objectAtIndex:i];
            NSArray *arr;
            NSString *answerStr;
            NSString *screenshotStr;
            if ([tempStr length]>0) {
                arr = [tempStr componentsSeparatedByString:@","];
                answerStr = [arr objectAtIndex:1];
                screenshotStr = [arr objectAtIndex:0];
                //imageView
                if (([answerStr containsString:@".jpg"]) || ([answerStr containsString:@".png"])) {
                    UIImageView *placeholderImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-25,ypositionOfRow + 10,50,50 )];
                    placeholderImage.image = [UIImage imageNamed:@"placeholder"];
                    placeholderImage.contentMode = UIViewContentModeScaleAspectFit;
                    placeholderImage.clipsToBounds = YES;
                    [bgViewForListAllType addSubview: placeholderImage];
                    imageViewListMaker = [[UIImageView alloc]initWithFrame:CGRectMake(10, ypositionOfRow + 10, screenWidth - 20, screenWidth * 1.4)];
                    imageViewListMaker.userInteractionEnabled = YES;
                    imageViewListMaker.tag = i;
                    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
                    [imageViewListMaker addGestureRecognizer:imageViewTap];
                    [imageViewListMaker setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2, answerStr]] placeholderImage:[UIImage imageNamed:@"placeholder_"]];
                    [bgViewForListAllType addSubview:imageViewListMaker];
                    ypositionOfRow = imageViewListMaker.frame.origin.y + imageViewListMaker.frame.size.height + 20;
                    
                    //video
                }else if ([answerStr containsString:@"mp4"]) {
                    imageViewListMaker = [[UIImageView alloc]initWithFrame:CGRectMake(10, ypositionOfRow + 10, screenWidth - 20, screenWidth - 100)];
                    imageViewListMaker.userInteractionEnabled = YES;
                    imageViewListMaker.tag = i;
                    UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideoAction:)];
                    [imageViewListMaker addGestureRecognizer:imageViewTap];
                    [imageViewListMaker setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BaseURL2, screenshotStr]] placeholderImage:[UIImage imageNamed:@"placeholder_"]];
                    [bgViewForListAllType addSubview:imageViewListMaker];
                    ypositionOfRow = imageViewListMaker.frame.origin.y + imageViewListMaker.frame.size.height + 20;
                    
                    UIImageView *playImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth/2 - 40, 70, 80, 80)];
                    playImageView.image = [UIImage imageNamed:@"play_video"];
                    [imageViewListMaker addSubview:playImageView];
                    
                    //text
                }else{
                    //                    descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,ypositionOfRow +10, screenWidth - 40, [self getHeightOfString:answerStr])];
                    //                    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
                    //                    [paragraph setLineSpacing:10];
                    //                    paragraph.alignment = NSTextAlignmentJustified;
                    //                    paragraph.baseWritingDirection = NSWritingDirectionRightToLeft;
                    //                    paragraph.firstLineHeadIndent = 1.0;
                    //                    NSDictionary* attributes = @{
                    //                                                 NSForegroundColorAttributeName: [UIColor blackColor],
                    //                                                 NSParagraphStyleAttributeName: paragraph,
                    //                                                 NSFontAttributeName:FONT_NORMAL(15)
                    //                                                 };
                    //                    NSAttributedString* aString = [[NSAttributedString alloc] initWithString:answerStr attributes: attributes];
                    //                    descriptionLabel.attributedText = aString;
                    //                    descriptionLabel.numberOfLines = 0;
                    
                    descriptionText = [[UITextView alloc]initWithFrame:CGRectMake(20,ypositionOfRow +10, screenWidth - 40, [self getHeightOfString:answerStr]+40)];
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
                    descriptionText.attributedText = aString;
                    descriptionText.editable = NO;
                    descriptionText.dataDetectorTypes = UIDataDetectorTypeAll;
                    //descriptionText.scrollEnabled = NO;
                    //descriptionText.numberOfLines = 0;
                    //descriptionText.contentSize = CGSizeMake(descriptionText.frame.size.width, descriptionText.frame.size.height) ;
                    [bgViewForListAllType addSubview:descriptionText];
                    ypositionOfRow += ([self getHeightOfString:answerStr]+40);
                }
            }
        }
        bgViewForListAllType.frame = CGRectMake(0, yPosition, screenWidth, ypositionOfRow + 40);
        scrollView.contentSize = CGSizeMake(screenWidth, bgViewForListAllType.frame.size.height  + bgViewForListAllType.frame.origin.y);
    });
}

- (void)tapImageView:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = [[detailDictionary objectForKey:@"fullDescription"]objectAtIndex:tap.view.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ImageViewController *view = (ImageViewController *)[story instantiateViewControllerWithIdentifier:@"ImageViewController"];
    NSString *url = [NSString stringWithFormat:@"%@%@", BaseURL2, [tempDic objectForKey:@"media"]];
    view.imageViewURL = url;
    view.imagesArray = imagesArray;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)tapVideoAction:(UITapGestureRecognizer *)tap{
    NSDictionary *tempDic = [[detailDictionary objectForKey:@"fullDescription"]objectAtIndex:tap.view.tag];
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

-(void)shoppingButtonAction{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShoppingViewController *view = (ShoppingViewController *)[story instantiateViewControllerWithIdentifier:@"ShoppingViewController"];
    //view.titleText = button.titleLabel.text;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - Sharing
- (void) shareButtonAction:(UIButton *)button{
    UIImageView *imageToShare = [[UIImageView alloc]init];
    imageToShare.contentMode = UIViewContentModeScaleAspectFit;
    //NSString *tempName = [dic.LPTVImageUrl lastPathComponent];
    //imageToShare.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", [DocumentDirectoy getDocuementsDirectory], tempName]];
    
    imageToShare.image = productImageView.image;

    NSString *textToShare1 = self.titleText;
    NSString *textToShare2 = descriptionText.text;
    //NSString *textToShare3 = [NSString stringWithFormat:@"\n %@ %@ %@ \n\n",@"این مطلب توسط اپلیکیشن",App_Name,@"به اشتراک گذاشته شده"];
    NSString *textToShare3 = [NSString stringWithFormat:@" جهت دریافت اپلیکیشن %@، روی لینک زیر کلیک نمایید. ",App_Name];
    NSString *textToShare4 = [[NSUserDefaults standardUserDefaults]objectForKey:@"downloadLink"];
    NSString *textToShare = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n",textToShare1,textToShare2,textToShare3,textToShare4];
    
    //Handle crash if image is nil
    if (imageToShare.image != nil) {
        objectsToShare = @[imageToShare.image,textToShare];
    } else {
        objectsToShare = @[textToShare];
    }
    
    //NSArray *objectsToShare = @[imageToShare.image,textToShare];
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

- (void)fetchPostDetailWithId:(NSString *)postID{
    
    [ProgressHUD show:@""];
    NSDictionary *params = @{
                             @"title_id":postID,
                             @"imei":UDID,
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    
    /*http://catalog2.yarima.co/mobiles/catalog_getFullDescription*/
    NSString *url = [NSString stringWithFormat:@"%@catalog_getFullDescription", BaseURL3];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *tempDic = (NSDictionary *)responseObject;
        if ([[tempDic objectForKey:@"error_code"]integerValue] == 5) {//post has deleted
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"این مطلب حذف شده است" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"بازگشت" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
                [Database deleteLandingPageWithFilePath:[Database getDbFilePath] withID:postID];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadTableview" object:nil];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        if ([[tempDic allKeys]count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        detailDictionary = [[NSMutableDictionary alloc]initWithDictionary:tempDic];
        
        [Database insertIntoDetailWithFilePath:[Database getDbFilePath] postID:[[tempDic objectForKey:@"feeds"]objectForKey:@"id"] title:[[tempDic objectForKey:@"feeds"]objectForKey:@"title"] coverImage:[[tempDic objectForKey:@"feeds"]objectForKey:@"photo"] postName:[[tempDic objectForKey:@"feeds"]objectForKey:@"title"] logoImage:[[[[tempDic objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"author_photo"] logoFirstName:[[[[tempDic objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"firstname"] logoLastName:[[[[tempDic objectForKey:@"feeds"]objectForKey:@"author"]objectAtIndex:0]objectForKey:@"lastname"] elements:[tempDic objectForKey:@"fullDescription"]];
        
        [Database deleteDuplicateDataDetailWithFilePath:[Database getDbFilePath]];
        
        [self makeScrollView];
        
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
