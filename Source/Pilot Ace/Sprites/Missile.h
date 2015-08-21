//
//  Missile.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Missile : SKSpriteNode

+ (id)createWithNumBulletsToDestroy: (int)numBulletsToDestroy;
- (BOOL)hitByBullet;

@end
