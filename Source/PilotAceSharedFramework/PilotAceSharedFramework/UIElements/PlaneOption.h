//
//  PlaneOption.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ShapedButton_Protected.h"
#import "ButtonSupport.h"

@class Airplane;

@interface PlaneOption : ShapedButton

+ (id)createForPlane:(Airplane *)plane withTouchDownCallback:(TouchUpInsideCallback)callback withNotUnlockedMessage:(NSString *)msg withAlwaysTouchDownCallback:(TouchUpInsideCallback)alwaysCallback;
- (void)hideOption;

@end
