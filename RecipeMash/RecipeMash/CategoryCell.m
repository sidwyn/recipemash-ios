//
//  CategoryCell.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/2/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.categoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 320, 24)];
        self.categoryTitle.tag = 111;
        self.categoryTitle.font = [UIFont fontWithName:@"Open Sans" size:18];
        self.categoryTitle.textColor = [UIColor blackColor];
        self.categoryTitle.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.categoryTitle];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
