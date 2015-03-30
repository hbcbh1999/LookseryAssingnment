//
//  UITextViewWithPlaceholder.h
//  LookseryAssingnment
//
//  Created by Valeriy Van on 3/30/15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>

@interface UITextViewWithPlaceholder : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
