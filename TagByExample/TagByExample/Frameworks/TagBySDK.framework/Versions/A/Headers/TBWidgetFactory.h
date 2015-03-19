//
//  TBWidgetFactory.h
//  TagByLauncher
//
//  Created by Alek on 08.10.2014.
//  Copyright (c) 2014 TagBy. All rights reserved.
//

@import Foundation;

@class TBWidget;

@interface TBWidgetFactory : NSObject

+ (TBWidget *)parseWidgetFromJSON:(NSDictionary *)dictionary;

@end
