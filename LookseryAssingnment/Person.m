//
//  Person.m
//  LookseryAssingnment
//
//  Created by Valeriy Van on 09.03.15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import "Person.h"

@interface Person ()
@end

@implementation Person

- (instancetype)initWithId:(long)_id image:(UIImage*)i name:(NSString*)n birthday:(NSDate*)b phones:(NSArray*)p about:(NSString*)a isFemale:(BOOL)s
{
    if ((self = [super init])) {
        self.identifier = _id;
        self.image = i;
        self.name = [n copy];
        self.birthday = b;
        self.phones = [p copy];
        self.about = a;
        self.isFemale = s;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage*)i name:(NSString*)n birthday:(NSDate*)b phones:(NSArray*)p about:(NSString*)a isFemale:(BOOL)s
{
    return [self initWithId:0 image:i name:n birthday:b phones:p about:a isFemale:s];
}

- (BOOL)isNewRecord {
    return self.identifier == 0;
}

@end
