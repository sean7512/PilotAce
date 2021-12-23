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
static NSString *const PARTICLE_TEXTURE_NAME = @"spark";

+ (SKEmitterNode *)createForParticleFilename:(NSString *)resourceName {
    // bundle for resources
    NSBundle *bundle = [NSBundle bundleForClass:[SKEmitterNodeFactory class]];

    // emitter node
    NSString *emitterPath = [bundle pathForResource:resourceName ofType:PARTICLE_FILE_TYPE];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchivedObjectOfClass:[SKEmitterNode class] fromData:[[NSData alloc] initWithContentsOfFile:emitterPath] error:nil];

    // texture for emitter node
    UIImage *particleTexture = [UIImage imageNamed:PARTICLE_TEXTURE_NAME inBundle:bundle compatibleWithTraitCollection:nil];
    emitterNode.particleTexture = [SKTexture textureWithImage:particleTexture];

    return emitterNode;
}

@end
