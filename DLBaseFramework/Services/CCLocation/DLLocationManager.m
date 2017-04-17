//
//  DLLocationManager.m
//  DLLocationManager
//
//  Created by 卢迎志 on 14-12-10.
//  Copyright (c) 2014年 卢迎志. All rights reserved.
//

#import "DLLocationManager.h"
#import "DLUserDefaults.h"

@interface DLLocationManager (){
    CLLocationManager* _manager;
}

AS_BLOCK(LocationBlock, locationBlock);
AS_BLOCK(NSStringBlock, cityBlock);
AS_BLOCK(NSStringBlock, addressBlock);
AS_BLOCK(LocationErrorBlock, errorBlock);

AS_MODEL(CLLocationCoordinate2D, lastCoordinate);
AS_MODEL_STRONG(NSString, lastCity);
AS_MODEL_STRONG(NSString, lastAddress);
AS_FLOAT(latitude);
AS_FLOAT(longitude);

@end

@implementation DLLocationManager

DEF_SINGLETON(DLLocationManager);

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.lastCity = [[DLUserDefaults sharedInstance] objectForKey:DLLastCity];
        self.lastAddress = [[DLUserDefaults sharedInstance] objectForKey:DLLastAddress];
        self.longitude = [[[DLUserDefaults sharedInstance] objectForKey:DLLastLongitude] floatValue];
        self.latitude = [[[DLUserDefaults sharedInstance] objectForKey:DLLastLatitude] floatValue];
    }
    return self;
}

//获取经纬度
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock
{
    self.locationBlock = [locaiontBlock copy];
    [self startLocation];
}

- (void) getLocationCoordinate:(LocationBlock) locaiontBlock  withAddress:(NSStringBlock) addressBlock
{
    self.locationBlock = [locaiontBlock copy];
    self.addressBlock = [addressBlock copy];
    [self startLocation];
}

- (void) getAddress:(NSStringBlock)addressBlock
{
    self.addressBlock = [addressBlock copy];
    [self startLocation];
}
//获取省市
- (void) getCity:(NSStringBlock)cityBlock
{
    self.cityBlock = [cityBlock copy];
    [self startLocation];
}

- (void) getCity:(NSStringBlock)cityBlock error:(LocationErrorBlock) errorBlock
{
    self.cityBlock = [cityBlock copy];
    self.errorBlock = [errorBlock copy];
    [self startLocation];
}
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks,NSError *error)
     {
         if (placemarks.count > 0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             _lastCity = [NSString stringWithFormat:@"%@%@",placemark.administrativeArea,placemark.locality];
             [[DLUserDefaults sharedInstance] setObject:_lastCity forKey:DLLastCity];
             NSLog(@"______%@",_lastCity);

             _lastAddress = placemark.name;//[NSString stringWithFormat:@"%@%@%@%@%@%@",placemark.country,placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark.name];//详细地址
             [[DLUserDefaults sharedInstance] setObject:_lastAddress forKey:DLLastAddress];
             NSLog(@"______%@",_lastAddress);
         }
         if (_cityBlock) {
             _cityBlock(_lastCity);
             _cityBlock = nil;
         }
         if (_addressBlock) {
             _addressBlock(_lastAddress);
             _addressBlock = nil;
         }
     }];
    
    _lastCoordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude ,newLocation.coordinate.longitude );
    if (_locationBlock) {
        _locationBlock(_lastCoordinate);
        _locationBlock = nil;
    }

    NSLog(@"%f--%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    [[DLUserDefaults sharedInstance] setObject:@(newLocation.coordinate.latitude) forKey:DLLastLatitude];
    [[DLUserDefaults sharedInstance] setObject:@(newLocation.coordinate.longitude) forKey:DLLastLongitude];

    [manager stopUpdatingLocation];
}

-(void)startLocation
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        _manager=[[CLLocationManager alloc]init];
        _manager.delegate=self;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
//        [_manager requestAlwaysAuthorization];
        _manager.distanceFilter=100;
        
        /** 由于IOS8中定位的授权机制改变 需要进行手动授权
         * 获取授权认证，两个方法：
         * [self.locationManager requestWhenInUseAuthorization];
         * [self.locationManager requestAlwaysAuthorization];
         */
        if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            NSLog(@"requestWhenInUseAuthorization");
            [_manager requestWhenInUseAuthorization];
//            [self.locationManager requestAlwaysAuthorization];
        }
        
        [_manager startUpdatingLocation];
    }
    else
    {
        UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启定位服务,请到设置->隐私,打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alvertView show];
    }
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [self stopLocation];
}
-(void)stopLocation
{
    _manager = nil;
}


@end
