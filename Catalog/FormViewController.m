//
//  FormViewController.m
//  Catalog
//
//  Created by Developer on 3/28/17.
//  Copyright © 2017 Developer. All rights reserved.
//

#import "FormViewController.h"
#import "Header.h"
#import "ShamsiDatePicker.h"
#import "DateUtil.h"
#import "ConvertHexToColor.h"

#define MENU_WIDTH  screenWidth/1.5

@interface FormViewController () <UITextFieldDelegate,AZJPickerData>
{
    UILabel *titleLabel;
    UIView *tranparentView;
    BOOL isMenuShown;
    UIView *mainView;
    UIScrollView *scrollView;
    //UITextView *textView;
    UITextField *lastTextField;
    NSMutableDictionary *paramsDictionary;
    NSString *formTitleLabelText;
    UILabel *formTitleLabel;
    UIButton *sendButton;
    NSString *textFieldType;
    NSMutableDictionary *typeDictionary;
    UILabel *offlineLabel;
    ShamsiDatePicker *datePickerView;
    NSDictionary *fromDateDic;
    UIToolbar *dateToolbar;
}
@end

@implementation FormViewController

- (void)viewWillAppear:(BOOL)animated{
    datePickerView.hidden = YES;
    if ([self hasConnectivity]){
        offlineLabel.hidden = YES;
        [self fetchFormFields];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            titleLabel.text = self.titleText;
            offlineLabel.hidden = NO;
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeTopBar];
    
    [self scrollViewMaker];
    
    [self datePickerMaker];
    
    if ([self hasConnectivity]){
        [self fetchFormFields];
        offlineLabel.hidden = YES;
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            titleLabel.text = self.titleText;
            offlineLabel.hidden = NO;
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.cancelsTouchesInView = NO;
    [scrollView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - text field delegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.inputView == datePickerView) {
        [self.view endEditing:YES];
        [self showDatePickerView];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    datePickerView.hidden = YES;
    [dateToolbar removeFromSuperview];
    if (textField.frame.origin.y > screenHeight/2) {
        [UIView animateWithDuration:0.5 animations:^{
            scrollView.contentOffset = CGPointMake(0, textField.frame.origin.y-50);
        }];
    }
    if (textField.inputView == datePickerView) {
        [self.view endEditing:YES];
        [self showDatePickerView];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentOffset = CGPointMake(0,0);
    }];
    return YES;
}

-(void)textFieldDidChange :(UITextField *)textField{
    [paramsDictionary setObject:textField.text forKey:textField.placeholder];
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
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 17, 40, 40)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UIImage *buttonImageNormal = [UIImage imageNamed:@"backButton"];
    [backButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    //titleLabel.text = @"دریافت تخفیف";
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
}
- (void)scrollViewMaker{
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 70, screenWidth, screenHeight - 70)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(screenWidth, screenHeight * 2);
    
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
    [scrollView addSubview:offlineLabel];
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

-(void)backAction{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendButtonAction{
    [self.view endEditing:YES];
    if ([self hasConnectivity]){
        for (NSString *key in paramsDictionary) {
            id value = [paramsDictionary objectForKey:key];
            NSString *type = [typeDictionary objectForKey:key];
            if ([value length] == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"لطفا تمامی فیلدها را تکمیل نمایید." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }else{
                if ([type isEqualToString:@"email"]) {
                    if(![self NSStringIsValidEmail:value]){
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"لطفا ایمیل را صحیح وارد کنید." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        [alert addAction:action];
                        [self presentViewController:alert animated:YES completion:nil];
                        return;
                    }
                }
                if([type isEqualToString:@"mobile"]){
                    if ([value length] != 11) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"لطفا شماره موبایل را صحیح تایپ کنید." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        [alert addAction:action];
                        [self presentViewController:alert animated:YES completion:nil];
                        return;
                    }
                }
                /*
                 if([type isEqualToString:@"tel"]){
                 if ([value length] != 11) {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"لطفا شماره تلفن را صحیح تایپ کنید." preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 }];
                 [alert addAction:action];
                 [self presentViewController:alert animated:YES completion:nil];
                 return;
                 }
                 }
                 */
            }
        }
        [self sendFormInfoToServer];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"شما در حالت آفلاین هستید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)tapAction:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
    [dateToolbar removeFromSuperview];
    datePickerView.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        scrollView.contentOffset = CGPointMake(0,0);
    }];
}

- (CGFloat)getHeightOfString:(NSString *)labelText{
    UIFont *myFont = FONT_MEDIUM(15);
    if (IS_IPHONE_5_IOS7 || IS_IPHONE_5_IOS8 || IS_IPHONE_4_AND_OLDER_IOS7 || IS_IPHONE_4_AND_OLDER_IOS8) {
        myFont = FONT_MEDIUM(15);
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
                                 NSFontAttributeName:FONT_MEDIUM(15)
                                 };
    NSString* txt = labelText;
    NSAttributedString* aString = [[NSAttributedString alloc] initWithString: txt attributes: attributes];
    CGSize sizeOfText = [aString boundingRectWithSize:CGSizeMake( screenWidth - 50,CGFLOAT_MAX)
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              context:nil].size;
    
    //boundingRectWithSize: CGSizeMake( self.view.bounds.size.width,CGFLOAT_MAX)
    //     options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
    //   context: nil].size;
    CGFloat height = sizeOfText.height;
    if (IS_IPHONE_4_AND_OLDER_IOS8)
        height = sizeOfText.height + 10;
    return height;
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)datePickerMaker{
    datePickerView = [[ShamsiDatePicker alloc]init];
    datePickerView.frame = CGRectMake(0, screenHeight - 195, screenWidth, 195);
    //datePickerView.backgroundColor = [UIColor cyanColor];
    datePickerView.delegate = self;
    [self.view addSubview:datePickerView];
    datePickerView.hidden = YES;
}
- (void)showDatePickerView{
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textfield = (UITextField *)view;
            if (![textfield.placeholder isEqualToString:@"birth_date"]) {
                [textfield resignFirstResponder];
            }
        }
    }
    datePickerView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        datePickerView.alpha = 100.0;
        [self makeToolBarOnView:datePickerView];
    }];
}

- (void)makeToolBarOnView:(UIView *)aView{
    [dateToolbar removeFromSuperview];
    dateToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,screenHeight - 220,screenWidth,44)];
    [dateToolbar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"انجام شد"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(doneToolbarItem)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc] initWithTitle:@"انصراف"
                                                                        style:UIBarButtonItemStyleDone target:self action:@selector(cancelToolbarItem)];
    dateToolbar.items = @[barButtonDone,flex,barButtonCancel];
    barButtonDone.tintColor=[UIColor whiteColor];
    barButtonCancel.tintColor=[UIColor whiteColor];
    [self.view addSubview:dateToolbar];
}

- (void)doneToolbarItem{
    datePickerView.hidden = YES;
    [dateToolbar removeFromSuperview];
}

- (void)cancelToolbarItem{
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textfield = (UITextField *)view;
            if ([textfield.placeholder isEqualToString:@"birth_date"]) {
                textfield.text = @"";
                datePickerView.hidden = YES;
                [dateToolbar removeFromSuperview];
            }
        }
    }
}

#pragma mark - my pickerview delegate
- (void)selectedAZJPickerData:(NSDictionary *)dic{
    
    NSString *day = [dic objectForKey:@"Day"];
    NSString *month = [dic objectForKey:@"Month"];
    NSString *year = [dic objectForKey:@"Year"];
    
    fromDateDic = [[NSDictionary alloc]initWithObjectsAndKeys:
                   day,@"Day",
                   [NSNumber numberWithInteger:[DateUtil convertMonthNameToNumber:month]],@"Month",
                   year, @"Year", nil];
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textfield = (UITextField *)view;
            //[textfield resignFirstResponder];
            if ([textfield.placeholder isEqualToString:@"birth_date"]) {
                textfield.text = [NSString stringWithFormat:@"%@ %@ %@", day, month, year];
                [paramsDictionary setObject:textfield.text forKey:textfield.placeholder];
            }
        }
    }
}

#pragma mark - Form Parser

- (void)makeElementsOfFormView:(NSDictionary *)elements{
    paramsDictionary = [[NSMutableDictionary alloc]init];
    typeDictionary = [[NSMutableDictionary alloc]init];
    CGFloat ypos = formTitleLabel.frame.origin.y + formTitleLabel.frame.size.height + 20;
    for (NSDictionary *dic in elements) {
        NSString *keyString = [dic objectForKey:@"alias"];
        //NSString *valueString = [dic objectForKey:@"value"];
        [paramsDictionary setObject:@"" forKey:keyString];
        NSString *typeString = [dic objectForKey:@"type"];
        [typeDictionary setObject:typeString forKey:keyString];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2 + 20, ypos, screenWidth/2 - 30, 25)];
        label.numberOfLines = 0;
        label.font = FONT_NORMAL(13);
        label.minimumScaleFactor = 0.5;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = [dic objectForKey:@"name"];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentRight;
        [scrollView addSubview:label];
        
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(20, ypos, screenWidth/2+20, 25)];
        textField.backgroundColor = [UIColor whiteColor];
        //textField.text = [dic objectForKey:@"value"];
        textField.text = @"";
        
        UIColor *whiteColor = [UIColor whiteColor];
        textField.attributedPlaceholder =[[NSAttributedString alloc] initWithString:keyString attributes:@{NSForegroundColorAttributeName: whiteColor}];
        
        textField.placeholder = keyString;
        textField.delegate = self;
        textField.font = FONT_NORMAL(12);
        textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textField.layer.borderWidth = 1.0;
        textField.layer.cornerRadius = 5;
        textField.clipsToBounds = YES;
        textField.minimumFontSize = 0.5;
        textField.adjustsFontSizeToFitWidth = YES;
        textField.textAlignment = NSTextAlignmentCenter;
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.userInteractionEnabled = YES;
        textFieldType = [dic objectForKey:@"type"];
        if ([textFieldType  isEqualToString: @"tel"]||[textFieldType  isEqualToString: @"mobile"]) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        } else if([textFieldType isEqualToString:@"email"]){
            textField.keyboardType = UIKeyboardTypeEmailAddress;
        }else if ([textFieldType isEqualToString:@"date"]){
            textField.inputView = datePickerView;
        }
        [scrollView addSubview:textField];
        lastTextField = textField;
        ypos += 35;
    }
    sendButton = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth/2)-50,ypos+40 ,100, 35)];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitle:@"ثبت" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    sendButton.titleLabel.font = FONT_NORMAL(17);
    NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        sendButton.backgroundColor = color;
    } else {
        sendButton.backgroundColor = MAIN_COLOR;
    }
    [[sendButton layer] setCornerRadius:10.0f];
    [[sendButton layer] setMasksToBounds:YES];
    [[sendButton layer] setBorderWidth:1.0f];
    //NSString *customColor = [[NSUserDefaults standardUserDefaults]objectForKey:@"customColor"];
    if ([customColor length]>0) {
        UIColor *color = [ConvertHexToColor colorWithHexString:customColor];
        [[sendButton layer] setBorderColor:color.CGColor];
    } else {
        [[sendButton layer] setBorderColor:MAIN_COLOR.CGColor];
    }
    //sendButton.alpha = 0.0;
    [scrollView addSubview:sendButton];
    
    scrollView.contentSize = CGSizeMake(screenWidth, ypos + 120);
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

- (void)fetchFormFields{ //:(NSInteger)authorId {
    //   [noResultLabelPost removeFromSuperview];
    [ProgressHUD show:@""];
    
    NSDictionary *params = @{
                             @"author_id":CUSTOMER_AUTHOR_ID
                             };
    //NSDictionary *params = paramsDictionary;
    
    //NSLog(@"params = %@",params);
    /*http://catalogtest.yarima.co/Mobiles/catalog_get_form_generator*/
    NSString *url = @"http://catalog2.yarima.co/Mobiles/catalog_get_form_generator";
    //NSString *url = [NSString stringWithFormat:@"%@catalog_get_author", BaseURL3];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        NSDictionary *tempDic = [(NSDictionary *)responseObject objectForKey:@"data"];
        
        [[NSUserDefaults standardUserDefaults]setObject:tempDic forKey:@"formDic"];
        
        if ([[tempDic allKeys]count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        NSString *title = [tempDic objectForKey:@"title"];
        if ([title length] == 0) {
            titleLabel.text = self.titleText;
        } else {
            titleLabel.text = title;
        }
        formTitleLabelText = [tempDic objectForKey:@"description"];
        /*
         formTitleLabelText = @"شرکت فناوری اطلاعات و ارتباطات هوشمند یاریما، مفتخر است به یاری حق تعالی و بهره گیری از نیروهای مجرب و با استعداد در سطوح مختلف و همچنین بکارگیری استانداردهای روز جهانی، به این مهم نائل آید که ظرف مدتی کوتاه، میان برترین شرکت های ارائه دهنده خدمات فن آوری اطلاعات و ارتباطات قرار گیرد.این مجموعه می کوشد، با استفاده از تخصص های درونی خود، کسب کار مشتریانش را به عنوان شرکای تجاری خود توسعه دهد و از هیچ کوششی برای اعتلای کسب و کار و موقعیت شرکای تجاری خود دریغ نخواهد نمود.اعتقاد ما بر آن است که آنچه در توان داریم را در جهت اعتلای اهداف مشتریان خود بگماریم تا بواسطه پیشرفت آنها و نزدیکی هرچه بیشتر آنها به اهدافشان ما نیز بتوانیم به اهداف خود نائل آییم. کوشش ما آن است تا به مسائل از نگاه مشتری بنگریم. شرکت فناوری اطلاعات و ارتباطات هوشمند یاریما، مفتخر است به یاری حق تعالی و بهره گیری از نیروهای مجرب و با استعداد در سطوح مختلف و همچنین بکارگیری استانداردهای روز جهانی، به این مهم نائل آید که ظرف مدتی کوتاه، میان برترین شرکت های ارائه دهنده خدمات فن آوری اطلاعات و ارتباطات قرار گیرد.این مجموعه می کوشد، با استفاده از تخصص های درونی خود، کسب کار مشتریانش را به عنوان شرکای تجاری خود توسعه دهد و از هیچ کوششی برای اعتلای کسب و کار و موقعیت شرکای تجاری خود دریغ نخواهد نموداعتقاد ما بر آن است که آنچه در توان داریم را در جهت اعتلای اهداف مشتریان خود بگماریم تا بواسطه پیشرفت آنها و نزدیکی هرچه بیشتر آنها به اهدافشان ما نیز بتوانیم به اهداف خود نائل آییم. کوشش ما آن است تا به مسائل از نگاه مشتری بنگریم";
         */
        formTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,0,screenWidth-40, [self getHeightOfString:formTitleLabelText])];
        formTitleLabel.text = formTitleLabelText;
        formTitleLabel.font = FONT_MEDIUM(15);
        formTitleLabel.numberOfLines = 0;
        //        formTitleLabel.baselineAdjustment = YES;
        //        formTitleLabel.adjustsFontSizeToFitWidth = YES;
        //        formTitleLabel.minimumScaleFactor = 0.5;
        //        formTitleLabel.clipsToBounds = YES;
        //        formTitleLabel.backgroundColor = [UIColor clearColor];
        //        formTitleLabel.textColor = [UIColor blackColor];
        //        formTitleLabel.textAlignment = NSTextAlignmentRight;
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
        //NSString* txt = [NSString stringWithFormat:@"%@%@",descriptionText,descriptionText];
        NSAttributedString* aString = [[NSAttributedString alloc] initWithString:formTitleLabelText attributes: attributes];
        formTitleLabel.attributedText = aString;
        formTitleLabel.numberOfLines = 0;
        [scrollView addSubview:formTitleLabel];
        //dispatch_async(dispatch_get_main_queue(), ^{
        [self makeElementsOfFormView:[tempDic objectForKey:@"options"]];
        //});
    }failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        //isBusyNow = NO;
    }];
}

- (void)sendFormInfoToServer{
    //   [noResultLabelPost removeFromSuperview];
    [ProgressHUD show:@""];
    
    [paramsDictionary setObject:CUSTOMER_AUTHOR_ID forKey:@"author_id"];
    
    //NSDictionary *params = @{
    //@"author_id":[NSNumber numberWithInteger:self.author_id]
    //@"author_id":CUSTOMER_AUTHOR_ID
    //};
    
    //NSLog(@"params = %@",params);
    /*http://catalogtest.yarima.co/Mobiles/catalog_submit_form_generator*/
    //NSString *url = [NSString stringWithFormat:@"%@catalog_get_author", BaseURL3];
    NSString * url = @"http://catalog2.yarima.co/Mobiles/catalog_submit_form_generator";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    manager.requestSerializer.timeoutInterval = 45;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:url parameters:paramsDictionary progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        [ProgressHUD dismiss];
        long tempDic = [[(NSDictionary *)responseObject objectForKey:@"success"]longValue];
        
        if (tempDic == 1){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"اطلاعات با موفقیت ذخیره شد." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }else if (tempDic != 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        
    }failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"خطا" message:@"خطای سرور.لطفا دوباره تلاش کنید." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"تایید" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        //isBusyNow = NO;
    }];
}
@end
