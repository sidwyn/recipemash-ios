//
//  RecipeViewController.h
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/12/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView/AsyncImageView.h>

@interface RecipeViewController : UIViewController

@property (nonatomic, assign) IBOutlet AsyncImageView *mainImage;
@property (nonatomic, assign) IBOutlet UILabel *recipeName;
@property (nonatomic, assign) IBOutlet UILabel *prepTime;
@property (nonatomic, assign) IBOutlet UILabel *numberOfServings;
@property (nonatomic, assign) IBOutlet UITextView *ingredients;
@property (nonatomic, assign) IBOutlet UIImageView *oneStar;
@property (nonatomic, assign) IBOutlet UIImageView *twoStar;
@property (nonatomic, assign) IBOutlet UIImageView *threeStar;
@property (nonatomic, assign) IBOutlet UIImageView *fourStar;
@property (nonatomic, assign) IBOutlet UIImageView *fiveStar;
@property (nonatomic, assign) IBOutlet UIButton *cookingDirections;

@property (nonatomic, retain) NSDictionary *recipeInfo;
@property (nonatomic, retain) NSDictionary *comprehensiveRecipeInfo;

- (IBAction)openCookingDirections:(id)sender;
@end
