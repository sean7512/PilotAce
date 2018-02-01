//
//  MainLevelScene.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PauseGameController.h"

@class Airplane;
@class DifficultyLevel;

@interface MainLevelScene : SKScene <PauseGameController>

+ (id)createWithSize:(CGSize)size withSideInsets:(CGFloat)inset forPlane: (Airplane *)plane forDiffucultyLebel: (DifficultyLevel *)difficulty;

@end
