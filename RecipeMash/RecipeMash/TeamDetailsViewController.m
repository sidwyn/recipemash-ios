//
//  TeamDetailsViewController.m
//  React
//
//  Created by Sidwyn Koh on 7/28/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "TeamDetailsViewController.h"
#import "TeamDetailCell.h"

@interface TeamDetailsViewController ()

@end

@implementation TeamDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)tapDoneButton:(id)sender {
    if (self.delegate) {
        NSLog(@"Yes delegate");
        [self.delegate didTapDoneButton];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Methods


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TeamDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TeamDetailCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    NSString *imageName = [NSString stringWithFormat:@"SampleFace%i.png", indexPath.row+1];
    cell.cellImage.image = [UIImage imageNamed:imageName];
    cell.cellImage.layer.cornerRadius = 37.5;
    cell.cellImage.clipsToBounds = YES;
    
    cell.cellLabel.numberOfLines = 0;
    NSString *name;
    switch (indexPath.row) {
        case 0:
            name = @"Dave";
            break;
        case 1:
            name = @"Michael";
            break;
        case 2:
            name = @"Joan";
            break;
        case 3:
            name = @"Gabriella";
            break;
        case 4:
            name = @"Thomas";
            break;
        default:
            break;
    }
    cell.cellLabel.text = name;
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 108);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}

@end
