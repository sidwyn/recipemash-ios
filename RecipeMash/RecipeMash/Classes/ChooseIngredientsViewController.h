//
//  ChooseIngredientsViewController.h
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/11/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseIngredientsViewController : UITableViewController {
    NSDictionary *epicGroceryList;
}

@property (nonatomic, retain) NSArray *listOfIngredients;
@property (nonatomic, assign) UIViewController *parentController;

@end
