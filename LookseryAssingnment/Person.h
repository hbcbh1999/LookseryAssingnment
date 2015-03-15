//
//  Person.h
//  LookseryAssingnment
//
//  Created by Valeriy Van on 09.03.15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Person : NSObject
@property long identifier; // don't set this
@property UIImage *image;
@property NSString *name;
@property BOOL isFemale;
@property NSDate *birthday;
@property NSArray *phones; // of NSString*
@property NSString *about;

// Only name is required.
// Init will not complain when name is nil allowing setting name letter over property.
// TODO: But inserting to database person with name nil will not be allowed.
- (instancetype)initWithId:(long)identifier image:(UIImage*)image name:(NSString*)name birthday:(NSDate*)birthday phones:(NSArray*)phones about:(NSString*)about isFemale:(BOOL)isFemale NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithImage:(UIImage*)image name:(NSString*)name birthday:(NSDate*)birthday phones:(NSArray*)phones about:(NSString*)about isFemale:(BOOL)isFemale;

- (BOOL)isNewRecord;

@end
