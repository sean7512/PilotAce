//
//  FuelSprite.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Fuel.h"
#import "CollisionController.h"
#import "PilotAceAppDelegate.h"

CGFloat const FUEL_Z_INDEX = 5;

@implementation Fuel

static NSString *const FUEL_IMG = @"Fuel";

static SKTexture *_texture;

- (id)initWithTexture:(SKTexture *)texture {
    self = [super initWithTexture:texture];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createAtPosition:(CGPoint)position {
    static dispatch_once_t loadFuelTextureOnce;
    dispatch_once(&loadFuelTextureOnce, ^{
        _texture = [SKTexture textureWithImageNamed:FUEL_IMG];
    });

    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    Fuel *fuel = [[Fuel alloc] initWithTexture:_texture];
    fuel.zPosition = FUEL_Z_INDEX;
    fuel.position = position;

    fuel.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:fuel.size];
    fuel.physicsBody.dynamic = YES;
    fuel.physicsBody.categoryBitMask = SpriteColliderTypeFuel;
    // plane listens for fuel-collisio
    fuel.physicsBody.collisionBitMask = 0;

    [fuel setScale:nodeScale];

    return fuel;
}

@end
