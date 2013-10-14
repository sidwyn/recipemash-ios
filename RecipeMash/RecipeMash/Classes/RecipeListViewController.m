//
//  RecipeListViewController.m
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/11/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "RecipeListViewController.h"
#import "VTPG_Common.h"
#import "TeamDetailCell.h"
#import "RecipeViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AsyncImageView/AsyncImageView.h>

@interface RecipeListViewController ()

@end

@implementation RecipeListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Recipes";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;

    if (self.ingredientsList.count > 0) {
        [self sendToServer];
    }
    
    // Cell's image quick hack
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(22, 22), NO, 0.0);
    blankImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


- (void)sendToServer
{
    // Parse ingredients
    NSMutableString *concatIngre = [NSMutableString string];
    for (NSString *eachIngredient in self.ingredientsList) {
        [concatIngre appendFormat:@"%@,", eachIngredient];
    }
    [concatIngre deleteCharactersInRange:NSMakeRange([concatIngre length]-1, 1)];
    
    NSString *fullAPICall = [NSString stringWithFormat:@"http://api.yummly.com/v1/api/recipes?_app_id=5acf0d63&_app_key=cc99e4608c08207f0b898e6217ef80fa&q=%@", concatIngre];
    LOG_EXPR(fullAPICall);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:fullAPICall parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            self.recipeList = [responseObject objectForKey:@"matches"];
            [self.tableView reloadData];
            NSLog(@"Yahoo!");
        }
        else {
            NSLog(@"Not a JSON Object");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recipeList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSDictionary *recipe = [self.recipeList objectAtIndex:indexPath.row];
    cell.textLabel.text = [recipe objectForKey:@"recipeName"];
    
    NSMutableString *eachImage = [[[recipe objectForKey:@"imageUrlsBySize"] objectForKey:@"90"] mutableCopy];
    
    [eachImage deleteCharactersInRange:NSMakeRange([eachImage length]-4, 4)];
    [eachImage appendString:@"360-c"];
    
    cell.imageView.image = blankImage;
    
    AsyncImageView *image = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    image.showActivityIndicator = NO;
    image.imageURL = [NSURL URLWithString:eachImage];
    [cell addSubview:image];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Pushing");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RecipeViewController *rvc = [storyboard instantiateViewControllerWithIdentifier:@"RecipeViewController"];

//    RecipeViewController *rvc = [[RecipeViewController alloc] init];
    rvc.recipeInfo = [self.recipeList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:rvc animated:YES];
}

@end
