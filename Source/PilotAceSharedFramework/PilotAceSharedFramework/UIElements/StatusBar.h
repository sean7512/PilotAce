//
//  StatusBar.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PauseGameController.h"

extern CGFloat const STATUS_BAR_HEIGHT;

@interface StatusBar : SKNode

+ (id)createWithPauseSceneController:(SKScene<PauseGameController> *)scene;
- (void)updateWithFuelPercent:(float)fuelPercent withDistance:(int64_t)distanceKm;

@end
