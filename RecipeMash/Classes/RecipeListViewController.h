//
//  RecipeListViewController.h
//  RecipeMash
//
//  Created by Sidwyn Koh on 10/11/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeListViewController : UITableViewController {
    UIImage *blankImage;
}

@property (nonatomic, retain) NSArray *ingredientsList;
@property (nonatomic, retain) NSArray *recipeList;

@end
