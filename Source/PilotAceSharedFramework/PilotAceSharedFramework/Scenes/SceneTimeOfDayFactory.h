//
//  SceneTimeOfDayFactory.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/21/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeOfDaySceneData.h"

@interface SceneTimeOfDayFactory : NSObject

+ (NSObject<TimeOfDaySceneData> *)setUpSceneWithRandomTimeOfDayData:(SKScene *)scene withMovement:(BOOL)isMoving;
+ (void)setUpScene:(SKScene *)scene forTimeOfDayData:(NSObject<TimeOfDaySceneData> *)sceneData withMovement:(BOOL)isMoving;

@end
