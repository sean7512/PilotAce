//
//  SKEmitterNodeFactory.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/19/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNodeFactory : NSObject

+ (SKEmitterNode *)createForParticleFilename:(NSString *)resourceName;

@end
