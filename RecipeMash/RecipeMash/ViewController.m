//
//  ViewController.m
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/11/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "ViewController.h"
#import "Tesseract.h"
#import <AFNetworking/AFNetworking.h>
#import "RecipeListViewController.h"
#import "VTPG_Common.h"
#import "ChooseIngredientsViewController.h"
#import "ImageProcessing.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)sampleText:(id)sender
{
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setImage:[UIImage imageNamed:@"Test.jpg"]];
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
}


UIImage * gs_convert_image (UIImage * src_img) {
    CGColorSpaceRef d_colorSpace = CGColorSpaceCreateDeviceRGB();
    /*
     * Note we specify 4 bytes per pixel here even though we ignore the
     * alpha value; you can't specify 3 bytes per-pixel.
     */
    size_t d_bytesPerRow = src_img.size.width * 4;
    unsigned char * imgData = (unsigned char*)malloc(src_img.size.height*d_bytesPerRow);
    CGContextRef context =  CGBitmapContextCreate(imgData, src_img.size.width,
                                                  src_img.size.height,
                                                  8, d_bytesPerRow,
                                                  d_colorSpace,
                                                  kCGImageAlphaNoneSkipFirst);
    
    UIGraphicsPushContext(context);
    // These next two lines 'flip' the drawing so it doesn't appear upside-down.
    CGContextTranslateCTM(context, 0.0, src_img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    // Use UIImage's drawInRect: instead of the CGContextDrawImage function, otherwise you'll have issues when the source image is in portrait orientation.
    [src_img drawInRect:CGRectMake(0.0, 0.0, src_img.size.width, src_img.size.height)];
    UIGraphicsPopContext();
    
    /*
     * At this point, we have the raw ARGB pixel data in the imgData buffer, so
     * we can perform whatever image processing here.
     */
    
    
    // After we've processed the raw data, turn it back into a UIImage instance.
    CGImageRef new_img = CGBitmapContextCreateImage(context);
    UIImage * convertedImage = [[UIImage alloc] initWithCGImage:
                                new_img];
    
    CGImageRelease(new_img);
    CGContextRelease(context);
    CGColorSpaceRelease(d_colorSpace);
    free(imgData);
    return convertedImage;
}
- (UIImage *) toGrayscale:(UIImage*)img
{
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, img.size.width * img.scale, img.size.height * img.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method:     http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:img.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^(void) {
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        NSLog(@"got image");
        LOG_EXPR(chosenImage);
        UIImage *chosenImage2 = gs_convert_image(chosenImage);
        UIImage *chosenImage3 = [self toGrayscale:chosenImage2];
        NSLog(@"finished processing image");
        
        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
        [tesseract setVariableValue:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"];
        
        CGSize newSize = CGSizeMake(chosenImage3.size.width / 3, chosenImage3.size.height / 3);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [chosenImage3 drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        ImageWrapper *greyScale=Image::createImage(resizedImage, resizedImage.size.width, resizedImage.size.height);
        ImageWrapper *edges = greyScale.image->autoLocalThreshold();
        
        [tesseract setImage:edges.image->toUIImage()];
//        [tesseract setImage:[UIImage imageNamed:@"SampleReceipt.jpg"]];
        [tesseract recognize];

        NSString *longString = [tesseract recognizedText];
        NSLog(@"%@", [tesseract recognizedText]);
        NSMutableArray *testArray2 = [[longString componentsSeparatedByString:@"\n"] mutableCopy];
        
        NSLog(@"Before array");
        LOG_EXPR(testArray2);
        for (int i = 0; i < testArray2.count; i++) {
            NSString *pureString = [[[testArray2 objectAtIndex:i] componentsSeparatedByCharactersInSet: [[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
            [testArray2 replaceObjectAtIndex:i withObject:pureString];
        }
        
        LOG_EXPR(testArray2);
        
        ChooseIngredientsViewController *civc = [[ChooseIngredientsViewController alloc] init];
        civc.listOfIngredients = [testArray2 copy];
        [self.navigationController pushViewController:civc animated:YES];


    }];
}

- (IBAction)sampleImage:(id)sender {
    
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setVariableValue:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"];
    
    UIImage *chosenImage3 = [UIImage imageNamed:@"SampleReceipt.jpg"];
    CGSize newSize = CGSizeMake(chosenImage3.size.width / 3, chosenImage3.size.height / 3);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [chosenImage3 drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    ImageWrapper *greyScale=Image::createImage(resizedImage, resizedImage.size.width, resizedImage.size.height);
    ImageWrapper *edges = greyScale.image->autoLocalThreshold();
    
    [tesseract setImage:edges.image->toUIImage()];
    [tesseract recognize];
    
    NSString *longString = [tesseract recognizedText];
    NSLog(@"%@", [tesseract recognizedText]);
    NSMutableArray *testArray2 = [[longString componentsSeparatedByString:@"\n"] mutableCopy];
    
    NSLog(@"Before array");
    LOG_EXPR(testArray2);
    for (int i = 0; i < testArray2.count; i++) {
        NSCharacterSet *charactersToRemove = [NSCharacterSet decimalDigitCharacterSet];
        NSString *trimmedReplacement = [[[testArray2 objectAtIndex:i] componentsSeparatedByCharactersInSet:charactersToRemove ]
         componentsJoinedByString:@""];
        NSString *trimmedString = [trimmedReplacement stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
        [testArray2 replaceObjectAtIndex:i withObject:trimmedString];
    }
    
    [testArray2 removeObject:@""];
    
    LOG_EXPR(testArray2);
    
    ChooseIngredientsViewController *civc = [[ChooseIngredientsViewController alloc] init];
    civc.listOfIngredients = [testArray2 copy];
    [self.navigationController pushViewController:civc animated:YES];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



- (IBAction)takeImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
