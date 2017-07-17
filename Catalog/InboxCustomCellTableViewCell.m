//
//  InboxCustomCellTableViewCell.m
//  Catalog
//
//  Created by Developer on 1/29/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "InboxCustomCellTableViewCell.h"
#import "Header.h"

@implementation InboxCustomCellTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,5,screenWidth-40,50)];
        self.titleLabel.font = FONT_BOLD(15);
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.textColor = [UIColor blackColor];
        //self.titleLabel.backgroundColor = [UIColor yellowColor];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
        
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+5, 130 , 25)];
        self.dateLabel.font = FONT_NORMAL(13);
        self.dateLabel.minimumScaleFactor = 0.7;
        self.dateLabel.textColor = [UIColor blackColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        //self.dateLabel.backgroundColor = [UIColor orangeColor];
        self.dateLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.dateLabel];
        
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height, screenWidth-40, 150)];
        self.contentLabel.font = FONT_MEDIUM(15);
        self.contentLabel.minimumScaleFactor = 0.7;
        self.contentLabel.numberOfLines = 10;
        self.contentLabel.textColor = [UIColor blackColor];
        self.contentLabel.textAlignment = NSTextAlignmentRight;
        self.contentLabel.adjustsFontSizeToFitWidth = YES;
        //self.contentLabel.backgroundColor = [UIColor purpleColor];
        [self addSubview:self.contentLabel];
    }
    return self;
}

@end
