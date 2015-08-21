//
//  GameOverScene.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class DifficultyLevel;

@interface GameOverScene : SKScene

+ (id)createWithSize:(CGSize)size withDistanceTraveled:(int64_t)distanceKm forDifficulty:(DifficultyLevel *)difficulty;

@end
