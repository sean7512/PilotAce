//
//  GameCenterController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "GameCenterController.h"
#import "GameSettingsController.h"
#import "DifficultyLevel.h"
#import "AchievementController.h"

@interface GameCenterController() <GKGameCenterControllerDelegate>

@property (strong, nonatomic) NSMutableSet *singleTimeAchievementsEarned;

@end

NSString *const GAME_CENTER_LOCAL_PLAYER_AUTHENTICATED = @"gameCenterLocalPlayerAuthenticated";
NSString *const GAME_CENTER_LOCAL_PLAYER_ID = @"localPlayer";
NSString *const DISPLAY_LEADERBOARD_REQUEST = @"displayLeaderboard";

@implementation GameCenterController

static NSString *const TOTAL_DISTANCE_LEADERBOARD_ID = @"pilot_ace_total_distance";
static NSString *const MACH_TWO_ACHIEVEMENT_ID = @"pilot_ace_mach_two";
static NSString *const MACH_THREE_ACHIEVEMENT_ID = @"pilot_ace_mach_three";

static NSString *const HERCULES_ACHIEVEMENT_ID = @"pilot_ace_hercules";
static NSString *const STEALTH_ACHIEVEMENT_ID = @"pilot_ace_stealth";
static NSString *const RAPTOR_ACHIEVEMENT_ID = @"pilot_ace_raptor";
static NSString *const BLACKBIRD_ACHIEVEMENT_ID = @"pilot_ace_blackbird";
static NSString *const STRATOTANKER_ACHIEVEMENT_ID = @"pilot_ace_stratotanker";
static NSString *const APACHE_ACHIEVEMENT_ID = @"pilot_ace_apache";
static NSString *const CHINOOK_ACHIEVEMENT_ID = @"pilot_ace_chinook";
static NSString *const OSPREY_ACHIEVEMENT_ID = @"pilot_ace_osprey";

- (id)init {
    self = [super init];
    if(self) {
        _singleTimeAchievementsEarned = [NSMutableSet new];
    }

    return self;
}

+ (GameCenterController *)sharedInstance {
    static GameCenterController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GameCenterController alloc] init];

        // register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(localPlayerAuthenticated:) name:GAME_CENTER_LOCAL_PLAYER_AUTHENTICATED object:nil];
    });
    return sharedInstance;
}

- (void)localPlayerAuthenticated:(NSNotification *)notification {
    // player authenticated to Game Center, now sync ALL highscore data
    GKPlayer *localPlayer = notification.userInfo[GAME_CENTER_LOCAL_PLAYER_ID];

    // get the highscore for the local player for all difficulty levels
    for (DifficultyLevel *difficulty in [DifficultyLevel getAllDifficultyLevels]) {
        [self getHighScoreForPlayer:localPlayer forDifficultyLevel:difficulty];
    }

}

- (void)getHighScoreForPlayer:(GKPlayer *)player forDifficultyLevel:(DifficultyLevel *)difficulty {
    NSString *leaderboardId = [difficulty keyWithSuffix:TOTAL_DISTANCE_LEADERBOARD_ID];



    [GKLeaderboard loadLeaderboardsWithIDs:@[leaderboardId] completionHandler:^(NSArray<GKLeaderboard *> * _Nullable leaderboards, NSError * _Nullable error) {
        if(error) {
            NSLog(@"An error ocucurred while loading the local player's Game Center highscore: %@", error);
            return;
        }

        if (leaderboardId && leaderboards.count > 0) {
            [leaderboards[0] loadEntriesForPlayers:@[player] timeScope:GKLeaderboardTimeScopeAllTime completionHandler:^(GKLeaderboardEntry * _Nullable_result localPlayerEntry, NSArray<GKLeaderboardEntry *> * _Nullable entries, NSError * _Nullable error) {
                if(error) {
                    NSLog(@"An error ocucurred while loading the local player's Game Center highscore: %@", error);
                    return;
                }

                // should only get 0 or 1 score (depends if user was previously logged in)
                int64_t remoteHighScore = 0;
                if (entries && entries.count > 0) {
                    remoteHighScore = entries[0].score;
                }

                // sync device score with GC
                [[GameSettingsController sharedInstance] syncWithRemoteHighScore:remoteHighScore forPlayerId:player.teamPlayerID forDifficultyLevel:difficulty];
            }];
        }
    }];
}

- (void)reportNewTotalScore:(int64_t)newScore forDifficulty:(DifficultyLevel *)difficulty {
    [GKLeaderboard submitScore:newScore context:0 player: GKLocalPlayer.local leaderboardIDs: @[[difficulty keyWithSuffix:TOTAL_DISTANCE_LEADERBOARD_ID]] completionHandler:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"An error occurred reporting the score to Game Center: %@", error);
        }
    }];
}

- (void)machTwoAchievementEarnedForDifficulty:(DifficultyLevel *)difficulty {
    [self reportRepeatableAchievementWithId:MACH_TWO_ACHIEVEMENT_ID forDifficulty:difficulty];
}

- (void)machThreeAchievementEarnedForDifficulty:(DifficultyLevel *)difficulty {
    [self reportRepeatableAchievementWithId:MACH_THREE_ACHIEVEMENT_ID forDifficulty:difficulty];
}


- (void)herculesAchievementEarned {
    [self reportAchievementEarnedWithId:HERCULES_ACHIEVEMENT_ID withCongratulatoryMessage:nil];
}

- (void)stealthFighterAchievementEarned {
    [self reportAchievementEarnedWithId:STEALTH_ACHIEVEMENT_ID withCongratulatoryMessage:nil];
}

- (void)raptorAchievementEarned {
    [self reportAchievementEarnedWithId:RAPTOR_ACHIEVEMENT_ID withCongratulatoryMessage:nil];
}

- (void)blackbirdAchievementEarned {
    [self reportAchievementEarnedWithId:BLACKBIRD_ACHIEVEMENT_ID withCongratulatoryMessage:nil];
}

- (void)stratotankerAchievementEarned {
    [self reportAchievementEarnedWithId:STRATOTANKER_ACHIEVEMENT_ID withCongratulatoryMessage:@"You unlocked the Stratotanker refueling plane! This plane has a large fuel tank and loses fuel at a slower rate."];
}

- (void)helicopterLevelUnlockEarned {
    [self reportAchievementEarnedWithId:APACHE_ACHIEVEMENT_ID withCongratulatoryMessage:@"You unlocked the helicopters! On the aircraft selection screen, you can swype over to fly with the helicopters."];
}

- (void)chinookAchievementEarned {
    [self reportAchievementEarnedWithId:CHINOOK_ACHIEVEMENT_ID withCongratulatoryMessage:nil];
}

- (void)ospreyAchievementEarned {
    [self reportAchievementEarnedWithId:OSPREY_ACHIEVEMENT_ID withCongratulatoryMessage:nil];
}

/*!
 Reports the given achievement has been earned to Game Center IF AND ONLY IF the current user has not already earned the achievement.
 @param achievementId The achievement Id the user earned.
 @param msg An optional message to show to the user upon receiving the achievement. This message is only shown if the user did not previously earn the achievement. Use nil to not show a message.
 */
- (void)reportAchievementEarnedWithId:(NSString *)achievementId withCongratulatoryMessage:(NSString *)msg {
    if([self.singleTimeAchievementsEarned containsObject:achievementId]) {
        // achievement is already reported
        return;
    }

    GameCenterController * __weak w_self = self;
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if(error) {
            NSLog(@"An error occurred loading the achievement data from Game Center: %@", error);
            return;
        }

        GameCenterController *sw_self = w_self;
        if(sw_self) {
            [sw_self.singleTimeAchievementsEarned addObject:achievementId];
        }

        NSUInteger achievementEarnedIndex = [achievements indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            GKAchievement *achievement = obj;
            if([achievement.identifier isEqualToString:achievementId]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];

        if(achievementEarnedIndex == NSNotFound) {
            // user didn't earn this yet, report it
            GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
            achievement.percentComplete = 100;
            achievement.showsCompletionBanner = YES;

            if(msg) {
                // show success message
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:msg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:ALERT_CONTROLLER_DISMISSED object:w_self userInfo:nil];
                }];
                [alert addAction:okAction];
                [[GameSettingsController sharedInstance].alertDelegate presentAlertController:alert];
            }

            [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
                if(error) {
                    NSLog(@"An error occurred reporting the achievement, %@, to Game Center: %@", achievementId, error);
                    GameCenterController *ssw_self = w_self;
                    if(ssw_self) {
                        [ssw_self.singleTimeAchievementsEarned removeObject:achievementId];
                    }
                }
            }];
        }
    }];
}

- (void)reportRepeatableAchievementWithId:(NSString *)achievementId forDifficulty:(DifficultyLevel *)difficulty {
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:[difficulty keyWithSuffix:achievementId]];
    achievement.percentComplete = 100;
    achievement.showsCompletionBanner = YES;

    [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
        if(error) {
            NSLog(@"An error occurred reporting the achievement, %@, to Game Center: %@", achievementId, error);
        }
    }];
}

- (void)displayLeaderBoardWithViewController:(UIViewController *)viewController {
    GKGameCenterViewController *leaderboardController = [[GKGameCenterViewController alloc] initWithState: GKGameCenterViewControllerStateLeaderboards];
    leaderboardController.gameCenterDelegate = self;
    leaderboardController.modalInPresentation = YES;
    leaderboardController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    [viewController presentViewController:leaderboardController animated:YES completion:NULL];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:ALERT_CONTROLLER_DISMISSED object:self userInfo:nil];
}

- (void)cleanup {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
