//
//  TBPreviewImageCollectionViewCell.m
//  TagByLauncher
//
//  Created by Alek on 14.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBPreviewImageCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <TagBySDK/TagBySDK.h>

@interface TBPreviewImageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CALayer *originalMask;
@property (nonatomic, assign) TBSocialNetwork socialNetwork;

@end

@implementation TBPreviewImageCollectionViewCell

- (void)showImage:(NSURL *)imageUrl backgroundColor:(UIColor *)backgroundColor
{
    [self showImage:imageUrl backgroundColor:backgroundColor socialNetwork:0];
}

- (void)showImage:(NSURL *)imageUrl backgroundColor:(UIColor *)backgroundColor socialNetwork:(TBSocialNetwork)socialNetwork
{
    self.socialNetwork = socialNetwork;
	self.backgroundView.backgroundColor = backgroundColor;
	self.originalMask = self.placeholderImageView.layer.mask;
	self.imageView.hidden = YES;
	self.placeholderImageView.hidden = NO;
	[self setProgress:0.];
	
	__weak __typeof(self) weakSelf = self;
	[self.imageView sd_setImageWithURL:imageUrl placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize) {
		__strong __typeof(weakSelf) strongSelf = weakSelf;
		if(!strongSelf) {
			return;
		}
		CGFloat percent = expectedSize > 0 ? (CGFloat)receivedSize / expectedSize : 0.;
		[strongSelf setProgress:percent];
	} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		__strong __typeof(weakSelf) strongSelf = weakSelf;
		if(!strongSelf) {
			return;
		}
		
		strongSelf.placeholderImageView.hidden = YES;
		strongSelf.placeholderImageView.layer.mask = strongSelf.originalMask;
        
        if(strongSelf.socialNetwork > 0) {
            UIImage *socialNetworkImage;
            if(strongSelf.socialNetwork == TBSocialNetworkFacebook) {
                socialNetworkImage = [UIImage imageNamed:@"icn_facebook-xs"];
            }
            else if(strongSelf.socialNetwork == TBSocialNetworkTwitter) {
                socialNetworkImage = [UIImage imageNamed:@"icn_twitter-xs"];
            }
            else if(strongSelf.socialNetwork == TBSocialNetworkEmail) {
                socialNetworkImage = [UIImage imageNamed:@"icn_email-xs"];
            }
            
            CGRect frame = CGRectMake(strongSelf.imageView.frame.size.width - 12. - 4., 4., 12. ,12.);
            strongSelf.imageView.image = [image mergeInRect:strongSelf.imageView.frame withImage:socialNetworkImage imageRect:frame];
        }
        
        strongSelf.imageView.hidden = NO;
	}];
}

// Drawing the red progress circle
- (void)setProgress:(CGFloat)percent
{
	CGFloat endAngle = 3 * M_PI_2 + percent * 2 * M_PI;
	if(endAngle >= M_PI * 2) {
		endAngle -= M_PI * 2;
	}
	
	CGFloat radius = MIN(CGRectGetWidth(self.imageView.bounds), CGRectGetHeight(self.imageView.bounds));
	CGPoint center = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));
	
	CAShapeLayer *mask = [[CAShapeLayer alloc] init];
	mask.frame = self.placeholderImageView.layer.bounds;

	UIBezierPath *maskPath = [UIBezierPath bezierPath];
	[maskPath moveToPoint:center];
	[maskPath addArcWithCenter:center radius:radius startAngle:(3 * M_PI_2) endAngle:endAngle clockwise:YES];
	[maskPath closePath];
	
	mask.path = maskPath.CGPath;
	[mask setFillRule:kCAFillRuleEvenOdd];
	mask.fillColor = [[UIColor blackColor] CGColor];
	self.placeholderImageView.layer.mask = mask;
}

@end
