//
//  ViewController.m
//  Flickr Photos
//
//  Created by Errol Cheong on 2017-07-17.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import "ViewController.h"
#import "Photo.h"
#import "PhotoCollectionViewCell.h"
#import "DetailViewController.h"
#import "SearchViewController.h"
#import "API.h"



@interface ViewController () <UICollectionViewDataSource, SearchViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray<Photo*>* listOfPhotos;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *photoFlowLayout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (!self.listOfPhotos)
    {
        [self performSegueWithIdentifier:@"searchSegue" sender:nil];
    }
    
    //Flow Layout
    self.photoFlowLayout.minimumLineSpacing = 20;
    self.photoFlowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    
    
    //UIGesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginSegue:)];
    [self.collectionView addGestureRecognizer:tapGesture];
    self.collectionView.userInteractionEnabled = YES;
}

# pragma mark - UICollectionView Data Source Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listOfPhotos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    
    Photo *photo = self.listOfPhotos[indexPath.row];
    if (photo.image == nil)
    {
        NSString *photoURL = [NSString stringWithFormat:@"%@%li%@/%li/%li_%@%@", @"https://farm", photo.farm, @".staticflickr.com/", photo.server, photo.photoID, photo.secret, @".jpg"];
//        NSLog(@"%@", photoURL);
        self.listOfPhotos[indexPath.row].image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
    }
    
    cell.photo = self.listOfPhotos[indexPath.row];
    
    
    return cell;
    
}


# pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailSegue"])
    {
        DetailViewController *dvc = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        dvc.photo = self.listOfPhotos[indexPath.row];
    }
    if ([segue.identifier isEqualToString:@"searchSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        SearchViewController *searchViewController = navController.viewControllers[0];
        searchViewController.delegate = self;
    }
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

# pragma mark - SearchView Controller Delegate Methods

- (void)returnNewSearchTag:(NSArray*)listOfPhotos
{
    self.listOfPhotos = listOfPhotos;
    [self.collectionView reloadData];
}


@end
