//
//  SafariViewController.m
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-17.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import "SafariViewController.h"

@interface SafariViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SafariViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.catURL];
    
    [self.webView loadRequest:request];
}


@end
