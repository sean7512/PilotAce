//
//  AppDelegate.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PilotAceAppDelegate.h"
#import "NSUserDefaults+SecureNSUserDefaults.h"
#import "GameCenterController.h"
#import "ViewController.h"
#import "AchievementController.h"
#import "DifficultyLevel.h"

NSString *const GAME_FONT = @"Chalkduster";
NSString *const ITUNES_URL = @"https://itunes.apple.com/us/app/pilot-ace/id833488539?ls=1&mt=8";

@implementation PilotAceAppDelegate

static NSString *const HIGH_SCORE_PREF_KEY = @"highscore";
static NSString *const PLAYER_ID_PREF_KEY = @"playerId";
static NSString *const GAME_MUSIC_PREF_KEY = @"gameMusic";
static NSString *const SOUND_EFFECTS_PREF_KEY = @"soundEffects";
static CGFloat const IPAD_NODE_SCALE = 2.2;
static CGFloat const IPONE_NODE_SCALE = 1;
static CGFloat nodeScale;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // initialize the gamecenter controller
    [GameCenterController sharedInstance];
    NSError *error = nil;
    if(![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error]) {
        NSLog(@"An error setting the shared audio category: %@", error);
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self pauseGame];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self pauseGame];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self resumeGame];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self resumeGame];
}

- (void)resumeGame {
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    [viewController resumeGame];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)pauseGame {
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    [viewController pauseGame];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[GameCenterController sharedInstance] cleanup];
}

- (CGFloat)getNodeScale {
    if(!nodeScale) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nodeScale = IPONE_NODE_SCALE;
        } else {
            nodeScale = IPAD_NODE_SCALE;
        }
    }
    return nodeScale;
}

- (BOOL)isHerculesUnlocked {
    // hercules is unlocked on plane difficulty
    return [AchievementController didAchieveHercules:[self getLocalHighscoreForDifficultyLevel:[DifficultyLevel planeDifficulty]]];
}

- (BOOL)isStealthUnlocked {
    // stealth is unlocked on plane difficulty
    return [AchievementController didAchieveStealthFighter:[self getLocalHighscoreForDifficultyLevel:[DifficultyLevel planeDifficulty]]];
}
- (BOOL)isRaptorUnlocked {
    // raptor is unlocked on plane difficulty
    return [AchievementController didAchieveRaptor:[self getLocalHighscoreForDifficultyLevel:[DifficultyLevel planeDifficulty]]];
}

- (BOOL)isBlackbirdUnlocked {
    // blackbird is unlocked on plane difficulty
    return [AchievementController didAchieveBlackbird:[self getLocalHighscoreForDifficultyLevel:[DifficultyLevel planeDifficulty]]];
}

- (BOOL)isStratotankerUnlocked {
    // stratotanker is unlocked on plane difficulty
    return [AchievementController didAchieveStratotanker:[self getLocalHighscoreForDifficultyLevel:[DifficultyLevel planeDifficulty]]];
}

- (BOOL)isApacheUnlocked {
    // user unlocks helicopters on plane difficulty
    return [AchievementController didUnlockHelicopters:[self getLocalHighscoreForDifficultyLevel:[DifficultyLevel planeDifficulty]]];
}

- (BOOL)isChinookUnlocked {
    // chinook is unlocked on helicopter difficulty
    return [AchievementController didAchieveChinook:[self getLocalHighscoreForDifficultyLevel:[DifficultyLevel helicopterDifficulty]]];
}

- (BOOL)isOspreyUnlocked {
    // osprey is unlocked on helicopter difficulty
    return [AchievementController didAchieveOsprey:[self getLocalHighscoreForDifficultyLevel:[DifficultyLevel helicopterDifficulty]]];
}

- (int64_t)recordScore:(int64_t)score forDifficultyLevel:(DifficultyLevel *)difficulty; {
    int64_t oldHighScore = [self getLocalHighscoreForDifficultyLevel:difficulty];
    int64_t retVal = oldHighScore;

    // only save locally if its a high score
    if(score > oldHighScore) {
        // save locally
        [self saveLocalHighScore:score forDifficultyLevel:difficulty];

        // return new high score
        retVal = score;
    }

    if([GKLocalPlayer localPlayer].isAuthenticated) {
        // send to gc if logged in
        [[GameCenterController sharedInstance] reportNewTotalScore:score forDifficulty:difficulty];
        [AchievementController applyEndGameAchievementsForDistanceTraveledKm:score forDifficulty:difficulty];
    }

    // return new high score
    return retVal;
}

- (void)syncWithRemoteHighScore:(int64_t)remoteHighscore forPlayerId:(NSString *)playerId forDifficultyLevel:(DifficultyLevel *)difficulty; {
    // need to sync correctly based on GC playerId
    NSString *lastPlayerId = [self getPlayerId];

    // perform a 2-way sync if lastPlayerId is nil OR if the new and old playerId are the same
    if(lastPlayerId == nil || [lastPlayerId isEqualToString:playerId]) {
        [self performTwoWayScoreSync:remoteHighscore forDifficultyLevel:difficulty];
    } else {
        // only do a cloud->local sync on new GC id
        [self saveLocalHighScore:remoteHighscore forDifficultyLevel:difficulty];

        // ensure all achievements are reported
        [AchievementController applyEndGameAchievementsForDistanceTraveledKm:remoteHighscore forDifficulty:difficulty];
    }

    // always set new GC playerId
    [self setPlayerId:playerId];
}

- (void)performTwoWayScoreSync:(int64_t)remoteHighscore forDifficultyLevel:(DifficultyLevel *)difficulty {
    int64_t localHighscore = [self getLocalHighscoreForDifficultyLevel:difficulty];

    // make sure the highest score is represented both locally and remotely
    if(localHighscore > remoteHighscore) {
        // the local highscore isn't in GC, update GC score and achievements
        [[GameCenterController sharedInstance] reportNewTotalScore:localHighscore forDifficulty:difficulty];
        [AchievementController applyEndGameAchievementsForDistanceTraveledKm:localHighscore forDifficulty:difficulty];
    } else if(remoteHighscore > localHighscore) {
        // score in GC is higher than local, save locally
        [self saveLocalHighScore:remoteHighscore forDifficultyLevel:difficulty];

        // ensure all achievements are reported
        [AchievementController applyEndGameAchievementsForDistanceTraveledKm:remoteHighscore forDifficulty:difficulty];
    } else {
        // scores are the same, just ensure achievements are up-to-date
        [AchievementController applyEndGameAchievementsForDistanceTraveledKm:remoteHighscore forDifficulty:difficulty];
    }
}

- (int64_t)getLocalHighscoreForDifficultyLevel:(DifficultyLevel *)difficulty; {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs secureIntForKey:[difficulty keyWithSuffix:HIGH_SCORE_PREF_KEY]];
}

- (void)saveLocalHighScore:(int64_t)score forDifficultyLevel:(DifficultyLevel *)difficulty; {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setSecureInt:score forKey:[difficulty keyWithSuffix:HIGH_SCORE_PREF_KEY]];
    if(![prefs synchronize]) {
        NSLog(@"Error writing score to prefs");
    }
}

- (NSString *)getPlayerId {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs stringForKey:PLAYER_ID_PREF_KEY];
}

- (void)setPlayerId:(NSString *)playerId {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:playerId forKey:PLAYER_ID_PREF_KEY];
    if(![prefs synchronize]) {
        NSLog(@"Error writing score to prefs");
    }
}

- (BOOL)isOtherAudioPlaying {
    return [[AVAudioSession sharedInstance] isOtherAudioPlaying];
}

- (BOOL)isGameMusicEnabled {
    return [self getBoolPrefForKey:GAME_MUSIC_PREF_KEY defaultValue:YES];
}

- (void)setGameMusicEnabled:(BOOL)enabled {
    [self setBool:enabled forPrefKey:GAME_MUSIC_PREF_KEY];
}
- (BOOL)isSoundEffectsEnabled {
    return [self getBoolPrefForKey:SOUND_EFFECTS_PREF_KEY defaultValue:YES];
}

- (void)setSoundEffectsEnabled:(BOOL)enabled {
    [self setBool:enabled forPrefKey:SOUND_EFFECTS_PREF_KEY];
}

- (BOOL)getBoolPrefForKey:(NSString *)key defaultValue:(BOOL)defValue {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    if (![prefs objectForKey:key]) {
        // not in, return default
        return defValue;
    }

    return [prefs boolForKey:key];
}

- (void)setBool:(BOOL)value forPrefKey:(NSString *)key {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:value forKey:key];
    if(![prefs synchronize]) {
        NSLog(@"Error bool to prefs: %@", key);
    }
}

@end
