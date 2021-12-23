//
//  BulletController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BulletController : NSObject

- (id)initWithScene:(SKScene *)scene;
- (void)shootBulletAt:(CGPoint)position;

@end
