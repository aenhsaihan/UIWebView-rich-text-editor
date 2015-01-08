//
//  RTEGestureRecognizer.h
//  RichTextEditor
//
//  Created by Anar Enhsaihan on 1/8/15.
//  Copyright (c) 2015 Citta LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchEventBlock)(NSSet * touches, UIEvent * event);

@interface RTEGestureRecognizer : UIGestureRecognizer

@property (nonatomic, copy) TouchEventBlock touchesBeganCallback;
@property (nonatomic, copy) TouchEventBlock touchesEndedCallback;
@end
