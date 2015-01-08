//
//  ViewController.m
//  RichTextEditor
//
//  Created by Anar Enhsaihan on 1/7/15.
//  Copyright (c) 2015 Citta LLC. All rights reserved.
//

#import "ViewController.h"
#import "RTEGestureRecognizer.h"

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
    
    RTEGestureRecognizer *tapInterceptor = [[RTEGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet *touches, UIEvent *event) {
        // Here we just get the location of the touch
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchPoint = [touch locationInView:self.view];
        
        // What we do here is to get the element that is located at the touch point to see whether or not it is an image
        NSString *javascript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).toString()", touchPoint.x, touchPoint.y];
        NSString *elementAtPoint = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
        
        if ([elementAtPoint rangeOfString:@"Image"].location != NSNotFound) {
            // We set the inital point of the image for use latter on when we actually move it
            self.initialPointOfImage = touchPoint;
            // In order to make moving the image easy we must disable scrolling otherwise the view will just scroll and prevent fully detecting movement on the image.
            self.webView.scrollView.scrollEnabled = NO;
        } else {
            self.initialPointOfImage = CGPointZero;
        }
    };
    
    tapInterceptor.touchesEndedCallback = ^(NSSet *touches, UIEvent *event) {
        // Let's get the finished touch point
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchPoint = [touch locationInView:self.view];
        
        // And move that image!
        NSString *javascript = [NSString stringWithFormat:@"moveImageAtTo(%f, %f, %f, %f)", self.initialPointOfImage.x, self.initialPointOfImage.y, touchPoint.x, touchPoint.y];
        [self.webView stringByEvaluatingJavaScriptFromString:javascript];
        
        // All done, lets re-enable scrolling
        self.webView.scrollView.scrollEnabled = YES;
    };
    
    [self.webView.scrollView addGestureRecognizer:tapInterceptor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // Font Color Picker
    
    UIBarButtonItem *fontColorPicker = [[UIBarButtonItem alloc] initWithTitle:@"Color" style:UIBarButtonItemStyleBordered target:self action:@selector(displayFontColorPicker:)];
    
    NSString *foreColor = [self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('foreColor')"];
    UIColor *color = [self colorFromRGBValue:foreColor];
    if (color) {
        [fontColorPicker setTintColor:color];
    }
    
    [items addObject:fontColorPicker];
    
    // Font Picker
    UIBarButtonItem *fontPicker = [[UIBarButtonItem alloc] initWithTitle:@"Font" style:UIBarButtonItemStyleBordered target:self action:@selector(displayFontPicker:)];
    
    NSString *fontName = [self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontName')"];
    UIFont *font = [UIFont fontWithName:fontName size:[UIFont systemFontSize]];
    if (font) {
        [fontPicker setTitleTextAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] forState:UIControlStateNormal];
    }
    
    [items addObject:fontPicker];
    
    UIBarButtonItem *undo = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered target:self action:@selector(undo)];
    UIBarButtonItem *redo = [[UIBarButtonItem alloc] initWithTitle:@"Redo" style:UIBarButtonItemStyleBordered target:self action:@selector(redo)];
    
    BOOL undoAvailable = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('undo')"] boolValue];
    BOOL redoAvailable = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('redo')"] boolValue];
    
    if (!undoAvailable) {
        [undo setEnabled:NO];
    }
    
    if (!redoAvailable) {
        [redo setEnabled:NO];
    }
    
    [items addObjectsFromArray:@[undo, redo]];
    
    UIBarButtonItem *insertPhoto = [[UIBarButtonItem alloc] initWithTitle:@"Photo+" style:UIBarButtonItemStyleBordered target:self action:@selector(insertPhoto:)];
    [items addObject:insertPhoto];
    
    
    if (self.currentFontSize != size || ![self.currentForeColor isEqualToString:foreColor] || ![self.currentFontName isEqualToString:fontName] || self.currentUndoStatus != undoAvailable || self.currentRedoStatus != redoAvailable || sender == self) {
        self.navigationItem.leftBarButtonItems = items;
        self.currentFontSize = size;
        self.currentForeColor = foreColor;
        self.currentFontName = fontName;
        self.currentUndoStatus = undoAvailable;
        self.currentRedoStatus = redoAvailable;
    }

}

#pragma mark - Insert photo

-(void)insertPhoto:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    [popover presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.imagePickerPopover = popover;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    static int i = 0;
    
    // Obtain the path to save to
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"photo%i.png", i]];
    
    // Extract image from the picker and save it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:imagePath atomically:YES];
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('insertImage', false, '%@')", imagePath]];
    [self.imagePickerPopover dismissPopoverAnimated:YES];
    i++;
}

#pragma mark - Undo and Redo

-(void)undo
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('undo')"];
}

-(void)redo
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('redo')"];
}

#pragma mark - Highlight

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


#pragma mark - Font Color and Size

-(void)displayFontColorPicker:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font color" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Blue", @"Yellow", @"Green", @"Red", @"Orange", nil];
    [actionSheet showFromBarButtonItem:(UIBarButtonItem *)sender animated:YES];
}

- (void)displayFontPicker:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Helvetica", @"Courier", @"Arial", @"Zapfino", @"Verdana", nil];
    [actionSheet showFromBarButtonItem:(UIBarButtonItem *)sender animated:YES];
}

- (UIColor *)colorFromRGBValue:(NSString *)rgb { // General format is 'rgb(red, green, blue)'
    if ([rgb rangeOfString:@"rgb"].location == NSNotFound)
        return nil;
    
    NSMutableString *mutableCopy = [rgb mutableCopy];
    [mutableCopy replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
    [mutableCopy replaceCharactersInRange:NSMakeRange(mutableCopy.length-1, 1) withString:@""];
    
    NSArray *components = [mutableCopy componentsSeparatedByString:@","];
    int red = [[components objectAtIndex:0] intValue];
    int green = [[components objectAtIndex:1] intValue];
    int blue = [[components objectAtIndex:2] intValue];
    
    UIColor *retVal = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return retVal;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    selectedButtonTitle = [selectedButtonTitle lowercaseString];
    
    if ([actionSheet.title isEqualToString:@"Select a font"]) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontName', false, '%@')", selectedButtonTitle]];
    } else {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('foreColor', false, '%@')", selectedButtonTitle]];
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

#pragma mark - Bold, Italic, Underline

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
