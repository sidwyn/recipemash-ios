//
//  ViewController.h
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/11/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *myCollectionView;
@property (nonatomic, strong) NSArray *recipeList;

- (IBAction)sampleText:(id)sender;
- (IBAction)takeImage:(id)sender;
- (IBAction)sampleImage:(id)sender;
@end
