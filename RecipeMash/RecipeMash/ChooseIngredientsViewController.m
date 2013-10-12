//
//  ChooseIngredientsViewController.m
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/11/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "ChooseIngredientsViewController.h"
#import "VTPG_Common.h"
#import <AFNetworking/AFNetworking.h>
#import "RecipeListViewController.h"
#import "FridgeViewController.h"
#import "NSString+Levenshtein.h"

@interface ChooseIngredientsViewController ()

@property (nonatomic, retain) NSMutableArray *listOfSelectedIngredientsIndices;

@end

@implementation ChooseIngredientsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    self.title = @"Choose Ingredients";
//    LOG_EXPR(self.listOfIngredients);
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(makeRecipes)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose Ingredients" message:@"Please choose the ingredients found in your receipt. Items highlighted in red have been ticked for your convenience." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"GroceryList" ofType:@"plist"];
    epicGroceryList = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
//    LOG_EXPR(epicGroceryList);
    
//    For Presentation purposes
//    self.listOfIngredients = @[@"Cheese", @"Pepper", @"Facebook", @"Salt", @"Flour", @"Chimpanzee", @"Eggs", @"Haste Street", @"Bread", @"Bananas", @"Facebook", @"Google"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)makeRecipes {
    // Replace with %20
    
    [self dismissViewControllerAnimated:YES completion:^(void) {
        // Open up Fridge controller
        FridgeViewController *fvc = [[FridgeViewController alloc] init];
        [self.parentController.navigationController pushViewController:fvc animated:YES];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.listOfIngredients) {
        return self.listOfIngredients.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *ingredient = [self.listOfIngredients objectAtIndex:indexPath.row];
    cell.textLabel.text = ingredient;
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    for (NSArray *eachArray in epicGroceryList) {
        for (NSString *eachItem in [epicGroceryList objectForKey:eachArray]) {
            BOOL found = NO;
            // Split OCR into words
            NSArray *theWords = [ingredient componentsSeparatedByString:@" "];
            for (NSString *eachWord in theWords) {
//                // Check if each word contains each other
//                if ([eachWord rangeOfString:eachItem].location != NSNotFound) {
//                    found = YES;
//                }
//                else if ([eachItem rangeOfString:eachWord].location != NSNotFound) {
//                    found = YES;
//                }
                
                // Use Levensthein Distance Algorithm
                if ([eachWord compareWithWord:eachItem matchGain:0 missingCost:1] < 2) {
                    found = YES;
                }
            }
            
            if (found) {
                cell.textLabel.textColor = [UIColor redColor];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    // Search in database
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType ]!= UITableViewCellAccessoryCheckmark) {
        // If it's not on, select it
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.listOfSelectedIngredientsIndices addObject:indexPath];
    }
    else {
        // If it's on, remove it
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
        [self.listOfSelectedIngredientsIndices removeObject:indexPath];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
