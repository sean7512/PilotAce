//
//  TimeOfDaySceneData.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/21/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol TimeOfDaySceneData <NSObject>

@required
@property (strong, readonly, nonatomic) SKColor *backgroundColor;

@required
@property (strong, readonly, nonatomic) SKTexture *distantBackgroundTexture;

@required
@property (strong, readonly, nonatomic) SKTexture *foregroundTexture;

@end
