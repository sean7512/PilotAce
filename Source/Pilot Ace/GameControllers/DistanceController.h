//
//  ScoreController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface DistanceController : NSObject

@property (assign, readonly, nonatomic) int64_t distanceTraveledKm;

- (void)update:(NSTimeInterval)elapsed withSpeedMultiplier:(CGFloat)speed;

+ (NSTimeInterval)determineStationaryObjectDurationFromPositionX:(CGFloat)xPos withWidth:(CGFloat)width;
+ (NSTimeInterval)determineStationaryObjectDuration:(SKSpriteNode *)node;
+ (NSTimeInterval)determineMovingObjectDuration:(SKSpriteNode *)node withAdditionalSpeed:(CGFloat)percentOfPlaneSpeed;

@end
