//
//  MissileController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "MissileController.h"
#import "Missile.h"
#import "StatusBar.h"
#import "DistanceController.h"
#import "Fuel.h"
#import "DifficultyLevel.h"

@interface MissileController()

@property (weak, nonatomic) SKScene<SceneInsetProvider> *scene;
@property (assign, nonatomic) NSTimeInterval timeSinceLastMissile;
@property (assign, readonly, nonatomic) NSTimeInterval secondsBetweenMissiles;
@property (assign, readonly, nonatomic) int numBulletsToDestroyMissile;

@end

@implementation MissileController

static NSTimeInterval const DEF_MISSILE_ADDED_TIME = 0;
static double const MISSILE_MULTIPLIER_PLANE_SPEED = 1.9;

- (id)initWithScene:(SKScene<SceneInsetProvider> *)scene forDifficulty:(DifficultyLevel *)difficulty {
    self = [super init];
    if(self) {
        _scene = scene;
        _timeSinceLastMissile = DEF_MISSILE_ADDED_TIME;
        _secondsBetweenMissiles = difficulty.secondsBetweenMissiles;
        _numBulletsToDestroyMissile = difficulty.numBulletsToDestroyMissile;
    }

    return self;
}

- (void)update:(NSTimeInterval)elapsedTime withSpeedMultiplier:(CGFloat)speed {
    self.timeSinceLastMissile += elapsedTime;

    // if 1 second or more has passed, add a missile
    if(self.timeSinceLastMissile >= (self.secondsBetweenMissiles / speed)) {
        // Add a missile
        [self addMissile];
        self.timeSinceLastMissile = DEF_MISSILE_ADDED_TIME;
    }
}

- (void)addMissile {
    // Create missile
    Missile *missile = [Missile createWithNumBulletsToDestroy:self.numBulletsToDestroyMissile];

    // missiles should always be above fuel
    missile.zPosition = FUEL_Z_INDEX + 1;

    // Determine where to spawn the missile along the Y axis
    int minY = [self.scene getPlaneBulletMinHeight];
    if(minY < [self.scene getBottomInset] + missile.size.height/2 + 5) {
        minY = [self.scene getBottomInset] + missile.size.height/2 +5;
    }
    int maxY = [self.scene getPlaneBulletMaxHeight];
    int rangeY = maxY - minY;
    int actualY = arc4random_uniform(rangeY) + minY;

    // Create the missile slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    missile.position = CGPointMake(self.scene.frame.size.width + missile.size.width*3, actualY);
    [self.scene addChild:missile];

    // Create the actions
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-missile.size.width/2, actualY) duration:[DistanceController determineMovingObjectDuration:missile withAdditionalSpeed:MISSILE_MULTIPLIER_PLANE_SPEED]];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [missile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

@end
