//
//  NSString+highlight.m
//  LookseryAssingnment
//
//  Created by Valeriy Van on 4/1/15.
//  Copyright (c) 2015 looksery.com. All rights reserved.
//

#import "NSString+highlight.h"

@implementation NSString (highlight)

-(NSAttributedString*)addAttribute:(NSString*)attribute value:(id)value regex:(NSRegularExpression*)regex options:(NSRegularExpressionOptions)options {
    NSRange range = NSMakeRange(0, self.length);
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self];
    [regex enumerateMatchesInString:self options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [attributedText addAttribute:attribute value:value range:result.range];
    }];
    return attributedText;
}

@end
