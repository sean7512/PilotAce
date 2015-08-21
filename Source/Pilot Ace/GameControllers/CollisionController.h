//
//  CollisionController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameOverListener.h"

typedef enum : uint8_t {
    SpriteColliderTypePlane       = 1,
    SpriteColliderTypeBullet      = 2,
    SpriteColliderTypeMissile     = 4,
    SpriteColliderTypeMountain    = 8,
    // 16 was tree
    SpriteColliderTypeLightning   = 32,
    SpriteColliderTypeFuel        = 64
} SpriteColliderType;

@class AirplaneController;

@interface CollisionController : NSObject <SKPhysicsContactDelegate>

- (id)initWithScene:(SKScene<GameOverListener> *)scene withPlaneController:(AirplaneController *)planeController;

@end
