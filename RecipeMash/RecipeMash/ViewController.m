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
#import "FridgeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "RecipeViewController.h"
#import "NSString+Levenshtein.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Collection View Methods


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retval = CGSizeMake(160, 200);
    return retval;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.contentView.layer.borderWidth = 0;
    cell.contentView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.7] CGColor];
    
    UILabel *mainLabel;
    if ([cell.contentView viewWithTag:200]) {
        mainLabel = (UILabel *)[cell.contentView viewWithTag:200];
    }
    else {
        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 150, 40)];
        mainLabel.tag = 200;
        mainLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        mainLabel.numberOfLines = 0;
        mainLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:mainLabel];
    }
    UIImageView *eachImage;
    if ([cell.contentView viewWithTag:100]) {
        eachImage = (UIImageView *)[cell.contentView viewWithTag:100];
    }
    else {
        eachImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        eachImage.tag = 100;
        eachImage.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:eachImage];
    }
    [cell.contentView bringSubviewToFront:mainLabel];
    
    if (indexPath.row > 9) {
        return cell;
    }
    mainLabel.text = [[self.recipeList objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    NSMutableString *eachImageString = [NSMutableString string];
    eachImageString = [[[self.recipeList objectAtIndex:indexPath.row] objectForKey:@"image_url"] mutableCopy];
    
    [eachImageString deleteCharactersInRange:NSMakeRange([eachImageString length]-4, 4)];
    [eachImageString appendString:@"600-c"];
    
    LOG_EXPR(eachImageString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:eachImageString]];
    [eachImage setImageWithURLRequest: request
                          placeholderImage:[UIImage imageNamed:@"Swirl.jpg"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       [eachImage setImage:image];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSLog(@"Failure");
                                   }];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    RecipeViewController *rvc = [storyboard instantiateViewControllerWithIdentifier:@"RecipeViewController"];
    rvc.recipeInfo = [self.recipeList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:rvc animated:YES];
}

# pragma mark - Main Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Receipt2RecipeLogo2.png"]];
    titleView.contentMode = UIViewContentModeCenter;
    self.navigationItem.titleView = titleView;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://smsa.berkeley.edu/hackathon/random.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // API is not working well, so only pull from API if we have no ingredients.
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            self.recipeList = [responseObject objectForKey:@"list"];
            if (self.recipeList.count < 1) {
                return;
            }
            [self.myCollectionView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (IBAction)goToFridge:(id)sender {
    FridgeViewController *fvc = [[FridgeViewController alloc] init];
    [self.navigationController pushViewController:fvc animated:YES];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [SVProgressHUD showWithStatus:@"Parsing Ingredients"];
    [picker dismissViewControllerAnimated:YES completion:^(void) {
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        [self processImage:chosenImage];
    }];
}

- (void)processImage:(UIImage *)theImage{
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setVariableValue:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"];
    
    UIImage *chosenImage3 = theImage;
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
    NSMutableArray *testArray2 = [[longString componentsSeparatedByString:@"\n"] mutableCopy];
    
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
    
    // Remove short letters
    NSMutableArray *toDelArray = [NSMutableArray array];
    for (int i = 0; i < testArray2.count; i++) {
        if ([[testArray2 objectAtIndex:i] length] <= 2) {
            [toDelArray addObject:[testArray2 objectAtIndex:i]];
            continue;
        }
        // Capitalize first letter
        [testArray2 replaceObjectAtIndex:i withObject:[[testArray2 objectAtIndex:i] capitalizedString]];
        // Remove extra whitespace
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:nil];
        NSString *trimmedString = [regex stringByReplacingMatchesInString:[testArray2 objectAtIndex:i] options:0 range:NSMakeRange(0, [[testArray2 objectAtIndex:i] length]) withTemplate:@" "];
        [testArray2 replaceObjectAtIndex:i withObject:trimmedString];

    }
    
    [testArray2 removeObjectsInArray:toDelArray];
    
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"GroceryList" ofType:@"plist"];
    epicGroceryList = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
    
    NSMutableArray *greatWords = [NSMutableArray array];
    for (NSString *eachIngredient in testArray2) {
        for (NSArray *eachArray in epicGroceryList) {
            for (NSString *eachItem in [epicGroceryList objectForKey:eachArray]) {
                // Split OCR into words
                NSArray *theWords = [eachIngredient componentsSeparatedByString:@" "];
                for (NSString *eachWord in theWords)
                    // Use Levensthein Distance algorithm - thanks to Peter Norvig where I learned this in CS61A!
                    if ([eachWord compareWithWord:eachItem matchGain:0.5 missingCost:1] < 2) {
                        [greatWords addObject:eachWord];
                    }
                    else {
//                        NSLog(@"%@",(eachWord));
                    }
            }
        }
    }
    [greatWords setArray:[[NSSet setWithArray:greatWords] allObjects]];
    testArray2 = greatWords;

//    LOG_EXPR(testArray2);
    
    if (testArray2.count == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No ingredients found. Please try another receipt." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [SVProgressHUD dismiss];
    
    ChooseIngredientsViewController *civc = [[ChooseIngredientsViewController alloc] init];
    civc.listOfIngredients = [testArray2 copy];
    civc.parentController = self;
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:civc];
    [self presentViewController:navC animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [as showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    switch (buttonIndex) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            else {
                [[[UIAlertView alloc] initWithTitle:@"Nice try!" message:@"You ain't got no camera." delegate:nil cancelButtonTitle:@":(" otherButtonTitles:nil] show];
                return;
            }
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            return;
        default:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary || picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Image Editing Methods

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

@end
