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
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *bold = [[UIBarButtonItem alloc] initWithTitle:@"B" style:UIBarButtonItemStyleBordered target:self action:@selector(bold)];
    UIBarButtonItem *italic = [[UIBarButtonItem alloc] initWithTitle:@"I" style:UIBarButtonItemStyleBordered target:self action:@selector(italic)];
    UIBarButtonItem *underline = [[UIBarButtonItem alloc] initWithTitle:@"U" style:UIBarButtonItemStyleBordered target:self action:@selector(underline)];
    
    [items addObjectsFromArray:@[bold, italic, underline]];
    
    self.navigationItem.rightBarButtonItems = items;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
