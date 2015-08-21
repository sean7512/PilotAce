//
//  AchievementController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/12/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class DifficultyLevel;

extern float const HERCULES_PLANE_SCORE;
extern float const STEALTH_PLANE_SCORE;
extern float const RAPTOR_PLANE_SCORE;
extern float const BLACKBIRD_PLANE_SCORE;
extern float const STRATOTANKER_PLANE_SCORE;

extern float const CHINOOK_UNLOCK_SCORE;
extern float const OSPREY_UNLOCK_SCORE;

@interface AchievementController : NSObject

+ (void)applyInGameAchievementsForDistanceTraveledKm:(int64_t)score forScene:(SKScene *)scene forDifficulty:(DifficultyLevel *)difficulty;
+ (void)applyEndGameAchievementsForDistanceTraveledKm:(int64_t)score forDifficulty:(DifficultyLevel *)difficulty;

// plane difficulty
+ (BOOL)didAchieveHercules:(int64_t)planeDifficultyLevelScore;
+ (BOOL)didAchieveStealthFighter:(int64_t)planeDifficultyLevelScore;
+ (BOOL)didAchieveRaptor:(int64_t)planeDifficultyLevelScore;
+ (BOOL)didAchieveBlackbird:(int64_t)planeDifficultyLevelScore;
+ (BOOL)didAchieveStratotanker:(int64_t)planeDifficultyLevelScore;

/*!
 * Determines if the user did unlock the helicopters based on their plane score.
 * @param planeDifficultyLevelScore The score of the PLANE level (NOT the helicopter level).
 * @return YES if the user has unlocked the helicopters; NO otherwise
 */
+ (BOOL)didUnlockHelicopters:(int64_t)planeDifficultyLevelScore;
+ (BOOL)didAchieveChinook:(int64_t)heliDifficultyLevelScore;
+ (BOOL)didAchieveOsprey:(int64_t)heliDifficultyLevelScore;

@end
