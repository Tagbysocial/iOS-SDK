//
//  TBBarcodePreviewController.h
//  TagByLauncher
//
//  Created by Alek on 18.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

#import "TBWidgetController.h"
#import "TBCameraPreviewController.h"

@protocol TBBarcodePreviewDelegate<NSObject>

- (void)didReadBarcode:(NSString *)barcode;

@end

@class TBBarcodePreview;

@interface TBBarcodePreviewController : TBWidgetController

- (instancetype)initWithSuperview:(UIView *)superview tbBarcodePreview:(TBBarcodePreview *)tbBarcodePreview;

@property (nonatomic, weak) id<TBBarcodePreviewDelegate> delegate;
@property (nonatomic, assign) TBCameraSide cameraSide;

- (void)startReadingBarcodes;
- (void)stopReadingBarcodes;

@end
