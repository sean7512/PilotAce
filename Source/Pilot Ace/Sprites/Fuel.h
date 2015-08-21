//
//  FuelSprite.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

extern CGFloat const FUEL_Z_INDEX;

@interface Fuel : SKSpriteNode

+ (id)createAtPosition:(CGPoint)position;

@end
