//
//  CategoriesCustomCell.m
//  Catalog
//
//  Created by Developer on 1/22/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "CategoriesCustomCell.h"
#import "Header.h"

@implementation CategoriesCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSInteger categoryImageWidth = 15;
        self.categoryImageView = [[UIImageView alloc]initWithFrame:CGRectMake( screenWidth- 60, 22, categoryImageWidth, categoryImageWidth)];
        self.categoryImageView.layer.cornerRadius = categoryImageWidth / 2;
        self.categoryImageView.clipsToBounds = YES;
        [self addSubview:self.categoryImageView];
        
        self.categoryTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, screenWidth-60, 30)];
        self.categoryTitleLabel.font = FONT_MEDIUM(13);
        self.categoryTitleLabel.minimumScaleFactor = 0.7;
        self.categoryTitleLabel.textColor = [UIColor blackColor];
        self.categoryTitleLabel.textAlignment = NSTextAlignmentRight;
        self.categoryTitleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.categoryTitleLabel];
    }
    return self;
}
@end
