//
//  DetailViewController.m
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-17.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import "DetailViewController.h"
#import "SafariViewController.h"
#import "API.h"
#import <MapKit/MapKit.h>

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURL *moreInfoURL;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.image = self.photo.image;
    self.navigationItem.title = self.photo.title;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&format=json&nojsoncallback=1&api_key=%@&photo_id=%li", api_key, self.photo.photoID]];
    NSURL *geoURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&format=json&nojsoncallback=1&api_key=%@&photo_id=%li", api_key, self.photo.photoID]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLRequest *geoRequest = [[NSURLRequest alloc] initWithURL:geoURL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
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
        
        self.moreInfoURL = [NSURL URLWithString:photoData[@"photo"][@"urls"][@"url"][0][@"_content"]];
    }];
    
    NSURLSessionDataTask *geoTask = [session dataTaskWithRequest:geoRequest completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
        NSError *jsonError;
        NSDictionary *geoData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError)
        {
            NSLog(@"json Error: %@", jsonError.localizedDescription);
        }
        
        self.photo.coordinate = CLLocationCoordinate2DMake([geoData[@"photo"][@"location"][@"latitude"] floatValue], [geoData[@"photo"][@"location"][@"longitude"] floatValue]);
        NSLog(@"%@",geoData[@"photo"][@"location"]);
        //Map Information
        self.mapView.showsBuildings = YES;
        self.mapView.showsPointsOfInterest = YES;
        MKCoordinateSpan span = MKCoordinateSpanMake(.5f, .5f);
        
        
        //Point Annotation
        MKPointAnnotation *myPoint = [[MKPointAnnotation alloc]init];
        myPoint.title = @"Photo location:";
        myPoint.subtitle = self.photo.title;
        myPoint.coordinate = self.photo.coordinate;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.mapView.region = MKCoordinateRegionMake(self.photo.coordinate, span);
            [self.mapView addAnnotation:myPoint];
        }];
        
    }];
    
    [dataTask resume];
    [geoTask resume];
}

# pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SafariViewController *dvc = segue.destinationViewController;
    dvc.photoURL = self.moreInfoURL;
}


@end
