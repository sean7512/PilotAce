//
//  SKEmitterNodeFactory.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/19/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "SKEmitterNodeFactory.h"

@implementation SKEmitterNodeFactory

static NSString *const PARTICLE_FILE_TYPE = @"sks";

+ (SKEmitterNode *)createForParticleFilename:(NSString *)resourceName {
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:PARTICLE_FILE_TYPE];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
}

@end
