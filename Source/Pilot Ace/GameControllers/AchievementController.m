//
//  AchievementController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/12/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "AchievementController.h"
#import "DistanceUtils.h"
#import "GameCenterController.h"
#import "DifficultyLevel.h"

@implementation AchievementController

float const HERCULES_PLANE_SCORE = 10; // 10 km
float const STEALTH_PLANE_SCORE = 20; // 20 km
static float const MACH_TWO_SCORE = 30; // 30 km
float const RAPTOR_PLANE_SCORE = 40; // 40 km
float const BLACKBIRD_PLANE_SCORE = 50; // 50 km
float const STRATOTANKER_PLANE_SCORE = 60; // 60 km
static float const MACH_THREE_SCORE = 100; // 100 km

float const CHINOOK_UNLOCK_SCORE = 10; // 10 km
float const OSPREY_UNLOCK_SCORE = 20; // 20 km

static float const GRADUAL_SPEED_STEP = 0.0167;
static float const MACH_ONE_MULTIPLIER = 1.0;
static float const MACH_TWO_MULTIPLIER = 2.0;
static float const MACH_THREE_MULTIPLIER = 3.0;

+ (void)applyInGameAchievementsForDistanceTraveledKm:(int64_t)score forScene:(SKScene *)scene forDifficulty:(DifficultyLevel *)difficulty {
    // ALL in-game achievements are difficulty-specific

    if(!difficulty.hasInGameAchievements) {
        // nothing to apply
        return;
    }

    float decimalScore = [DistanceUtils getFloatScore:score];

    // mach 2 and mach 3 are the only in-game achievements
    if([AchievementController didAchieveMachThree:decimalScore]) {
        if(scene.speed != MACH_THREE_MULTIPLIER) {
            if(scene.speed == MACH_TWO_MULTIPLIER) {
                // only report to gamce center the first time they hit mach 3
                [[GameCenterController sharedInstance] machThreeAchievementEarnedForDifficulty:difficulty];
            }

            if(MACH_THREE_MULTIPLIER - scene.speed > GRADUAL_SPEED_STEP) {
                scene.speed += GRADUAL_SPEED_STEP; // gradually go to mach 3
            } else {
                scene.speed = MACH_THREE_MULTIPLIER;
            }
        }
    } else if([AchievementController didAchieveMachTwo:decimalScore]) {
        if(scene.speed != MACH_TWO_MULTIPLIER) {
            if(scene.speed == MACH_ONE_MULTIPLIER) {
                // only report to gamce center the first time they hit mach 2
                [[GameCenterController sharedInstance] machTwoAchievementEarnedForDifficulty:difficulty];
            }

            if(MACH_TWO_MULTIPLIER - scene.speed > GRADUAL_SPEED_STEP) {
                scene.speed += GRADUAL_SPEED_STEP; // gradually go to mach 2
            } else {
                scene.speed = MACH_TWO_MULTIPLIER;
            }
        }
    }
}

+ (void)applyEndGameAchievementsForDistanceTraveledKm:(int64_t)score forDifficulty:(DifficultyLevel *)difficulty {
    // unlockable items are the end-game achievements

#warning this ever-expanding if statement is ugly, yuck!
    if(difficulty == [DifficultyLevel planeDifficulty]) {
        // apply plane end game achievements
        if([AchievementController didAchieveHercules:score]) {
            // once the user has unlocked the hercules, open the helicopters as well
            [[GameCenterController sharedInstance] herculesAchievementEarned];
            [[GameCenterController sharedInstance] helicopterLevelUnlockEarned];
        }

        if([AchievementController didAchieveStealthFighter:score]) {
            [[GameCenterController sharedInstance] stealthFighterAchievementEarned];
        }

        if([AchievementController didAchieveRaptor:score]) {
            [[GameCenterController sharedInstance] raptorAchievementEarned];
        }

        if([AchievementController didAchieveBlackbird:score]) {
            [[GameCenterController sharedInstance] blackbirdAchievementEarned];
        }

        if([AchievementController didAchieveStratotanker:score]) {
            [[GameCenterController sharedInstance] stratotankerAchievementEarned];
        }
    } else if(difficulty == [DifficultyLevel helicopterDifficulty]) {
        // apply helicopter end game achievements
        if([AchievementController didAchieveChinook:score]) {
            [[GameCenterController sharedInstance] chinookAchievementEarned];
        }

        if([AchievementController didAchieveOsprey:score]) {
            [[GameCenterController sharedInstance] ospreyAchievementEarned];
        }
    } else {
        NSLog(@"Unknown difficulty level: %@", difficulty.displayName);
    }
}

#pragma mark in game achievements
+ (BOOL)didAchieveMachTwo:(float)score {
    return score >= MACH_TWO_SCORE;
}

+ (BOOL)didAchieveMachThree:(float)score {
    return score >= MACH_THREE_SCORE;
}

#pragma mark plane unlock achievements
+ (BOOL)didAchieveHercules:(int64_t)planeDifficultyLevelScore {
    return planeDifficultyLevelScore >= [DistanceUtils getIntScore:HERCULES_PLANE_SCORE];
}

+ (BOOL)didAchieveStealthFighter:(int64_t)planeDifficultyLevelScore {
    return planeDifficultyLevelScore >= [DistanceUtils getIntScore:STEALTH_PLANE_SCORE];
}

+ (BOOL)didAchieveRaptor:(int64_t)planeDifficultyLevelScore {
    return planeDifficultyLevelScore >= [DistanceUtils getIntScore:RAPTOR_PLANE_SCORE];
}

+ (BOOL)didAchieveBlackbird:(int64_t)planeDifficultyLevelScore {
    return planeDifficultyLevelScore >= [DistanceUtils getIntScore:BLACKBIRD_PLANE_SCORE];
}

+ (BOOL)didAchieveStratotanker:(int64_t)planeDifficultyLevelScore {
    return planeDifficultyLevelScore >= [DistanceUtils getIntScore:STRATOTANKER_PLANE_SCORE];
}

+ (BOOL)didUnlockHelicopters:(int64_t)planeDifficultyLevelScore {
    // user unlocked the helicopters if he/she unlocked the hercules
    return [AchievementController didAchieveHercules:planeDifficultyLevelScore];
}

+ (BOOL)didAchieveChinook:(int64_t)heliDifficultyLevelScore {
    return heliDifficultyLevelScore >= [DistanceUtils getIntScore:CHINOOK_UNLOCK_SCORE];
}

+ (BOOL)didAchieveOsprey:(int64_t)heliDifficultyLevelScore {
    return heliDifficultyLevelScore >= [DistanceUtils getIntScore:OSPREY_UNLOCK_SCORE];
}

@end
