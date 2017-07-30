//
//  SearchViewController.m
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-18.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import "SearchViewController.h"
#import "Photo.h"
#import "API.h"
#import "FlickrKit.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@import MapKit;
@import SafariServices;

@interface SearchViewController () <CLLocationManagerDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) CLLocationCoordinate2D userCoordinates;
@property (strong, nonatomic) NSArray *listOfPhotos;


//Flickr Kit
@property (strong, nonatomic) FlickrKit *flickrKit;
@property (strong, nonatomic) FKDUNetworkOperation *completeAuthOp;
@property (strong, nonatomic) FKDUNetworkOperation *checkAuthOp;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
//    ?oauth_nonce=89601180
//    &oauth_timestamp=1305583298
//    &oauth_consumer_key=653e7a6ecc1d528c516cc8f92cf98611
//    &oauth_signature_method=HMAC-SHA1
//    &oauth_version=1.0
//    &oauth_callback=http%3A%2F%2Fwww.example.com
//    NSString *tokenURL = @"https://www.flickr.com/services/oauth/request_token";
//    NSString *tokenURL = @"GET&https%3A%2F%2Fwww.flickr.com%2Fservices%2Foauth%2Frequest_token";
//    NSString *oauth_nonce = [NSString stringWithFormat:@"%%26oauth_nonce%%3D%i", arc4random_uniform(99999999)];
//    NSInteger unixTime = (NSInteger)[[NSDate date] timeIntervalSince1970];
//    NSString *oauth_timestamp = [NSString stringWithFormat:@"%%26oauth_timestamp%%3D%li", unixTime];
//    NSString *oauth_consumer_key = [NSString stringWithFormat:@"%%26oauth_consumer_key%%3D%@", api_key];
//    NSString *oauth_signature_method = @"%26oauth_signature_method%3DHMAC-SHA1";
//    NSString *oauth_version = @"%26oauth_version%3D1.0";
//    NSString *oauth_callback = @"&oauth_callback%3DiOSFlickrApp:%252F%252F";
//    NSString *signatureString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", tokenURL, oauth_callback, oauth_consumer_key, oauth_nonce, oauth_signature_method, oauth_timestamp, oauth_version];
    
//    NSString *hmac = [self hmacsha1:signatureString secret:shared_secret];
//    NSLog(@"%@", hmac);
    
//    NSLog(@"%@, %@", signatureString, oauth_signature);
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:concatURL]];
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *newSession = [NSURLSession sessionWithConfiguration:configuration];
//    NSURLSessionDataTask *newDataTask = [newSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        if (error)
//        {
//            NSLog(@"Error: %@", error.localizedDescription);
//        }
//        
//        NSError *jsonError;
//        NSDictionary *tokenData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
//        
//        if (jsonError)
//        {
//            NSLog(@"json Error: %@", jsonError.localizedDescription);
//        }
//        
//        
//        NSLog(@"%@", tokenData);
//    }];
//    
//    [newDataTask resume];
//
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthCallback:) name:@"URLSCHEMENOTIFICATION" object:nil];
}

- (IBAction)locationSwitchTapped:(UISwitch *)sender {
    if (sender.isOn)
    {
        [self.locationManager requestWhenInUseAuthorization];
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            self.locationManager.delegate = self;
            [self.locationManager requestLocation];
//            [self.flickrKit checkAuthorizationOnCompletion:^(NSString * _Nullable userName, NSString * _Nullable userId, NSString * _Nullable fullName, NSError * _Nullable error) {
                [self flickrBeginAuth];
            
//            }];
        }
    }
}


- (IBAction)doneButton:(UIBarButtonItem*)sender {
    [self performNewQuery];
}
- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Flickr Auth

- (void)flickrBeginAuth
{
    //FlickrKit
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:api_key sharedSecret:shared_secret];
    NSURL *callBackURL = [NSURL URLWithString:@"iosflickrapp://auth"];
    [[FlickrKit sharedFlickrKit] beginAuthWithCallbackURL:callBackURL permission:FKPermissionWrite completion:^(NSURL * _Nullable flickrLoginPageURL, NSError * _Nullable error) {
        if (!error) {
//            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:flickrLoginPageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:flickrLoginPageURL];
            safari.delegate = self;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self presentViewController:safari animated:YES completion:nil];
            }];
        } else {
            NSLog(@"beginAuth: %@", error.localizedDescription);
        }
    }];
}

- (void)flickrCompleteAuth:(NSURL*)callbackURLNotification
{

    NSURL *callbackURL = callbackURLNotification;
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL completion:^(NSString * _Nullable userName, NSString * _Nullable userId, NSString * _Nullable fullName, NSError * _Nullable error) {
        NSLog(@"%@\n%@\n%@", userName, userId, fullName);
        
    }];
    
    [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString * _Nullable userName, NSString * _Nullable userId, NSString * _Nullable fullName, NSError * _Nullable error) {
        NSLog(@"%@\n%@\n%@", userName, userId, fullName);
    }];
    
}

#pragma mark - Query Methods

-(void)performNewQuery
{
    NSURL *url;
    if (self.locationSwitch.isOn)
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=%@&tags=%@&has_geo=1&lat=%.5f&lon=%.5f", api_key, self.tagTextField.text, 43.644625, -79.395197]];
        
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=%@&tags=%@&has_geo=1", api_key, self.tagTextField.text]];
    }
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    FKFlickrPhotosGeoPhotosForLocation *photosForLocation = [[FKFlickrPhotosGeoPhotosForLocation alloc] init];
    photosForLocation.lat = @"43.656238";
    photosForLocation.lon = @"-79.380470";
    photosForLocation.accuracy = @"8";
//    photosForLocation.extras = [NSString stringWithFormat:@"tags=%@", self.tagTextField.text];
    
    [[FlickrKit sharedFlickrKit] call:photosForLocation completion:^(NSDictionary<NSString *,id> * _Nullable response, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"%@", error.localizedDescription);
        }
        NSLog(@"%@", [response description]);
        if (response)
        {
            //            NSMutableArray *tempPhotos = [@[] mutableCopy];
            for (NSDictionary* photoData in [response valueForKeyPath:@"photo.photo"]) {
                NSLog(@"%@", photoData);
            }
        }
    }];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
        NSError *jsonError;
        NSDictionary *photoData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError)
        {
            NSLog(@"json Error: %@", jsonError.localizedDescription);
        }
        
//        NSLog(@"%@",[photoData description]);
        
        NSMutableArray *tempPhotos = [@[] mutableCopy];
        NSArray *photoPhoto = photoData[@"photos"][@"photo"];
        for (NSDictionary *info in photoPhoto) {
            Photo *photo = [[Photo alloc] initWithInfo:info];
            [tempPhotos addObject:photo];
        }
        self.listOfPhotos = [tempPhotos copy];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.delegate returnNewSearchTag:self.listOfPhotos];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
    
    [dataTask resume];
}

#pragma mark - CLLocation Manager Delegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.userCoordinates = [locations lastObject].coordinate;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
}

# pragma mark - Safari Delegate


-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    
}

-(NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL title:(NSString *)title
{
    NSLog(@"%@", URL);
    return nil;
}

# pragma mark - NSNotification Methods

- (void)userAuthCallback:(NSNotification*)notification
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSURL *callbackURL = notification.object;
    [self flickrCompleteAuth:callbackURL];
}


//- (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key {
//    
//    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
//    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
//    
//    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
//    
//    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
//    
//    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
//    
//    NSString *hash = [HMAC base64EncodedStringWithOptions:0];
//    
//    return hash;
//}

@end
