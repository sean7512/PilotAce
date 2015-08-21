//
//  Bullet.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Bullet.h"
#import "PilotAceAppDelegate.h"
#import "CollisionController.h"

@implementation Bullet

static NSString *const BULLET_FONT = @"Arial";

- (id)initWithFontNamed:(NSString *)fontName {
    self = [super initWithFontNamed:fontName];
    if(self) {
        // nothing to initialize
    }

    return self;
}

+ (id)create {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    Bullet *bullet = [[Bullet alloc] initWithFontNamed:BULLET_FONT];
    bullet.fontColor = [SKColor whiteColor];
    bullet.text = @"-";
    bullet.fontSize = 20*nodeScale;

    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.frame.size center:CGPointMake(bullet.position.x, bullet.position.y+(6*nodeScale))];
    bullet.physicsBody.dynamic = YES;
    bullet.physicsBody.usesPreciseCollisionDetection = YES;
    bullet.physicsBody.categoryBitMask = SpriteColliderTypeBullet;
    // the missile checks for the bullet contact
    bullet.physicsBody.contactTestBitMask = SpriteColliderTypeMountain;
    bullet.physicsBody.collisionBitMask = 0;

    return bullet;
}

@end
