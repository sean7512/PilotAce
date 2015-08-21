//
//  AppDelegate.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DifficultyLevel;

extern NSString *const GAME_FONT;
extern NSString *const ITUNES_URL;

@interface PilotAceAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (int64_t)recordScore:(int64_t)score forDifficultyLevel:(DifficultyLevel *)difficulty;
- (void)syncWithRemoteHighScore:(int64_t)remoteHighscore forPlayerId:(NSString *)playerId forDifficultyLevel:(DifficultyLevel *)difficulty;
- (BOOL)isHerculesUnlocked;
- (BOOL)isStealthUnlocked;
- (BOOL)isRaptorUnlocked;
- (BOOL)isBlackbirdUnlocked;
- (BOOL)isStratotankerUnlocked;
- (BOOL)isApacheUnlocked;
- (BOOL)isChinookUnlocked;
- (BOOL)isOspreyUnlocked;
- (CGFloat)getNodeScale;
- (BOOL)isOtherAudioPlaying;
- (BOOL)isGameMusicEnabled;
- (void)setGameMusicEnabled:(BOOL)enabled;
- (BOOL)isSoundEffectsEnabled;
- (void)setSoundEffectsEnabled:(BOOL)enabled;

@end
