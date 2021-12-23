//
//  Airplane.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Airplane.h"
#import "CollisionController.h"

@interface Airplane()

@property (assign, nonatomic) double fuel;
@property (assign, nonatomic) BOOL didNoseDive;

@end

@implementation Airplane

static double const MAX_FUEL = 100;
static double const MIN_FUEL = 0;
static double const FUEL_LOSS_PER_SECIND = 5;
static double const FUEL_GAINED_COLLECTION = 16;
static NSTimeInterval const NOSEDIVE_FROM_TOP_SECONDS = 0.8;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        _fuel = MAX_FUEL;
        _didNoseDive = NO;
    }
    return self;
}

- (void)setupPhysicsBodyForPath:(CGPathRef)path {
    self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];

    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.dynamic = YES;
    self.physicsBody.categoryBitMask = SpriteColliderTypePlane;
    self.physicsBody.contactTestBitMask = SpriteColliderTypeMissile | SpriteColliderTypeMountain | SpriteColliderTypeLightning | SpriteColliderTypeFuel;
    self.physicsBody.collisionBitMask = 0;
}

- (BOOL)calculateFuelLoss:(NSTimeInterval)elapsedTime withSpeedMultiplier:(CGFloat)speed {
    if(self.fuel > MIN_FUEL) {
        self.fuel -= (elapsedTime * [self getFuelLossPerSecond]) * speed;
    }

    if(self.fuel < MIN_FUEL) {
        // don't allow fuel to go below empty
        self.fuel = MIN_FUEL;
    }

    return [self isFuelTankEmpty];
}

- (double)getFuelLossPerSecond {
    return FUEL_LOSS_PER_SECIND;
}

- (float)getFuelTankFillPercent {
    return ((self.fuel-MIN_FUEL)/(MAX_FUEL - MIN_FUEL)) * 100;
}

- (BOOL)isFuelTankEmpty {
    return self.fuel <= MIN_FUEL;
}

- (CGFloat)getNodeDiveAngleRadians {
    return -M_PI/3.0;
}

- (void)noseDive {
    if(!self.didNoseDive) {
        self.didNoseDive = YES;
        self.userInteractionEnabled = NO;

        // determine how far we need to fall to determine the crash duration
        CGFloat sceneHeight = self.scene.size.height - self.topInset;
        CGFloat heightToFall = self.position.y;
        CGFloat percentofTotalToFall = heightToFall / sceneHeight;
        CGFloat fallDuration = percentofTotalToFall / NOSEDIVE_FROM_TOP_SECONDS;

        [self runAction:[SKAction rotateToAngle:[self getNodeDiveAngleRadians] duration:0.3]];
        [self runAction:[SKAction moveToY:0 duration:fallDuration]];
    }
}

- (void)receivedFuel {
    self.fuel += [self getFuelGainPerCollection];
    if(self.fuel > MAX_FUEL) {
        self.fuel = MAX_FUEL;
    }
}

- (double)getFuelGainPerCollection {
    return FUEL_GAINED_COLLECTION;
}

- (CGPoint)getBulletPosition {
    return CGPointMake(self.position.x + self.size.width/2, self.position.y);
}

- (CGFloat)getRelativeBulletHeightFromTop {
    return self.size.height/2;
}

- (CGFloat)getRelativeBulletHeightFromBottom {
    return self.size.height/2;
}

@end
