//
//  PersonViewController.h
//  LookseryAssingnment
//
//  Created by Valeriy Van on 09.03.15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@class PersonViewController;

@protocol PersonViewControllerDelegate <NSObject>

- (void)personViewController:(PersonViewController*)personViewController updatePerson:(Person*)person;
- (void)personViewController:(PersonViewController*)personViewController addPerson:(Person*)person;

@end

@interface PersonViewController : UITableViewController <UINavigationControllerDelegate>

@property (nonatomic) BOOL changed;
@property (nonatomic) BOOL editMode;
@property (nonatomic) Person *person;
@property (weak) UIViewController<PersonViewControllerDelegate> *personViewControllerDelegate;

- (void)addEditButtonAndRemoveCancelButton;

@end

