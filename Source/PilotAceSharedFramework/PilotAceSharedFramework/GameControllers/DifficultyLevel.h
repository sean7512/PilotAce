//
//  DifficultyController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/1/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DifficultyLevel : NSObject

@property (strong, nonatomic, readonly) NSString *displayName;
@property (assign, nonatomic, readonly) int numBulletsToDestroyMissile;
@property (assign, nonatomic, readonly) NSTimeInterval secondsBetweenMissiles;
@property (assign, nonatomic, readonly) NSTimeInterval secondsBetweenObstacles;
@property (strong, nonatomic, readonly) NSArray *planeAchievementInfoList;
@property (assign, nonatomic, readonly) BOOL hasInGameAchievements;

+ (DifficultyLevel *)planeDifficulty;
+ (DifficultyLevel *)helicopterDifficulty;
+ (NSArray *)getAllDifficultyLevels;

- (NSString *)keyWithSuffix:(NSString *)key;

@end
