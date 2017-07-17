//
//  InboxCustomCellTableViewCell.h
//  Catalog
//
//  Created by Developer on 1/29/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TABLEVIEW_CELL_HEIGHT   90
#define TABLEVIEW_CELL_HEIGHT_Iphone6   140

@interface InboxCustomCellTableViewCell : UITableViewCell
@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, retain)UILabel *contentLabel;
@property(nonatomic, retain)UILabel *dateLabel;
@end
