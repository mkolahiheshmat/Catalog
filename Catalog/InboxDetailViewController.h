//
//  InboxDetailViewController.h
//  Catalog
//
//  Created by Developer on 1/29/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxDetailViewController : UIViewController
@property(nonatomic) NSString *message_id;
@property(nonatomic) NSString *message_Title;
@property(nonatomic, retain) NSDictionary *dictionary;
@end
