//
//  RecipeViewController.m
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/12/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "RecipeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
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
    NSLog(@"Open la");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[self.comprehensiveRecipeInfo objectForKey:@"source"] objectForKey:@"sourceRecipeUrl"]]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cookingDirections.hidden = YES;
    NSLog(@"Loaded recipe view controller");
//    CGSize textSize = [self.ingredients.text sizeWithFont:self.ingredients.font constrainedToSize:CGSizeMake(self.ingredients.frame.size.width, MAXFLOAT) lineBreakMode:self.ingredients.lineBreakMode];
//    self.ingredients.frame = CGRectMake(self.ingredients.frame.origin.x, self.ingredients.frame.origin.y, textSize.width, textSize.height);
    
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
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:eachImage]];
        [self.mainImage setImageWithURLRequest: request
                              placeholderImage:[UIImage imageNamed:@"Swirl.jpg"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           NSLog(@"Success");
                                           [self.mainImage setImage:image];
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           NSLog(@"Failure");
                                       }];
        
    }
    // Load name
    
    
    
    NSString *loadString = [NSString stringWithFormat:@"http://api.yummly.com/v1/api/recipe/%@?_app_id=5acf0d63&_app_key=cc99e4608c08207f0b898e6217ef80fa", [self.recipeInfo objectForKey:@"id"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:loadString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            self.comprehensiveRecipeInfo = responseObject;
            [self updateInfo];
            NSLog(@"Yahoo!");
        }
        else {
            NSLog(@"Not a JSON Object");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void)updateInfo {
    NSLog(@"Updating info");
    NSLog(@"total time is %@", [self.comprehensiveRecipeInfo objectForKey:@"totalTime"]);
    if ([self.comprehensiveRecipeInfo objectForKey:@"totalTime"]) {
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
    switch (rating) {
        case 1:
            self.oneStar.hidden = NO;
            self.twoStar.hidden = YES;
            self.threeStar.hidden = YES;
            self.fourStar.hidden = YES;
            self.fiveStar.hidden = YES;
            break;
        case 2:
            self.oneStar.hidden = NO;
            self.twoStar.hidden = NO;
            self.threeStar.hidden = YES;
            self.fourStar.hidden = YES;
            self.fiveStar.hidden = YES;
            break;
        case 3:
            self.oneStar.hidden = NO;
            self.twoStar.hidden = NO;
            self.threeStar.hidden = NO;
            self.fourStar.hidden = YES;
            self.fiveStar.hidden = YES;
            break;
        case 4:
            self.oneStar.hidden = NO;
            self.twoStar.hidden = NO;
            self.threeStar.hidden = NO;
            self.fourStar.hidden = NO;
            self.fiveStar.hidden = YES;
            break;
        case 5:
            self.oneStar.hidden = NO;
            self.twoStar.hidden = NO;
            self.threeStar.hidden = NO;
            self.fourStar.hidden = NO;
            self.fiveStar.hidden = YES;
            break;
            
        default:
            break;
    }
    LOG_EXPR([[self.comprehensiveRecipeInfo objectForKey:@"source"] objectForKey:@"sourceRecipeUrl"]);
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
