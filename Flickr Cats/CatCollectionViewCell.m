//
//  CatCollectionViewCell.m
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-17.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import "CatCollectionViewCell.h"

@interface CatCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CatCollectionViewCell

-(void)setCat:(Cat *)cat{
    self.titleLabel.text = cat.title;
    self.imageView.image = cat.image;
    
    _cat = cat;
}


@end
