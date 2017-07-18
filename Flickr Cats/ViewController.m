//
//  ViewController.m
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-17.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import "ViewController.h"
#import "Cat.h"
#import "CatCollectionViewCell.h"
#import "DetailViewController.h"
#import "API.h"



@interface ViewController () <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray<Cat*>* listOfCats;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *catFlowLayout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.catFlowLayout.minimumLineSpacing = 20;
    self.catFlowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    
    
    //UIGesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginSegue:)];
    [self.collectionView addGestureRecognizer:tapGesture];
    self.collectionView.userInteractionEnabled = YES;
    
    
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=%@&tags=cat", api_key]];
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
        
        
        NSMutableArray *tempCats = [@[] mutableCopy];
        NSArray *catPhoto = catData[@"photos"][@"photo"];
        for (NSDictionary *info in catPhoto) {
            Cat *cat = [[Cat alloc] initWithInfo:info];
            [tempCats addObject:cat];
        }
        self.listOfCats = [tempCats copy];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.collectionView reloadData];
        }];
    }];
    
    [dataTask resume];
}


# pragma mark - UICollectionView Data Source Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listOfCats.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CatCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"catCell" forIndexPath:indexPath];
    
    Cat *cat = self.listOfCats[indexPath.row];
    if (cat.image == nil)
    {
        NSString *catURL = [NSString stringWithFormat:@"%@%li%@/%li/%li_%@%@", @"https://farm", cat.farm, @".staticflickr.com/", cat.server, cat.catID, cat.secret, @".jpg"];
//        NSLog(@"%@", catURL);
        self.listOfCats[indexPath.row].image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:catURL]]];
    }
    
    cell.cat = self.listOfCats[indexPath.row];
    
    
    return cell;
    
}

# pragma mark - UICollectionView Delegate Methods

# pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *dvc = segue.destinationViewController;
    NSIndexPath *indexPath = sender;
    dvc.cat = self.listOfCats[indexPath.row];
}

# pragma mark - UI Gesture Recognizers Methods

- (void)beginSegue:(UITapGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[sender locationInView:self.collectionView]];
        [self performSegueWithIdentifier:@"detailSegue" sender:indexPath];
    }
   
}


@end
