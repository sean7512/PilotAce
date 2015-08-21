//
//  DayTimeSceneData.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/21/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TimeOfDaySceneData.h"

@interface DayTimeSceneData : NSObject <TimeOfDaySceneData>

+ (DayTimeSceneData *)sharedInstance;

@property (strong, readonly, nonatomic) SKColor *backgroundColor;
@property (strong, readonly, nonatomic) SKTexture *distantBackgroundTexture;
@property (strong, readonly, nonatomic) SKTexture *foregroundTexture;

@end
