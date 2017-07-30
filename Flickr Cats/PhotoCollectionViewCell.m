//
//  CatCollectionViewCell.m
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-17.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@interface PhotoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation PhotoCollectionViewCell

-(void)setPhoto:(Photo *)photo{
    self.titleLabel.text = photo.title;
    self.imageView.image = photo.image;
    
    _photo = photo;
}


@end
