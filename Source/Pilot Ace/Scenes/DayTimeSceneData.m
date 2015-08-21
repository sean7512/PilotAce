//
//  DayTimeSceneData.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/21/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "DayTimeSceneData.h"

@implementation DayTimeSceneData

static NSString *const DISTANT_BACKGROUND_TEXTURE = @"Distant";
static NSString *const FOREGROUND_TEXTURE = @"ground";

- (id)init {
    self = [super init];
    if(self) {
        _backgroundColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
        
        _distantBackgroundTexture = [SKTexture textureWithImageNamed:DISTANT_BACKGROUND_TEXTURE];

        _foregroundTexture = [SKTexture textureWithImageNamed:FOREGROUND_TEXTURE];
        _foregroundTexture.filteringMode = SKTextureFilteringLinear;
    }

    return self;
}

+ (DayTimeSceneData *)sharedInstance {
    static DayTimeSceneData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DayTimeSceneData alloc] init];
    });
    return sharedInstance;
}

@end
