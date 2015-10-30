//
//  ObstacleNode.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/25/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SceneInsetProvider.h"

@protocol ObstacleNode <NSObject>

- (CGFloat)getPreferredYPositionForScene:(SKScene<SceneInsetProvider> *)scene;
+ (id)create;

@end
