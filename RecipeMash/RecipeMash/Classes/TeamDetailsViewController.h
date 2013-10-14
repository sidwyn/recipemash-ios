//
//  TeamDetailsViewController.h
//  React
//
//  Created by Sidwyn Koh on 7/28/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamDetailsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

- (IBAction)tapDoneButton:(id)sender;

@property IBOutlet id delegate;
@end

@protocol TeamDetailsViewControllerDelegate

- (void)didTapDoneButton;

@end