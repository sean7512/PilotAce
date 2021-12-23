//
//  GameCenterController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <GameKit/GameKit.h>

@class DifficultyLevel;

extern NSString *const GAME_CENTER_LOCAL_PLAYER_AUTHENTICATED;
extern NSString *const GAME_CENTER_LOCAL_PLAYER_ID;
extern NSString *const DISPLAY_LEADERBOARD_REQUEST;

@interface GameCenterController : NSObject <GKGameCenterControllerDelegate>

+ (GameCenterController *)sharedInstance;

// difficulty-specific achievements
- (void)reportNewTotalScore:(int64_t)newScore forDifficulty:(DifficultyLevel *)difficulty;
- (void)machTwoAchievementEarnedForDifficulty:(DifficultyLevel *)difficulty;
- (void)machThreeAchievementEarnedForDifficulty:(DifficultyLevel *)difficulty;

// non difficulty-specific achievements
- (void)herculesAchievementEarned;
- (void)stealthFighterAchievementEarned;
- (void)raptorAchievementEarned;
- (void)blackbirdAchievementEarned;
- (void)stratotankerAchievementEarned;
- (void)helicopterLevelUnlockEarned;
- (void)chinookAchievementEarned;
- (void)ospreyAchievementEarned;

// misc
- (void)displayLeaderBoardWithViewController:(UIViewController *)viewController;
- (void)cleanup;

@end
