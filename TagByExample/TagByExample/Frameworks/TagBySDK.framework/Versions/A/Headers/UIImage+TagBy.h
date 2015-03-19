//
//  UIImage+TagBy.h
//  TagBySDK
//
//  Created by Stephane JAIS on 8/25/12.
//  Copyright (c) 2012 Cantina Software. All rights reserved.
//

@import UIKit;

@interface UIImage (TagBy)

- (UIImage *)orientationFreeFlipped:(BOOL)flipped;
- (UIImage *)tintedWithColor:(UIColor *)color;
- (UIImage *)resizeToFit:(CGSize)size;
- (UIImage *)mergeInRect:(CGRect)rect withImage:(UIImage *)image imageRect:(CGRect)imageRect;
- (UIImage *)mergeInRect:(CGRect)rect withImageToAspectFill:(UIImage *)image imageRect:(CGRect)imageRect;

@end
