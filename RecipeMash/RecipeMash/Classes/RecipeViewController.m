//
//  RecipeViewController.m
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/12/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "RecipeViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "VTPG_Common.h"

@interface RecipeViewController ()

@end

@implementation RecipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)openCookingDirections:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[self.comprehensiveRecipeInfo objectForKey:@"source"] objectForKey:@"sourceRecipeUrl"]]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cookingDirections.hidden = YES;
    if ([self.recipeInfo objectForKey:@"recipeName"]) {
        self.title = [self.recipeInfo objectForKey:@"recipeName"];
        self.recipeName.text = [self.recipeInfo objectForKey:@"recipeName"];
    }
    else if ([self.recipeInfo objectForKey:@"name"]) {
        self.title = [self.recipeInfo objectForKey:@"name"];
        self.recipeName.text = [self.recipeInfo objectForKey:@"name"];
    }
	// Do any additional setup after loading the view.
    
    // Load picture
    NSMutableString *eachImage = [NSMutableString string];
    if ([self.recipeInfo objectForKey:@"imageUrlsBySize"]) {
        eachImage = [[[self.recipeInfo objectForKey:@"imageUrlsBySize"] objectForKey:@"90"] mutableCopy];
    }
    else if ([self.recipeInfo objectForKey:@"image_url"]) {
        eachImage = [[self.recipeInfo objectForKey:@"image_url"] mutableCopy];
    }
    if (eachImage.length > 0) {
        [eachImage deleteCharactersInRange:NSMakeRange([eachImage length]-4, 4)];
        [eachImage appendString:@"600-c"];        
        self.mainImage.contentMode = UIViewContentModeScaleAspectFill;
        self.mainImage.showActivityIndicator = YES;
        self.mainImage.imageURL = [NSURL URLWithString:eachImage];
    }
    
    
    NSString *loadString = [NSString stringWithFormat:@"http://api.yummly.com/v1/api/recipe/%@?_app_id=5acf0d63&_app_key=cc99e4608c08207f0b898e6217ef80fa", [self.recipeInfo objectForKey:@"id"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:loadString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            self.comprehensiveRecipeInfo = responseObject;
            [self updateInfo];
        }
        else {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void)updateInfo {
    NSString *totalTime = [self.comprehensiveRecipeInfo objectForKey:@"totalTime"];
    if (totalTime != (id)[NSNull null]) {
        self.prepTime.text = [NSString stringWithFormat:@"%@", [self.comprehensiveRecipeInfo objectForKey:@"totalTime"]];
    }
    int numberOfServings = [[self.comprehensiveRecipeInfo objectForKey:@"numberOfServings"] integerValue];
    if (numberOfServings > 1) {
        self.numberOfServings.text = [NSString stringWithFormat:@"%i servings", numberOfServings];
    }
    else if (numberOfServings == 1) {
        self.numberOfServings.text = [NSString stringWithFormat:@"%i serving", numberOfServings];
    }
    NSMutableString *ingredientsString = [NSMutableString string];
    if ([self.comprehensiveRecipeInfo objectForKey:@"ingredientLines"]) {
        for (NSString *eachIngredient in [self.comprehensiveRecipeInfo objectForKey:@"ingredientLines"]) {
            [ingredientsString appendFormat:@"%@\n", eachIngredient];
        }
    }
    if (ingredientsString.length > 0)
        self.ingredients.text = ingredientsString;
    NSInteger rating = (NSInteger) [self.comprehensiveRecipeInfo objectForKey:@"rating"];
    self.oneStar.hidden = NO; self.twoStar.hidden = NO; self.threeStar.hidden = NO; self.fourStar.hidden = NO; self.fiveStar.hidden = NO;
    switch (rating) {
        case 1:
            self.twoStar.hidden = YES; self.threeStar.hidden = YES; self.fourStar.hidden = YES; self.fiveStar.hidden = YES;
            break;
        case 2:
            self.threeStar.hidden = YES; self.fourStar.hidden = YES; self.fiveStar.hidden = YES;
            break;
        case 3:
            self.fourStar.hidden = YES; self.fiveStar.hidden = YES;
            break;
        case 4:
            self.fiveStar.hidden = YES;
            break;
    }
    if (![[self.comprehensiveRecipeInfo objectForKey:@"source"] objectForKey:@"sourceRecipeUrl"]) {
        self.cookingDirections.hidden = YES;
    }
    else {
        self.cookingDirections.hidden = NO;
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
