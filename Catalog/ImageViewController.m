//
//  ImageViewController.m
//  AdvisorsHealthCloud
//
//  Created by Yarima on 12/15/15.
//  Copyright (c) 2015 Yarima. All rights reserved.
//

#import "ImageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ImageResizer.h"
#import "DocumentDirectoy.h"
#import "Header.h"
#import "ConvertHexToColor.h"

#define VIEW_FOR_ZOOM_TAG (-1)

//#import <Google/Analytics.h>

@interface ImageViewController ()<UIScrollViewDelegate>
{
    UIView *headerView;
    UIScrollView *scrollView;
    NSInteger imagesCount;
    UIView *imageToZoom;
    NSString *zoomURL;
    UIButton *previousButton;
    UIButton *nextButton;
    UIScrollView *pageScrollView;
    UIScrollView *mainScrollView;
}
@property(nonatomic, retain)UIImageView *imageView;

@end

@implementation ImageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    imagesCount = [self.imagesArray count];
    
    [self makeTopbar];

    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,66, screenWidth, screenHeight-66)];
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    
    CGRect innerScrollFrame = mainScrollView.bounds;
    
    for (int i = 0; i < [self.imagesArray count]; i++) {
        NSString *arrayImageURL = [NSString stringWithFormat:@"%@%@", BaseURL2, [[self.imagesArray objectAtIndex:i] objectForKey:@"media"]];
        
        CGFloat ratio = [[[self.imagesArray objectAtIndex:i]objectForKey:@"media_ratio"]floatValue];
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, ((screenHeight/2)-((screenWidth/ratio)/2)), screenWidth, ((screenWidth/ratio)-66))];
        self.imageView.userInteractionEnabled = YES;
        [self.imageView setImageWithURL:[NSURL URLWithString:arrayImageURL] placeholderImage:[UIImage imageNamed:@"placeholder_"]];
        
        previousButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.imageView.frame.size.height/2-15, 30, 30)];
        [previousButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
        [previousButton addTarget:self action:@selector(previousButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [previousButton setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
        previousButton.titleLabel.font = FONT_NORMAL(15);
        previousButton.tag = i;
        //[self.imageView addSubview:previousButton];
        
        nextButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-30, self.imageView.frame.size.height/2-10, 30, 30)];
        [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
        [nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [nextButton setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
        nextButton.titleLabel.font = FONT_NORMAL(15);
        nextButton.tag = i+1;
       // [self.imageView addSubview:nextButton];
        
        if (i==0){
            previousButton.hidden = YES;
        }
        if (i == imagesCount-1){
            nextButton.hidden = YES;
        }
        self.imageView.tag = VIEW_FOR_ZOOM_TAG;
        
        pageScrollView = [[UIScrollView alloc]
                                        initWithFrame:innerScrollFrame];
        pageScrollView.minimumZoomScale = 1.0f;
        pageScrollView.maximumZoomScale = 100.0f;
        pageScrollView.zoomScale = 1.0f;
        pageScrollView.contentSize = self.imageView.bounds.size;
        pageScrollView.delegate = self;
        pageScrollView.tag = i;
        pageScrollView.showsHorizontalScrollIndicator = NO;
        pageScrollView.showsVerticalScrollIndicator = NO;
        
        UIImageView *placeholderImage = [[UIImageView alloc] initWithFrame:CGRectMake(((screenWidth/2)-25),((screenHeight-66)/2)-25,50,50 )];
        placeholderImage.image = [UIImage imageNamed:@"placeholder"];
        placeholderImage.contentMode = UIViewContentModeScaleAspectFit;
        placeholderImage.clipsToBounds = YES;
        [pageScrollView addSubview:placeholderImage];
        
        [pageScrollView addSubview:self.imageView];
        
        [mainScrollView addSubview:pageScrollView];
        
        if (i < [self.imagesArray count]-1) {
            innerScrollFrame.origin.x += innerScrollFrame.size.width;
        }
    }
    mainScrollView.contentSize = CGSizeMake(innerScrollFrame.origin.x +
                                            innerScrollFrame.size.width, mainScrollView.bounds.size.height);
    [self.view addSubview:mainScrollView];
    
    [self scrollToSelectedImage];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView2 {
    return [scrollView2 viewWithTag:VIEW_FOR_ZOOM_TAG];
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Custom Methods

-(void)scrollToSelectedImage{
    for (int j = 0; j<[self.imagesArray count]; j++) {
        NSString *url = [NSString stringWithFormat:@"%@%@", BaseURL2, [[self.imagesArray objectAtIndex:j]objectForKey:@"media"]];
        if ([url isEqualToString: self.imageViewURL]) {
            [mainScrollView scrollRectToVisible:CGRectMake(j*screenWidth, 66, screenWidth, screenHeight-66) animated:YES];
        }
    }
}

- (void)makeTopbar{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        topView.backgroundColor = color;
    } else {
        topView.backgroundColor = MAIN_COLOR;
    }
    [self.view addSubview:topView];
    
    //CGFloat topViewHeight = topView.frame.size.height;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.font = FONT_NORMAL(20);
    if ([self.imagesArray count] == 1) {
        titleLabel.text = @"نمایش تصویر";
    } else {
        titleLabel.text = @"نمایش تصاویر";
    }
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:titleLabel];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 17 , 40, 40)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonImgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)backButtonImgAction{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)previousButtonAction:(UIButton *)button{
    //NSLog(@"Pre:%ld",button.tag);
    [mainScrollView scrollRectToVisible:CGRectMake((((button.tag)-1)* mainScrollView.frame.size.width), 66, screenWidth, screenHeight-66) animated:YES];
}

-(void)nextButtonAction:(UIButton *)button{
    //NSLog(@"Next:%ld",button.tag);
    [mainScrollView scrollRectToVisible:CGRectMake((((button.tag))* mainScrollView.frame.size.width), 66, screenWidth, screenHeight-66) animated:YES];
}
@end
