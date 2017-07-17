//
//  CustomCell2.m
//  AdvisorsHealthCloud
//
//  Created by Arash on 12/26/15.
//  Copyright © 2015 Arash. All rights reserved.
//

#import "LandingPageCustomCell.h"
#import "Header.h"
#import "ConvertHexToColor.h"

@implementation LandingPageCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 2, screenWidth - 30, 60)];
        self.titleLabel.font = FONT_NORMAL(15);
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
        
        self.placeholderImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2-35, screenWidth*0.7/2-35,70,70 )];
        self.placeholderImage.contentMode = UIViewContentModeScaleAspectFit;
        self.placeholderImage.clipsToBounds = YES;
        [self addSubview: self.placeholderImage];
        
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10, screenWidth-30, screenWidth * 0.7)];
        self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.postImageView.clipsToBounds = YES;
        [self addSubview:self.postImageView];
        
        NSInteger categoryImageWidth = 40;
        self.categoryImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - categoryImageWidth - 20, self.postImageView.frame.origin.y + 20, categoryImageWidth, categoryImageWidth)];
        self.categoryImageView.layer.cornerRadius = categoryImageWidth / 2;
        self.categoryImageView.clipsToBounds = YES;
        [self addSubview:self.categoryImageView];
        
        self.videoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, self.postImageView.frame.origin.y + 20, 220 * 0.16, 180 * 0.16)];
        [self addSubview:self.videoImageView];
        
        self.shoppingButton = [[UIButton alloc]initWithFrame:CGRectMake(15,self.postImageView.frame.origin.y+self.postImageView.frame.size.height+10 , 130, 30)];
        NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
//        if ([customColor length]>0) {
//            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
//            [self.shoppingButton setTitleColor:color forState:UIControlStateNormal ];
//        } else {
//            [self.shoppingButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
//        }
        
        [self.shoppingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.shoppingButton setTitle:@"" forState:UIControlStateNormal];
        self.shoppingButton.titleLabel.font = FONT_NORMAL(11);
        [[self.shoppingButton layer] setCornerRadius:10.0f];
        [[self.shoppingButton layer] setMasksToBounds:YES];
        [[self.shoppingButton layer] setBorderWidth:1.0f];
        //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
//        if ([customColor length]>0) {
//            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
//            [[self.shoppingButton layer] setBorderColor:color.CGColor];
//        } else {
//            [[self.shoppingButton layer] setBorderColor:MAIN_COLOR.CGColor];
//        }
        [[self.shoppingButton layer] setBorderColor:[UIColor colorWithRed:0/255.0 green:189/255.0 blue:69/255.0 alpha:1.0].CGColor];
        self.shoppingButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:189/255.0 blue:69/255.0 alpha:1.0];
        [self addSubview:self.shoppingButton];
        
        UIImageView *shoppingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 5, 20,20)];    shoppingImageView.image = [UIImage imageNamed:@"shoppingImage"];
        //shoppingImageView.backgroundColor = [UIColor redColor];
        shoppingImageView.contentMode = UIViewContentModeScaleAspectFit;
        shoppingImageView.userInteractionEnabled = YES;
        [_shoppingButton addSubview: shoppingImageView];
        
        self.shoppingLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.shoppingLabel.textColor = [UIColor whiteColor];
        //self.shoppingLabel.text = phoneNumber;
        self.shoppingLabel.font = FONT_NORMAL(15);
        //self.shoppingLabel.backgroundColor = [UIColor yellowColor];
        self.shoppingLabel.textAlignment = NSTextAlignmentCenter;
        [self.shoppingButton addSubview:self.shoppingLabel];
        
        self.discountLabel =[[UILabel alloc]initWithFrame:CGRectMake(150,self.postImageView.frame.origin.y+self.postImageView.frame.size.height+10 , 100, 30)];
        self.discountLabel.textColor = [UIColor redColor];
        self.discountLabel.font = FONT_NORMAL(15);
        //self.discountLabel.backgroundColor = [UIColor yellowColor];
        self.discountLabel.textAlignment = NSTextAlignmentCenter;
        //[self addSubview:self.discountLabel];
        
        NSInteger authorImageWidth = 30;
        self.authorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - authorImageWidth - 20, self.postImageView.frame.origin.y + self.postImageView.frame.size.height + 60, authorImageWidth, authorImageWidth)];
        self.authorImageView.layer.cornerRadius = authorImageWidth / 2;
        self.authorImageView.clipsToBounds = YES;
        [self addSubview:self.authorImageView];
        
        self.authorNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, self.postImageView.frame.origin.y + self.postImageView.frame.size.height+50, screenWidth-185, 50)];
        self.authorNameLabel.font = FONT_MEDIUM(11);
        self.authorNameLabel.numberOfLines = 2;
        self.authorNameLabel.minimumScaleFactor = 0.7;
        self.authorNameLabel.textColor = [UIColor blackColor];
        self.authorNameLabel.textAlignment = NSTextAlignmentRight;
        self.authorNameLabel.adjustsFontSizeToFitWidth = YES;
        //self.authorNameLabel.backgroundColor = [UIColor yellowColor];
        [self addSubview:self.authorNameLabel];
        
        self.moreButton = [[UIButton alloc]initWithFrame:CGRectMake(15,self.postImageView.frame.origin.y+self.postImageView.frame.size.height+60 , 50, 25)];
        //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            [self.moreButton setTitleColor:color forState:UIControlStateNormal ];
        } else {
           [self.moreButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        }
        
        [self.moreButton setTitle:@"بیشتر" forState:UIControlStateNormal];
        self.moreButton.titleLabel.font = FONT_NORMAL(11);
        [[self.moreButton layer] setCornerRadius:10.0f];
        [[self.moreButton layer] setMasksToBounds:YES];
        [[self.moreButton layer] setBorderWidth:1.0f];
        //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            [[self.moreButton layer] setBorderColor:color.CGColor];
        } else {
            [[self.moreButton layer] setBorderColor:MAIN_COLOR.CGColor];
        }
        [self addSubview:self.moreButton];
        
        self.shareButton = [[UIButton alloc]initWithFrame:CGRectMake(70,self.postImageView.frame.origin.y+self.postImageView.frame.size.height+60 , 50, 25)];
        //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            [self.shareButton setTitleColor:color forState:UIControlStateNormal ];
        } else {
            [self.shareButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        }
        
        [self.shareButton setTitle:@"اشتراک" forState:UIControlStateNormal];
        self.shareButton.titleLabel.font = FONT_NORMAL(11);
        [[self.shareButton layer] setCornerRadius:10.0f];
        [[self.shareButton layer] setMasksToBounds:YES];
        [[self.shareButton layer] setBorderWidth:1.0f];
        //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
        if ([customColor length]>0) {
            UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
            [[self.shareButton layer] setBorderColor:color.CGColor];
        } else {
            [[self.shareButton layer] setBorderColor:MAIN_COLOR.CGColor];
        }
        [self addSubview:self.shareButton];
        
        self.authorJobLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, self.authorNameLabel.frame.origin.y + 25, screenWidth - authorImageWidth - 40, 25)];
        self.authorJobLabel.font = FONT_NORMAL(13);
        self.authorJobLabel.minimumScaleFactor = 0.7;
        self.authorJobLabel.textColor = [UIColor blackColor];
        self.authorJobLabel.textAlignment = NSTextAlignmentRight;
        self.authorJobLabel.adjustsFontSizeToFitWidth = YES;
        //[self addSubview:self.authorJobLabel];

        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, self.authorImageView.frame.origin.y + self.authorImageView.frame.size.height , screenWidth - 30, 60)];
        //self.contentLabel.font = FONT_NORMAL(13);
        //self.contentLabel.textAlignment = NSTextAlignmentRight;
        //self.contentLabel.textColor = [UIColor blackColor];
        self.contentLabel.numberOfLines = 2;
        [self addSubview:self.contentLabel];
    }
    return self;
}
@end
