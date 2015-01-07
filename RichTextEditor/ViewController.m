//
//  ViewController.m
//  RichTextEditor
//
//  Created by Anar Enhsaihan on 1/7/15.
//  Copyright (c) 2015 Citta LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURL *indexFileURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
    
    [self checkSelection:self];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
    
    UIMenuItem *highlightMenuItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(highlight)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObject:highlightMenuItem]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 This is a bit more complicated compared to our other actions as we have to check the current color of the selected text to see whether or not to highlight it or to remove the highlight. Firstly we get the current value of the background color, we then check to see if it’s equal to ‘rgb(255, 255, 0)’ which is the rgb equivalent of yellow and if so we reset the color to white else we highlight the selection by setting the background color to yellow.
 */
-(void)highlight
{
    NSString *currentColor = [self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('backColor')"];
    if ([currentColor isEqualToString:@"rgb(255, 255, 0)"]) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'white')"];
    } else {
        [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'yellow')"];
    }
}

-(void)checkSelection:(id)sender
{
    BOOL boldEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Bold')"] boolValue];
    BOOL italicEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Italic')"] boolValue];
    BOOL underlineEnabled = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandState('Underline')"] boolValue];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *bold = [[UIBarButtonItem alloc] initWithTitle:(boldEnabled) ? @"[B]" : @"B" style:UIBarButtonItemStyleBordered target:self action:@selector(bold)];
    UIBarButtonItem *italic = [[UIBarButtonItem alloc] initWithTitle:(italicEnabled) ? @"[I]" : @"I" style:UIBarButtonItemStyleBordered target:self action:@selector(italic)];
    UIBarButtonItem *underline = [[UIBarButtonItem alloc] initWithTitle:(underlineEnabled) ? @"[U]" : @"U" style:UIBarButtonItemStyleBordered target:self action:@selector(underline)];
    
    [items addObjectsFromArray:@[bold, italic, underline]];
    
    /*
     We add the bar button items to the array and then if there are any changes to the status of bold, italic or underline since we last checked or if this is the first time then we set that array as the navigation items right bar button items and update the statuses.
     */
    
    if (self.currentBoldStatus != boldEnabled || self.currentItalicStatus != italicEnabled || self.currentUnderlineStatus != underlineEnabled || sender == self) {
        self.navigationItem.rightBarButtonItems = items;
        self.currentBoldStatus = boldEnabled;
        self.currentItalicStatus = italicEnabled;
        self.currentUnderlineStatus = underlineEnabled;
    }
    
    NSString *currentColor = [self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('backColor')"];
    BOOL isYellow = [currentColor isEqualToString:@"rgb(255, 255, 0)"];
    UIMenuItem *highlightMenuItem = [[UIMenuItem alloc] initWithTitle:(isYellow) ? @"De-Highlight" : @"Highlight" action:@selector(highlight)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObject:highlightMenuItem]];
    
    [items removeAllObjects];
    
    UIBarButtonItem *plusFontSize = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(fontSizeUp)];
    UIBarButtonItem *minusFontSize = [[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStyleBordered target:self action:@selector(fontSizeDown)];
    
    int size = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue];
    if (size == 7) {
        plusFontSize.enabled = NO;
    } else if (size == 1) {
        minusFontSize.enabled = NO;
    }
    
    [items addObjectsFromArray:@[plusFontSize, minusFontSize]];
    
    if (self.currentFontSize != size || sender == self) {
        self.navigationItem.leftBarButtonItems = items;
        self.currentFontSize = size;
    }

}

/*
 Before we add our bar button items and everything else we need to add some global variables to keep the status of our font size, font color and font so that we only update the the bar button items when we need to. Why do we need to do this you might ask, the reason behind it is if you update them every 0.1 seconds then the action of the bar button item is never sent so it renders them useless.
 */
-(void)fontSizeUp
{
    [self.timer invalidate];
    
    int size = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] + 1;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
}

-(void)fontSizeDown
{
    [self.timer invalidate];
    
    int size = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] - 1;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
}

-(void)bold {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
}

-(void)italic {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
}

-(void)underline {
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Underline\")"];
}

@end
