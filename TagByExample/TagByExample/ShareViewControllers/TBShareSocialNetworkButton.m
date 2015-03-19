//
//  TBPhotoboothShareButton.m
//  TagByLauncher
//
//  Created by Alek on 23.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBShareSocialNetworkButton.h"

@implementation TBShareSocialNetworkButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
