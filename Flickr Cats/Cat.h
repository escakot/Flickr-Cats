//
//  Cat.h
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-17.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface Cat : NSObject <MKAnnotation>

@property (assign, nonatomic) NSInteger catID;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *secret;
@property (assign, nonatomic) NSInteger server;
@property (assign, nonatomic) NSInteger farm;
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

-(instancetype)initWithInfo:(NSDictionary*)info;

@end
