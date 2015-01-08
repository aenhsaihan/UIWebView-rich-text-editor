//
//  RTEGestureRecognizer.m
//  RichTextEditor
//
//  Created by Anar Enhsaihan on 1/8/15.
//  Copyright (c) 2015 Citta LLC. All rights reserved.
//

#import "RTEGestureRecognizer.h"

@implementation RTEGestureRecognizer

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchesBeganCallback) {
        _touchesBeganCallback(touches, event);
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchesEndedCallback) {
        _touchesEndedCallback(touches, event);
    }
}

-(BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    if ([[preventingGestureRecognizer description] rangeOfString:@"UIScrollViewPanGestureRecognizer"].location != NSNotFound) {
        return NO;
    }
    
//    return [self canBePreventedByGestureRecognizer:preventingGestureRecognizer];
    
    return YES;
}

@end
