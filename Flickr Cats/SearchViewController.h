//
//  SearchViewController.h
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-18.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewDelegate <NSObject>

- (void)returnNewSearchTag:(NSArray*)listOfPhotos;

@end


@interface SearchViewController : UIViewController

@property (weak, nonatomic) id <SearchViewDelegate> delegate;

@end
