    //
    //  MapViewController.m
    //  BehsaClinic-Patient
    //
    //  Created by Yarima on 3/28/17.
    //  Copyright © 2017 Arash Z. Jahangiri. All rights reserved.
    //

#import "MapViewController.h"
#import "MapPin.h"
#import "BranchModel.h"
#import "Header.h"
#import "ConvertHexToColor.h"

@interface MapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *myLocationManager;
    MKMapView *_mapView;
    UILabel *titleLabel;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeTopBar];
    
    //set up zoom level
    MKCoordinateSpan zoom;
    zoom.latitudeDelta = .1f; //the zoom level in degrees
    zoom.longitudeDelta = .1f;//the zoom level in degrees
    
        //    //the region the map will be showing
        //    MKCoordinateRegion myRegion;
        //    myRegion.center = center;
        //    myRegion.span = zoom;
    
        //programmatically create a map that fits the screen
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, screenWidth, screenHeight - 64)];
        //set the map location/region
        //[_mapView setRegion:myRegion animated:YES];
    
    _mapView.mapType = MKMapTypeStandard;//standard map(not satellite)
    _mapView.delegate = self;
    [self.view addSubview:_mapView];//add map to the view
    
    MKUserLocation *location = _mapView.userLocation;
    [_mapView setCenterCoordinate:location.coordinate animated:YES];
    
            myLocationManager = [[CLLocationManager alloc] init];
            myLocationManager.delegate = self;
            myLocationManager.distanceFilter = 1;
            myLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [myLocationManager requestWhenInUseAuthorization];
            [myLocationManager requestAlwaysAuthorization];
            [myLocationManager startUpdatingLocation];
            _mapView.userTrackingMode=MKUserTrackingModeFollow;
            _mapView.mapType=MKMapTypeStandard;
    
    [self addAnnotation];
    
}
-(void)addAnnotation{
    for (NSInteger i = 0; i < [_branchesArray count]; i++) {
        BranchModel *entity = [_branchesArray objectAtIndex:i];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(entity.latitude, entity.longitude);
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
        MKCoordinateRegion region = {coord, span};
        MapPin *pin = [[MapPin alloc] init];
        [pin setCoordinate:coord];
        pin.title = entity.nameString;
        pin.subtitle = entity.phoneString;
        pin.coordinate = coord;
        [_mapView setRegion:region animated:YES];
        [_mapView addAnnotation:pin];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    
}

-(void)makeTopBar{
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
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55,26,screenWidth-110,25)];
    titleLabel.text = @"نقشه";
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

- (void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Update the user location, as long as the user changes this method (including the first positioning to the user location
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    NSLog(@"userLocation = %@",userLocation);
        //Set the map display range (if you do not make the regional settings will automatically display the scope of the region and specify the current user location for the map center point)
    //MKCoordinateSpan span=MKCoordinateSpanMake(0.01, 0.01);
    //MKCoordinateRegion region=MKCoordinateRegionMake(userLocation.location.coordinate, span);
    //[_mapView setRegion:region animated:true];
}

#pragma mark When the pin is displayed, note that the annotation parameter in the method is the pin object that is about to be displayed
/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MapPin class]]) {
        static NSString *key1=@"AnnotationKey1";
            //MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:key1];
            //if (!annotationView) {
        MKAnnotationView *annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:key1];
        annotationView.canShowCallout=true;
        annotationView.calloutOffset=CGPointMake(0, 1);
            //annotationView.leftCalloutAccessoryView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"snow10.png"]];
            //}
        annotationView.annotation=annotation;
        return annotationView;
    }else {
        return nil;
    }
}
*/
@end
