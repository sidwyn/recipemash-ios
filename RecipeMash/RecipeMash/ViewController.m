//
//  ViewController.m
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/11/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "ViewController.h"
#import "Tesseract.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setImage:[UIImage imageNamed:@"Test.jpg"]];
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
