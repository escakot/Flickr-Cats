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

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSURL *moreInfoURL;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.image = self.cat.image;
    self.titleLabel.text = self.cat.title;
    
//    https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&format=json&nojsoncallback=1&api_key=af2bac8217fed88cb5500a2858003bfa&photo_id=35949590396
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%li", @"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&format=json&nojsoncallback=1&api_key=af2bac8217fed88cb5500a2858003bfa&photo_id=", self.cat.catID]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
        NSError *jsonError;
        NSDictionary *catData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError)
        {
            NSLog(@"json Error: %@", jsonError.localizedDescription);
        }
        
        self.moreInfoURL = [NSURL URLWithString:catData[@"photo"][@"urls"][@"url"][0][@"_content"]];
    }];
    
    [dataTask resume];
}

- (IBAction)moreInfoButton:(UIButton *)sender
{
    
}

# pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SafariViewController *dvc = segue.destinationViewController;
    dvc.catURL = self.moreInfoURL;
}


@end
