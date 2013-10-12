//
//  FridgeViewController.h
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/12/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FridgeViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *listOfMyIngredients;
@property (nonatomic, retain) NSString *userId;
@end
