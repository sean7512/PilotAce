//
//  Airplane.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "DraggableSpriteNode.h"

@interface Airplane : DraggableSpriteNode

@property (assign, readonly, nonatomic) BOOL didNoseDive;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection;
- (void)setupPhysicsBodyForPath:(CGPathRef)path;

- (BOOL)calculateFuelLoss:(NSTimeInterval)elapsedTime withSpeedMultiplier:(CGFloat)speed;
- (float)getFuelTankFillPercent;
- (void)noseDive;
- (void)receivedFuel;
- (CGPoint)getBulletPosition;
- (CGFloat)getRelativeBulletHeightFromTop;
- (CGFloat)getRelativeBulletHeightFromBottom;

@end
