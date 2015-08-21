//
//  AirplaneController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameOverListener.h"
#import "SceneInsetProvider.h"

@class Airplane;

@interface AirplaneController : NSObject

- (id)initWithScene:(SKScene<GameOverListener, SceneInsetProvider> *)scene withPlane:(Airplane *)plane withPlaneXPos:(CGFloat)xPos;
- (void)update:(NSTimeInterval)elapsedTime withSpeedMultiplier:(CGFloat)speed;
- (CGPoint)getPlanePosition;
- (CGPoint)getPlaneBulletPosition;
- (CGFloat)getPlaneFuelTankPercentFull;
- (void)receivedFuel;
- (CGFloat)getPlaneBulletMaxHeight;
- (CGFloat)getPlaneBulletMinHeight;
- (void)movePlaneToY:(CGFloat)yPos;
- (BOOL)didPlaneNosedive;

@end
