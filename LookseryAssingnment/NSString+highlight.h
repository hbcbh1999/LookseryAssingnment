//
//  NSString+highlight.h
//  LookseryAssingnment
//
//  Created by Valeriy Van on 4/1/15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (highlight)
-(NSAttributedString*)addAttribute:(NSString*)attribute value:(id)value regex:(NSRegularExpression*)regex options:(NSRegularExpressionOptions)options;
@end
