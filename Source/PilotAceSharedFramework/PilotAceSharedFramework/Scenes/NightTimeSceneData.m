//
//  NightTimeSceneData.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/21/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "NightTimeSceneData.h"

@implementation NightTimeSceneData

static NSString *const DISTANT_BACKGROUND_TEXTURE = @"Distant";
static NSString *const FOREGROUND_TEXTURE = @"ground";

- (id)init {
    self = [super init];
    if(self) {
        _backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

        UIImage *distantGroundImage = [UIImage imageNamed:DISTANT_BACKGROUND_TEXTURE inBundle:[NSBundle bundleForClass:[NightTimeSceneData class]] compatibleWithTraitCollection:nil];
        _distantBackgroundTexture = [SKTexture textureWithImage:distantGroundImage];

        UIImage *foregroundImage = [UIImage imageNamed:FOREGROUND_TEXTURE inBundle:[NSBundle bundleForClass:[NightTimeSceneData class]] compatibleWithTraitCollection:nil];
        _foregroundTexture = [SKTexture textureWithImage:foregroundImage];
        _foregroundTexture.filteringMode = SKTextureFilteringLinear;
    }

    return self;
}

+ (NightTimeSceneData *)sharedInstance {
    static NightTimeSceneData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NightTimeSceneData alloc] init];
    });
    return sharedInstance;
}

@end
