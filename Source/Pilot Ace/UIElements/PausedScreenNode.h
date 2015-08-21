//
//  PausedScreenNode.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/27/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PauseGameController.h"

@interface PausedScreenNode : SKNode

+ (id)createForScreenWithSize:(CGSize)size withPauseGameController:(NSObject<PauseGameController> *)pauseGameController;

@end
