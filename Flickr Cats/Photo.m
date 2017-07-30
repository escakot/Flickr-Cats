//
//  Photo.m
//  Flickr Cats
//
//  Created by Errol Cheong on 2017-07-17.
//  Copyright © 2017 Errol Cheong. All rights reserved.
//

#import "Photo.h"

@implementation Photo


-(instancetype)initWithInfo:(NSDictionary*)info
{
    self = [super init];
    if (self)
    {
        _photoID = [info[@"id"] integerValue];
        _owner = info[@"owner"];
        _secret = info[@"secret"];
        _server = [info[@"server"] integerValue];
        _farm = [info[@"farm"] integerValue];
        _title = info[@"title"];
    }
    return self;
}


@end
