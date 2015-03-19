//
//  TBPreviewImageCollectionViewCell.h
//  TagByLauncher
//
//  Created by Alek on 14.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import UIKit;
#import <TagBySDK/TagBySDK.h>

// This collection view cell is used whenever we load a remote image in offer previews, share views
@interface TBPreviewImageCollectionViewCell : UICollectionViewCell

- (void)showImage:(NSURL *)imageUrl backgroundColor:(UIColor *)backgroundColor;
// We will merge a small social network icon on the image (used on the FinalShare view controller
- (void)showImage:(NSURL *)imageUrl backgroundColor:(UIColor *)backgroundColor socialNetwork:(TBSocialNetwork)socialNetwork;

@end
