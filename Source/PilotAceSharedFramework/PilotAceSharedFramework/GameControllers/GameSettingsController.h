//
//  GameSettingsController.h
//  PilotAceSharedFramework
//
//  Created by Sean Kosanovich on 9/13/15.
//  Copyright © 2015 seko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCController;

extern NSString *const GAME_CONTROLLER_CONNECTED_NOTIFICATION;
extern NSString *const GAME_CONTROLLER_DISCONNECTED_NOTIFICATION;

extern NSString *const GAME_STARTING_NOTIFICATION;
extern NSString *const GAME_MUSIC_SETTING_CHANGED;
extern NSString *const GAME_MUSIC_SETTING_KEY;

extern NSString *const SHOW_SHARE_SHEET;
extern NSString *const SHARE_TEXT_KEY;
extern NSString *const SHARE_RECT_KEY;

extern NSString *const GAME_FONT;
extern NSString *const ITUNES_URL;

typedef NS_ENUM(NSInteger, ControllerSensitivity) {
    ControllerSensitivityLow = 5,
    ControllerSensitivityNormal = 15,
    ControllerSensitivityHigh = 25
};

@class DifficultyLevel;

@protocol SystemMenuHandlingScene <NSObject>
// protocol for identification tagging only
@end

@protocol NodeScaleSizeDelegate <NSObject>
@required
- (CGFloat)getNodeScaleSize;
@end

@protocol SocialShareDelegate <NSObject>
@required
- (BOOL)canUseShare;
@end

@protocol AlertControllerPresenter <NSObject>
- (void)presentAlertController:(UIAlertController *)alertViewController;
@end

@protocol MenuHandler <NSObject>
- (void)setUseNativeMenuHandling:(BOOL)useNativeMenuHandling;
@end

@interface GameSettingsController : NSObject

+ (GameSettingsController *)sharedInstance;

- (void)cleanup;

// achievements
- (BOOL)isHerculesUnlocked;
- (BOOL)isStealthUnlocked;
- (BOOL)isRaptorUnlocked;
- (BOOL)isBlackbirdUnlocked;
- (BOOL)isStratotankerUnlocked;
- (BOOL)isApacheUnlocked;
- (BOOL)isChinookUnlocked;
- (BOOL)isOspreyUnlocked;

// audio settings
- (BOOL)isOtherAudioPlaying;
- (BOOL)isGameMusicEnabled;
- (void)setGameMusicEnabled:(BOOL)enabled;
- (BOOL)isSoundEffectsEnabled;
- (void)setSoundEffectsEnabled:(BOOL)enabled;
- (ControllerSensitivity)getControllerSensitivity;
- (void)setControllerSensitivity:(ControllerSensitivity)sensitivity;

// scoring options
- (int64_t)recordScore:(int64_t)score forDifficultyLevel:(DifficultyLevel *)difficulty;
- (void)syncWithRemoteHighScore:(int64_t)remoteHighscore forPlayerId:(NSString *)playerId forDifficultyLevel:(DifficultyLevel *)difficulty;

@property (nonatomic, assign, readonly) BOOL mustUseController;
@property (nonatomic, strong, readonly) GCController *controller;
@property (weak, nonatomic) id<NodeScaleSizeDelegate> nodeScaleDelegate;
@property (weak, nonatomic) id<SocialShareDelegate> shareDelegate;
@property (weak, nonatomic) id<AlertControllerPresenter> alertDelegate;
@property (weak, nonatomic) id<MenuHandler> menuHandlerDelegate;

@end
