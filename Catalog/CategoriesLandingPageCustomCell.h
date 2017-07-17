//
//  CategoriesLandingPageCustomCell.h
//  Catalog
//
//  Created by Developer on 3/4/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TABLEVIEW_CELL_HEIGHT   480
#define TABLEVIEW_CELL_HEIGHT_Iphone6   530

@interface CategoriesLandingPageCustomCell : UITableViewCell
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UILabel *dateLabel;
@property(nonatomic, retain)UILabel *categoryLabel;
@property(nonatomic, retain)UIImageView *placeholderImage;
@property(nonatomic, retain)UIImageView *postImageView;
@property(nonatomic, retain)UILabel *likeCountLabel;
@property(nonatomic, retain)UILabel *viewCountLabel;
@property(nonatomic, retain)UIImageView *authorImageView;
@property(nonatomic, retain)UIImageView *categoryImageView;
@property(nonatomic, retain)UIImageView *videoImageView;
@property(nonatomic, retain)UILabel *authorNameLabel;
@property(nonatomic, retain)UIButton *moreButton;
@property(nonatomic, retain)UILabel *authorJobLabel;
@property(nonatomic, retain)UILabel *contentLabel;
@property(nonatomic, retain)UIImageView *toolImageView;
@property(nonatomic, retain)UIButton *favButton;
@property(nonatomic, retain)UIButton *heartButton;
@property(nonatomic, retain)UIButton *shareButton;
@property(nonatomic, retain)UIButton *shoppingButton;
@property(nonatomic, retain)UILabel *shoppingLabel;
@property(nonatomic, retain)UILabel *discountLabel;
@end
