//
//  ViewController.h
//  RichTextEditor
//
//  Created by Anar Enhsaihan on 1/7/15.
//  Copyright (c) 2015 Citta LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL currentBoldStatus;
@property (nonatomic) BOOL currentItalicStatus;
@property (nonatomic) BOOL currentUnderlineStatus;
@property (nonatomic) int currentFontSize;
@property (nonatomic, strong) NSString *currentForeColor;
@property (nonatomic, strong) NSString *currentFontName;
@property (nonatomic) BOOL currentUndoStatus;
@property (nonatomic) BOOL currentRedoStatus;
@property (nonatomic, strong) UIPopoverController *imagePickerPopover;
@property (nonatomic) CGPoint initialPointOfImage;
@end

