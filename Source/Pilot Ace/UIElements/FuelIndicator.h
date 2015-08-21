//
//  FuelIndicator.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FuelIndicator : SKNode

+ (id)create;
- (void)setFuelIndicator:(double)percentFull;

@end
