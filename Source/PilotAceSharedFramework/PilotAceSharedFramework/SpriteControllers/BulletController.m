//
//  BulletController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "BulletController.h"
#import "Bullet.h"

@interface BulletController()

@property (weak, nonatomic) SKScene *scene;

@end

@implementation BulletController

static NSTimeInterval const BULLET_SPEED_SECONDS = 1;

- (id)initWithScene:(SKScene *)scene {
    self = [super init];
    if(self) {
        _scene = scene;

        // preload a bullet node so the first bullet doesn't cause stutter
        [Bullet create];
    }

    return self;
}

- (void)shootBulletAt:(CGPoint)position {
    // Create and position bullet
    Bullet *bullet = [Bullet create];
    bullet.position = position;
    [self.scene addChild:bullet];

    // Create the actions
    SKAction *actionMove = [SKAction moveTo:CGPointMake(bullet.scene.frame.size.width + bullet.frame.size.width/2, bullet.position.y) duration:BULLET_SPEED_SECONDS];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [bullet runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

@end
