//
//  UICollectionViewAddFriendCellCollectionViewCell.m
//  TagByLauncher
//
//  Created by Alek on 21.11.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBUICollectionViewAddFriendCellCollectionViewCell.h"

@interface TBUICollectionViewAddFriendCellCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TBUICollectionViewAddFriendCellCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame])) {
        self.layer.borderWidth = 2.;
        self.layer.borderColor = [UIColor whiteColor].CGColor;

        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10., 10., 60., 60.)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.image = [UIImage imageNamed:@"icn_add_friend_iPhone.png"];
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)setImage:(BOOL)pressed
{
    self.imageView.image = pressed ? [UIImage imageNamed:@"icn_add_friend_iPhone-pressed.png"] : [UIImage imageNamed:@"icn_add_friend_iPhone.png"];
    [self setNeedsDisplay];
}

@end
