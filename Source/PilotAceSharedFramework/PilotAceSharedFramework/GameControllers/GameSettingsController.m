//
//  GameSettingsController.m
//  PilotAceSharedFramework
//
//  Created by Sean Kosanovich on 9/13/15.
//  Copyright © 2015 seko. All rights reserved.
//

#import "GameSettingsController.h"
#import <AVFoundation/AVFoundation.h>
#import <GameController/GameController.h>
#import "DifficultyLevel.h"
#import "GameCenterController.h"
#import "AchievementController.h"
#import "NSUserDefaults+SecureNSUserDefaults.h"

NSString *const GAME_CONTROLLER_CONNECTED_NOTIFICATION = @"gameControllerConnected";
NSString *const GAME_CONTROLLER_DISCONNECTED_NOTIFICATION = @"gameControllerDisconnected";

NSString *const ALERT_CONTROLLER_DISMISSED = @"alertControllerDismissed";

NSString *const GAME_STARTING_NOTIFICATION = @"gameIsStarting";
NSString *const GAME_MUSIC_SETTING_CHANGED = @"gameMusicChanged";
NSString *const GAME_MUSIC_SETTING_KEY = @"gameMusicEnabled";

NSString *const SHOW_SHARE_SHEET = @"showShareSheet";
NSString *const SHARE_TEXT_KEY = @"shareText";
NSString *const SHARE_RECT_KEY = @"shareRect";

NSString *const GAME_FONT = @"Chalkduster";
NSString *const ITUNES_URL = @"https://itunes.apple.com/us/app/pilot-ace/id833488539?ls=1&mt=8";

@interface GameSettingsController()
@property (assign, nonatomic) ControllerSensitivity conSensitivity;
@property (nonatomic, strong, readwrite) GCController *controller;
@end

@implementation GameSettingsController

static NSString *const HIGH_SCORE_PREF_KEY = @"highscore";
static NSString *const PLAYER_ID_PREF_KEY = @"playerId";
static NSString *const GAME_MUSIC_PREF_KEY = @"gameMusic";
static NSString *const SOUND_EFFECTS_PREF_KEY = @"soundEffects";
static NSString *const CONTROLLER_SENSITIVITY_PREF_KEY = @"controllerSensitivity";

+ (GameSettingsController *)sharedInstance {
    static GameSettingsController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GameSettingsController alloc] init];
        sharedInstance.controllerSensitivity = [sharedInstance getControllerSensitivityFromPrefs];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if(self) {

        GameSettingsController * __weak w_self = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:GCControllerDidConnectNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [w_self toggleHardwareController: [GCController controllers].count > 0];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:GCControllerDidDisconnectNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [w_self toggleHardwareController: [GCController controllers].count > 0];
        }];

        [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
            // nothing
        }];

#ifdef TVOS
        _mustUseController = YES;
#else
        _mustUseController = NO;
#endif
    }
    return self;
}

- (BOOL)isOtherAudioPlaying {
    return [AVAudioSession sharedInstance].isOtherAudioPlaying;
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

- (int64_t)recordScore:(int64_t)score forDifficultyLevel:(DifficultyLevel *)difficulty {
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

- (void)syncWithRemoteHighScore:(int64_t)remoteHighscore forPlayerId:(NSString *)playerId forDifficultyLevel:(DifficultyLevel *)difficulty {
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

- (int64_t)getLocalHighscoreForDifficultyLevel:(DifficultyLevel *)difficulty {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs secureIntForKey:[difficulty keyWithSuffix:HIGH_SCORE_PREF_KEY]];
}

- (void)saveLocalHighScore:(int64_t)score forDifficultyLevel:(DifficultyLevel *)difficulty {
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

- (ControllerSensitivity)getControllerSensitivityFromPrefs {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs objectForKey:CONTROLLER_SENSITIVITY_PREF_KEY]) {
        // not in, return default
        return ControllerSensitivityNormal;
    }
    return [prefs integerForKey:CONTROLLER_SENSITIVITY_PREF_KEY];
}

- (ControllerSensitivity)getControllerSensitivity {
    return self.conSensitivity;
}

- (void)setControllerSensitivity:(ControllerSensitivity)sensitivity {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:sensitivity forKey:CONTROLLER_SENSITIVITY_PREF_KEY];
    if(![prefs synchronize]) {
        NSLog(@"Error bool to prefs: %@", CONTROLLER_SENSITIVITY_PREF_KEY);
    }

    self.conSensitivity = sensitivity;
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

- (void)toggleHardwareController:(BOOL)useHardware {
    if(self.controller) {
        // reset player index
        self.controller.playerIndex = GCControllerPlayerIndexUnset;
    }

    if (useHardware) {
        // use the first controller
        self.controller = [GameSettingsController getControllerToUse];

#ifdef TVOS
        if (self.controller.microGamepad) {
            // apple tv remote is used sideways
            self.controller.microGamepad.allowsRotation = YES;
        }
#endif
        self.controller.playerIndex = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_CONTROLLER_CONNECTED_NOTIFICATION object:self];
    } else {
        self.controller = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:GAME_CONTROLLER_DISCONNECTED_NOTIFICATION object:self];
    }
}

#ifdef TVOS
// for tvOS, prefer the first extended controller
+ (GCController *)getControllerToUse {
    NSArray<GCController *> *controllers = [GCController controllers];
    if(!controllers || controllers.count == 0) {
        return nil;
    }

    for(GCController *controller in controllers) {
        if(controller.extendedGamepad) {
            // return the first extended controller
            return controller;
        }
    }

    // just use the first one we found
    return controllers[0];
}
#else
// for iOS, prefer the first form-fitting controller
+ (GCController *)getControllerToUse {
    NSArray<GCController *> *controllers = [GCController controllers];
    if(!controllers || controllers.count == 0) {
        return nil;
    }

    for(GCController *controller in controllers) {
        if(controller.isAttachedToDevice) {
            // return the first form-fitting/conencted controller
            return controller;
        }
    }

    for(GCController *controller in controllers) {
        if(controller.extendedGamepad) {
            // return the first extended
            return controller;
        }
    }

    // just use the first one we found
    return controllers[0];
}
#endif

- (void)cleanup {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(self.controller) {
        self.controller.playerIndex = GCControllerPlayerIndexUnset;
    }
}

@end
