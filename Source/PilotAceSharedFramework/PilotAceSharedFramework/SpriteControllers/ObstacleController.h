//
//  ObstacleController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/25/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SceneInsetProvider.h"

@class DifficultyLevel;

@interface ObstacleController : NSObject

- (id)initWithScene:(SKScene<SceneInsetProvider> *)scene forDifficulty:(DifficultyLevel *)difficulty;
- (void)update:(NSTimeInterval)elapsed withSpeedMultiplier:(CGFloat)speed;

@end
