//
//  MainLevelScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <GameController/GameController.h>
#import "MainLevelScene.h"
#import "GameSettingsController.h"
#import "AirplaneController.h"
#import "GameOverScene.h"
#import "FuelIndicator.h"
#import "MissileController.h"
#import "CollisionController.h"
#import "GameOverListener.h"
#import "ShapedButton.h"
#import "Bullet.h"
#import "Missile.h"
#import "SKEmitterNodeFactory.h"
#import "StatusBar.h"
#import "BulletController.h"
#import "DistanceController.h"
#import "SceneTimeOfDayFactory.h"
#import "TimeOfDaySceneData.h"
#import "SceneInsetProvider.h"
#import "ObstacleController.h"
#import "PausedScreenNode.h"
#import "HowToPlayOverlayNode.h"
#import "AchievementController.h"
#import "Airplane.h"
#import "DifficultyLevel.h"
#import "GameSettingsController.h"

@interface MainLevelScene() <GameOverListener, SceneInsetProvider>

@property (strong, nonatomic) StatusBar *statusBar;
@property (strong, nonatomic) AirplaneController *planeController;
@property (strong, nonatomic) MissileController *missileController;
@property (strong, nonatomic) BulletController *bulletController;
@property (strong, nonatomic) CollisionController *collisionController;
@property (strong, nonatomic) DistanceController *distanceController;
@property (strong, nonatomic) ObstacleController *obstacleController;
@property (strong, nonatomic) ShapedButton *fireButton;
@property (strong, nonatomic) NSObject<TimeOfDaySceneData> *sceneData;
@property (strong, nonatomic) PausedScreenNode *pausedScreen;
@property (strong, nonatomic) HowToPlayOverlayNode *howToPlay;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@property (strong, nonatomic, readonly) DifficultyLevel *difficultyLevel;
@property (strong, nonatomic, readonly) GameSettingsController *gameSettingsController;
@property (strong, nonatomic) NSTimer *autoShootTimer;

@property (assign, nonatomic) ControllerSensitivity controllerSensitivity;
@property (assign, nonatomic) NSTimeInterval diedTime;
@property (assign, nonatomic) NSTimeInterval lastUpdatedTime;
@property (assign, nonatomic) NSTimeInterval totalTimePausedByUser;
@property (assign, nonatomic) BOOL isPausedByUser;
@property (assign, nonatomic) BOOL isGameOver;
@property (assign, nonatomic) BOOL isGameOverTransitionRequested;
@property (assign, nonatomic) CGFloat planeHeight;
@property (assign, nonatomic) CGFloat nodeScale;
@property (assign, nonatomic) CGFloat currSceneSpeed;

@property (assign, nonatomic, readonly) CGFloat sideInset;

@end

@implementation MainLevelScene

static CGFloat const TOP_LAYER_Z_INDEX = 100;
static CGFloat const PLANE_X_POS = 130;
static CGFloat const PLANE_DRAG_X = 180;
static CGFloat const PLANE_Y_BOUNDING_BOX = 50;
static NSTimeInterval const NEVER_DIED_TAG = -1;
static NSTimeInterval const DEF_TIME_PAUSED = 0;
static NSTimeInterval const NEVER_UPDATED_TAG = -1;
static NSTimeInterval const SECONDS_AFTER_DEATH_SWITCH_SCENE = 2.5;

static NSString *const BACKGROUND_MUSIC_FILE = @"in_game_background";
static NSString *const PAUSE_SOUND = @"pause.caf";
static NSString *const UNPAUSE_SOUND = @"unpause.caf";
static NSString *const MUSIC_EXTENSION = @"caf";

static SKAction *_pauseSoundAction;
static SKAction *_unpauseSoundAction;

- (id)initWithSize:(CGSize)size withSideInsets:(CGFloat)inset forDifficultyLevel:(DifficultyLevel *)difficulty {
    if (self = [super initWithSize:size]) {
        _diedTime = NEVER_DIED_TAG;
        _isGameOver = NO;
        _isGameOverTransitionRequested = NO;
        _totalTimePausedByUser = DEF_TIME_PAUSED;
        _lastUpdatedTime = NEVER_UPDATED_TAG;
        _isPausedByUser = NO;
        _difficultyLevel = difficulty;
        _gameSettingsController = [GameSettingsController sharedInstance];
        _controllerSensitivity = [_gameSettingsController getControllerSensitivity];

        [_gameSettingsController.menuHandlerDelegate setUseNativeMenuHandling:NO];

        _sideInset = inset;

        MainLevelScene * __weak w_self = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:GAME_CONTROLLER_CONNECTED_NOTIFICATION object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [w_self setupController: w_self.gameSettingsController.controller];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:GAME_CONTROLLER_DISCONNECTED_NOTIFICATION object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [w_self pauseGamePlayingSound:YES];
        }];

        static dispatch_once_t loadPauseSoundsOnce;
        dispatch_once(&loadPauseSoundsOnce, ^{
            _pauseSoundAction = [SKAction playSoundFileNamed:PAUSE_SOUND waitForCompletion:NO];
            _unpauseSoundAction = [SKAction playSoundFileNamed:UNPAUSE_SOUND waitForCompletion:NO];
        });
    }

    return self;
}

+ (id)createWithSize:(CGSize)size withSideInsets:(CGFloat)inset forPlane: (Airplane *)plane forDiffucultyLebel: (DifficultyLevel *)difficulty {
    MainLevelScene *mainLevel = [[MainLevelScene alloc] initWithSize:size withSideInsets:inset forDifficultyLevel:difficulty];
    [mainLevel populateInitialScreenForPlane:plane];

    // setup controller
    if([GameSettingsController sharedInstance].controller) {
        [mainLevel setupController:[GameSettingsController sharedInstance].controller];
    }

    return mainLevel;
}

- (void)willMoveFromView:(SKView *)view {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super willMoveFromView:view];
}

- (void)populateInitialScreenForPlane:(Airplane *)plane {
    self.nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    self.physicsWorld.gravity = CGVectorMake(0, 0);
    CGFloat overlayZPos = TOP_LAYER_Z_INDEX + 1;

    // pause screen
    self.pausedScreen = [PausedScreenNode createForScreenWithSize:self.size withPauseGameController:self];
    self.pausedScreen.zPosition = overlayZPos;

    // set scene
    self.sceneData = [SceneTimeOfDayFactory setUpSceneWithRandomTimeOfDayData:self withMovement:YES];

    // plane controller
    self.planeController = [[AirplaneController alloc] initWithScene:self withPlane:plane withPlaneXPos:PLANE_X_POS*self.nodeScale];
    self.planeHeight = plane.size.height;

    // missiles
    self.missileController = [[MissileController alloc] initWithScene:self forDifficulty:self.difficultyLevel];

    // obstacles
    self.obstacleController = [[ObstacleController alloc] initWithScene:self forDifficulty:self.difficultyLevel];

    // bullets
    self.bulletController = [[BulletController alloc] initWithScene:self];

    // fire button
    MainLevelScene * __weak w_self = self;
    if (![self.gameSettingsController isAutoShootEnabled]) {
        self.fireButton = [ShapedButton createWithTouchDownInsideEventCallBack:^{
            if(w_self && !w_self.isGameOver && !w_self.isPausedByUser && ![GameSettingsController sharedInstance].mustUseController && ![GameSettingsController sharedInstance].controller) {
                // shoot bullet
                [w_self.bulletController shootBulletAt:[w_self.planeController getPlaneBulletPosition]];
            }
        }];
        [self.fireButton rectWithWidth:(self.size.width - (PLANE_DRAG_X*self.nodeScale)) height:(self.size.height)];
        self.fireButton.strokeColor = [SKColor clearColor];
        self.fireButton.fillColor = [SKColor clearColor];
        self.fireButton.antialiased = NO;
        self.fireButton.zPosition = TOP_LAYER_Z_INDEX;
        self.fireButton.position = CGPointMake(PLANE_DRAG_X*self.nodeScale, 0);
        [self addChild:self.fireButton];
    }

    // status bar
    self.statusBar = [StatusBar createWithPauseSceneController:self withSideInsets:self.sideInset];
    self.statusBar.position = CGPointMake(0, self.frame.size.height - self.statusBar.frame.size.height);
    self.statusBar.zPosition = TOP_LAYER_Z_INDEX;
    [self addChild:self.statusBar];

    // collision detection
    self.collisionController = [[CollisionController alloc] initWithScene:self withPlaneController:self.planeController];
    self.physicsWorld.contactDelegate = self.collisionController;

    // distance controller
    self.distanceController = [[DistanceController alloc] init];

    // background music
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle bundleForClass:[MainLevelScene class]] URLForResource:BACKGROUND_MUSIC_FILE withExtension:MUSIC_EXTENSION];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    if(!self.backgroundMusicPlayer) {
        NSLog(@"An error occurred while laoding the background music: %@", error);
    } else {
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
    }

    // how to play overlay
    self.howToPlay = [HowToPlayOverlayNode createForScreenWithSize:self.size withPauseGameController:self];
    self.howToPlay.zPosition = overlayZPos;
    [self addChild:self.howToPlay];

    // start game in a paused state, dismissing the instructions will resume
    self.isPausedByUser = YES;
    self.currSceneSpeed = self.speed;

    if ([self.gameSettingsController isAutoShootEnabled]) {
        self.autoShootTimer = [NSTimer scheduledTimerWithTimeInterval:0.30 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if(w_self && !w_self.isGameOver && !w_self.isPausedByUser) {
                // shoot bullet
                [w_self.bulletController shootBulletAt:[w_self.planeController getPlaneBulletPosition]];
            }
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)handleTouches:(NSSet *)touches {
    if(self.isPausedByUser || self.isGameOver || [GameSettingsController sharedInstance].mustUseController || [GameSettingsController sharedInstance].controller) {
        return;
    }

    for(UITouch *touch in touches) {
        CGPoint touchPos = [touch locationInNode:self];
        if([self.gameSettingsController isAutoShootEnabled] || touchPos.x < PLANE_DRAG_X*self.nodeScale) {
            if(touchPos.y > ([self.planeController getPlanePosition].y - (self.planeHeight/2) - PLANE_Y_BOUNDING_BOX) && touchPos.y < ([self.planeController getPlanePosition].y + (self.planeHeight/2) + PLANE_Y_BOUNDING_BOX)) {
                [self.planeController movePlaneToY:touchPos.y];
            }
        }
    }
}

- (void)cleanupControllerHandlers {
    GCController *controller = [GameSettingsController sharedInstance].controller;

    if (controller && controller.microGamepad) {
        [controller.microGamepad.buttonX setPressedChangedHandler:NULL];
        [controller.microGamepad.buttonA setPressedChangedHandler:NULL];
        [controller.microGamepad.dpad setValueChangedHandler:NULL];
        [controller.microGamepad.buttonMenu setValueChangedHandler:NULL];
    }

    // also handled extended gamepad
    if (controller && controller.extendedGamepad) {
        [controller.extendedGamepad.buttonX setPressedChangedHandler:NULL];
        [controller.extendedGamepad.buttonA setPressedChangedHandler:NULL];
        [controller.extendedGamepad.dpad setValueChangedHandler:NULL];
        [controller.extendedGamepad.buttonMenu setValueChangedHandler:NULL];
    }
    
    if (controller && controller.extendedGamepad) {
        [controller.extendedGamepad.leftThumbstick setValueChangedHandler:NULL];
    }
}

- (void)buttonXChanged:(GCControllerButtonInput *)button withValue:(float)value isPressed:(BOOL)pressed {
    if(pressed && !self.isGameOver && !self.isPausedByUser && ![self.gameSettingsController isAutoShootEnabled]) {
        // shoot bullet
        [self.bulletController shootBulletAt:[self.planeController getPlaneBulletPosition]];
    } else if (self.howToPlay && self.howToPlay.scene && pressed) {
        [self resumeGame];
    }
}

- (void)buttonAChanged:(GCControllerButtonInput *)button withValue:(float)value isPressed:(BOOL)pressed {
    // remove how to play when touchpad is clicked
    if (self.howToPlay && self.howToPlay.scene && pressed) {
        [self resumeGame];
    }
}

- (void)controllerPauseButtonPressed:(GCController *)controller {
    if(self.isPausedByUser) {
        [self resumeGame];
    } else {
        [self pauseGamePlayingSound:YES];
    }
}

- (void)setupController:(GCController *)controller {
    MainLevelScene * __weak w_self = self;

    if(controller.extendedGamepad) {
        // execute action on button x press
        [controller.extendedGamepad.buttonX setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonXChanged:button withValue:value isPressed:pressed];
        }];

        [controller.extendedGamepad.buttonA setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonAChanged:button withValue:value isPressed:pressed];
        }];

        [controller.extendedGamepad.buttonMenu setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if (pressed) {
                [w_self controllerPauseButtonPressed:controller];
            }
        }];
    } else if (controller.microGamepad) {
        controller.microGamepad.reportsAbsoluteDpadValues = YES;

        [controller.microGamepad.buttonX setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonXChanged:button withValue:value isPressed:pressed];
        }];

        [controller.microGamepad.buttonA setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonAChanged:button withValue:value isPressed:pressed];
        }];

        [controller.microGamepad.buttonMenu setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            if (pressed) {
                [w_self controllerPauseButtonPressed:controller];
            }
        }];
    }
}

- (void)removeFromParent {
    [self.fireButton removeFromParent];
    self.fireButton = nil;
    [super removeFromParent];
}

- (void)update:(NSTimeInterval)currentTime {
    if(self.lastUpdatedTime == NEVER_UPDATED_TAG) {
        self.lastUpdatedTime = currentTime;
    }

    NSTimeInterval elapsed = currentTime - self.lastUpdatedTime;
    if(self.isPausedByUser) {
        self.totalTimePausedByUser = elapsed;
        return;
    }
    // adjust for all the time that was paused
    elapsed -= self.totalTimePausedByUser;

    if(self.isGameOver) {
        if(!self.isGameOverTransitionRequested && currentTime - self.diedTime - self.totalTimePausedByUser >= SECONDS_AFTER_DEATH_SWITCH_SCENE) {
            [self transitionToGameOverScene];
        }
        return;
    }

    if([self.planeController didPlaneNosedive]) {
        // plane ran out of fuel and nosedived
        // don't update the score or anything
        return;
    }

    if(self.gameSettingsController.mustUseController || self.gameSettingsController.controller) {
        float yValue = [self getControllerYAxis];

        CGFloat newYPos = [self.planeController getPlanePosition].y + (yValue*self.controllerSensitivity);
        if(newYPos > ([self.planeController getPlanePosition].y - (self.planeHeight/2) - PLANE_Y_BOUNDING_BOX) && newYPos < ([self.planeController getPlanePosition].y + (self.planeHeight/2) + PLANE_Y_BOUNDING_BOX)) {
            [self.planeController movePlaneToY:newYPos];
        }
    }

    // update plane controller
    [self.planeController update:elapsed  withSpeedMultiplier:self.speed];

    // update missile controller
    [self.missileController update:elapsed  withSpeedMultiplier:self.speed];

    // update the obstacle controller
    [self.obstacleController update:elapsed  withSpeedMultiplier:self.speed];

    // distance calculator
    [self.distanceController update:elapsed withSpeedMultiplier:self.speed];

    // update status bar
    [self.statusBar updateWithFuelPercent:[self.planeController getPlaneFuelTankPercentFull] withDistance:self.distanceController.distanceTraveledKm];

    // apply any achievements
    [AchievementController applyInGameAchievementsForDistanceTraveledKm:self.distanceController.distanceTraveledKm forScene:self forDifficulty:self.difficultyLevel];

    // reset pause time and update last update time
    self.totalTimePausedByUser = DEF_TIME_PAUSED;
    self.lastUpdatedTime = currentTime;
}

- (void)setIsGameOver:(BOOL)isGameOver {
    _isGameOver = isGameOver;
    if(isGameOver) {
        self.diedTime = CACurrentMediaTime();
    }
}

- (void)gameOver {
    [self cleanupControllerHandlers];
    self.isGameOver = YES;
    self.speed = 0;
    [self.backgroundMusicPlayer stop];
    if (self.autoShootTimer && self.autoShootTimer.isValid) {
        [self.autoShootTimer invalidate];
        self.autoShootTimer = NULL;
    }
}

- (void)pauseGame {
    [self pauseGamePlayingSound:NO];
}

- (void)pauseGamePlayingSound:(BOOL)playSound {
    if(!self.isPausedByUser) {
        self.isPausedByUser = YES;
        self.currSceneSpeed = self.speed;
        self.speed = 0;

        // pause screen will take over controller input
        [self cleanupControllerHandlers];

        // allow the paused screen to start listening for controller input
        [self.pausedScreen setupController];

        GameSettingsController *gameSettings = [GameSettingsController sharedInstance];
        if(playSound && (![gameSettings isOtherAudioPlaying]) && [gameSettings isSoundEffectsEnabled] && _pauseSoundAction) {
            [self runAction:_pauseSoundAction];
        }

        [self addChild:self.pausedScreen];
        if(self.backgroundMusicPlayer) {
            [self.backgroundMusicPlayer stop];
        }

        // send fullscreen ad always when user paused
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_FULLSCREEN_AD object:self userInfo:@{FULLSCREEN_INTERVAL_KEY: @-1}];
    }
}

- (void)quitGame {
    [self gameOver];
    [self transitionToGameOverScene];
}

- (void)transitionToGameOverScene {
    self.isGameOverTransitionRequested = YES;
    SKTransition *reveal = [SKTransition doorsCloseHorizontalWithDuration:0.7];
    GameOverScene *gameOverScene = [GameOverScene createWithSize:self.frame.size withSideInsets:self.sideInset withDistanceTraveled:self.distanceController.distanceTraveledKm forDifficulty:self.difficultyLevel];
    [self.scene.view presentScene:gameOverScene transition:reveal];
}

- (void)resumeGame {
    if(self.isPausedByUser) {
        GameSettingsController *gameSettings = [GameSettingsController sharedInstance];

        // if coming back from pause screen, re-setup controller input to here
        if(self.pausedScreen.scene && gameSettings.controller) {
            [self setupController:[GameSettingsController sharedInstance].controller];
        }

        self.isPausedByUser = NO;
        self.speed = self.currSceneSpeed;

        if(self.pausedScreen.scene) {
            [self.pausedScreen removeFromParent];
            if((![gameSettings isOtherAudioPlaying]) && [gameSettings isSoundEffectsEnabled] && _unpauseSoundAction) {
                [self runAction:_unpauseSoundAction];
            }
        }

        if(self.howToPlay && self.howToPlay.scene) {
            [self.howToPlay removeFromParent];
            self.howToPlay = nil;
        }

        [self playBackgroundMusic];
    }
}

- (void)playBackgroundMusic {
    GameSettingsController *gameSettings = [GameSettingsController sharedInstance];
    if((![gameSettings isOtherAudioPlaying]) &&  [gameSettings isGameMusicEnabled] && (!self.isGameOver) && self.backgroundMusicPlayer) {
        [self.backgroundMusicPlayer play];
    }
}

- (CGFloat)getTopInset {
    return STATUS_BAR_HEIGHT*self.nodeScale;
}

- (CGFloat)getBottomInset {
    return self.sceneData.foregroundTexture.size.height*self.nodeScale;
}

- (CGFloat)getPlaneBulletMaxHeight {
    return [self.planeController getPlaneBulletMaxHeight];
}

- (CGFloat)getPlaneBulletMinHeight {
    return [self.planeController getPlaneBulletMinHeight];
}

- (float)getControllerYAxis {
    if(self.gameSettingsController.controller.extendedGamepad) {
        float joystickVal = self.gameSettingsController.controller.extendedGamepad.leftThumbstick.yAxis.value;
        float dpadVal = self.gameSettingsController.controller.extendedGamepad.dpad.yAxis.value;
        return joystickVal == 0 ? dpadVal : joystickVal;
    }

    if(self.gameSettingsController.controller.extendedGamepad) {
        return self.gameSettingsController.controller.extendedGamepad.dpad.yAxis.value;
    }

    if(self.gameSettingsController.controller.microGamepad) {
        return self.gameSettingsController.controller.microGamepad.dpad.yAxis.value;
    }
    return 0;
}

@end
