//
//  FridgeViewController.m
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/12/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "FridgeViewController.h"
#import "RecipeListViewController.h"
#import "RecipesViewController.h"
#import "TeamDetailsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "VTPG_Common.h"
#import <AFNetworking/AFNetworking.h>

@interface FridgeViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end

@implementation FridgeViewController

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

    self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookUserId"];
    if (!self.userId) {
        NSArray *permissions = [NSArray arrayWithObjects:@"user_about_me", nil];
        self.loginView.readPermissions = permissions;
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          /* handle success + failure in block */
                                          if (!error) {
                                              FBRequest *me = [[FBRequest alloc] initWithSession:session
                                                                                       graphPath:@"me"];
                                              [me startWithCompletionHandler:^(FBRequestConnection *connection,
                                                                               NSDictionary<FBGraphUser> *aUser,
                                                                               NSError *error) {
                                                  NSLog(@"User id is %@", aUser.id);
                                                  [[NSUserDefaults standardUserDefaults] setObject:aUser.id forKey:@"facebookUserId"];
                                                  [self getListOfIngredients];
                                                  
                                              }];                                      }
                                          else {
                                              LOG_EXPR(error);
                                          }
                                      }];
    }
    
    [self getListOfIngredients];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *makeRecipesButton = [[UIBarButtonItem alloc] initWithTitle:@"Recipes" style:UIBarButtonItemStylePlain target:self action:@selector(makeRecipes)];
    self.navigationItem.rightBarButtonItem = makeRecipesButton;
    self.title = @"My Fridge";
}

- (void)viewDidAppear:(BOOL)animated {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"listOfSavedIngredients"];
    self.listOfMyIngredients = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    [self.tableView reloadData];
}

- (void)getListOfIngredients {
    return;
    if (!self.userId) {
        return;
    }
    LOG_EXPR(self.userId);
    NSString *toString = [NSString stringWithFormat:@"http://smsa.berkeley.edu/hackathon/get.php?id=%@", self.userId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:toString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            NSArray *ingredients = [responseObject objectForKey:@"list"];
            NSMutableArray *listOfIngredients = [NSMutableArray array];
            for (NSDictionary *eachIngredient in ingredients) {
                [listOfIngredients addObject:[eachIngredient objectForKey:@"ingredient"]];
            }
            // Only get if my current count is 0, if not assume my local copy is correct
            if (self.listOfMyIngredients.count == 0) {
                self.listOfMyIngredients = [listOfIngredients copy];
                [self.tableView reloadData];
            }
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


- (void)makeRecipes {
    NSMutableArray *finalArray = [NSMutableArray array];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark && cell.textLabel.text.length > 0) {
            [finalArray addObject:[[NSString stringWithFormat:@"%@", cell.textLabel.text] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        }
    }
    
    if (finalArray.count == 0) {
        [[[UIAlertView alloc] initWithTitle:@"You're lying!" message:@"Your fridge is empty. Better stock up before the zombies come!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
//    NSMutableArray *toMakeRecipesArray = [[NSMutableArray alloc] init];
//    for (NSString *eachIngredient in self.listOfMyIngredients) {
//        NSString *newString = [eachIngredient stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//        [toMakeRecipesArray addObject:newString];
//    }
    RecipeListViewController *rlvc = [[RecipeListViewController alloc] init];
    rlvc.ingredientsList = [finalArray copy];
    [self.navigationController pushViewController:rlvc animated:YES];
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
    return self.listOfMyIngredients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [self.listOfMyIngredients objectAtIndex:indexPath.row];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.listOfMyIngredients removeObjectAtIndex:indexPath.row];
        
        NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:self.listOfMyIngredients];
        [[NSUserDefaults standardUserDefaults] setObject:data2 forKey:@"listOfSavedIngredients"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType ]!= UITableViewCellAccessoryCheckmark) {
        // If it's not on, select it
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
        theCell.textLabel.textColor = UIColorFromRGB(0x1986fb);
    }
    else {
        // If it's on, remove it
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setTextColor:[UIColor blackColor]];
    }
}


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
