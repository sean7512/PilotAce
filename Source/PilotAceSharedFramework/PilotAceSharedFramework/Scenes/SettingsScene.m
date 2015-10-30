//
//  SettingsScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "SettingsScene.h"
#import <GameController/GameController.h>
#import "GameSettingsController.h"
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "LabelButton.h"
#import "MainMenuScene.h"
#import "AboutScene.h"
#import "MultiOptionSelect.h"
#import "NavigableScene_Protected.h"

@interface SettingsScene()

@property (strong, nonatomic, readonly) SKScene *sceneToTransitionTo;
@property (strong, nonatomic, readonly) NSString *backText;

@end

@implementation SettingsScene

- (id)initWithSize:(CGSize)size withBackScene:(SKScene *)scene withBackTitle:(NSString *)backText {
    if (self = [super initWithSize:size]) {
        _sceneToTransitionTo = scene;
        _backText = backText;

        [[GameSettingsController sharedInstance].menuHandlerDelegate setUseNativeMenuHandling:NO];
    }

    return self;
}

+ (id)createWithSize:(CGSize)size withBackScene:(SKScene *)scene withBackTitle:(NSString *)backText {
    SettingsScene *settings = [[SettingsScene alloc] initWithSize:size withBackScene:scene withBackTitle:backText];
    [settings populate];
    return settings;
}

- (void)populate {
    self.physicsWorld.gravity = CGVectorMake(0, 0);

    [SceneTimeOfDayFactory setUpScene:self forTimeOfDayData:[DayTimeSceneData sharedInstance] withMovement:NO];

    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    CGFloat midX = CGRectGetMidX(self.frame);

    SettingsScene * __weak w_self = self;
    LabelButton *mainMenuButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.7];
            [w_self.scene.view presentScene: w_self.sceneToTransitionTo transition: reveal];
        }
    }];
    mainMenuButton.text = [NSString stringWithFormat:@"< %@", self.backText];
    mainMenuButton.fontSize = 15*nodeScale;
    mainMenuButton.position = CGPointMake(mainMenuButton.frame.size.width/2 + 25*nodeScale, self.frame.size.height - mainMenuButton.frame.size.height/2 - 20*nodeScale);
    [self addChild:mainMenuButton];

    SKLabelNode *settings = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    settings.text = @"Settings";
    settings.fontSize = 50*nodeScale;
    settings.position = CGPointMake(midX, mainMenuButton.position.y - settings.frame.size.height/2);
    [self addChild:settings];

    GameSettingsController *gameSettings = [GameSettingsController sharedInstance];
    MultiOptionSelect *music = [MultiOptionSelect createWithLabel:@"Game Music:" withOptions:@[@"On", @"Off"] withSelectedValueChangeListener:^(id selectedOption){
        if(w_self) {
            BOOL gameMusicEnabled = [w_self getBoolForOnOffString:selectedOption];
            [gameSettings setGameMusicEnabled:gameMusicEnabled];
            [[NSNotificationCenter defaultCenter] postNotificationName:GAME_MUSIC_SETTING_CHANGED object:w_self userInfo:@{GAME_MUSIC_SETTING_KEY: [NSNumber numberWithBool:gameMusicEnabled]}];
        }
    }];
    music.position = CGPointMake(midX-25*nodeScale, settings.position.y - 65*nodeScale);
    [self addChild:music];
    music.selectedOption = [self getOnOffForBool:[gameSettings isGameMusicEnabled]];
    [self.navigableNodes addObject:@[music]];

    MultiOptionSelect *soundFx = [MultiOptionSelect createWithLabel:@"Sound Effects:" withOptions:@[@"On", @"Off"] withSelectedValueChangeListener:^(id selectedOption){
        if(w_self) {
            [gameSettings setSoundEffectsEnabled:[w_self getBoolForOnOffString:selectedOption]];
        }
    }];
    soundFx.position = CGPointMake(midX-25*nodeScale, music.position.y - 40*nodeScale);
    [self addChild:soundFx];
    soundFx.selectedOption = [self getOnOffForBool:[gameSettings isSoundEffectsEnabled]];
    [self.navigableNodes addObject:@[soundFx]];

    SKNode *prevNode = soundFx;

    BOOL mustUseController = [GameSettingsController sharedInstance].mustUseController;
    BOOL hasController = mustUseController || [GameSettingsController sharedInstance].controller;

    if(hasController) {
        MultiOptionSelect *controllerSensitivity = [MultiOptionSelect createWithLabel:@"Controller Sensitivity:" withOptions:@[@"Low", @"Med", @"High"] withSelectedValueChangeListener:^(id selectedOption){
            if(w_self) {
                [gameSettings setControllerSensitivity:[w_self getControllerSensitivityString:selectedOption]];
            }
        }];
        controllerSensitivity.position = CGPointMake(midX-25*nodeScale, soundFx.position.y - 40*nodeScale);
        [self addChild:controllerSensitivity];
        controllerSensitivity.selectedOption = [self getSensitivityLabelForSensitivity:[gameSettings getControllerSensitivity]];
        [self.navigableNodes addObject:@[controllerSensitivity]];

        prevNode = controllerSensitivity;
    }

    LabelButton *aboutButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.7];
            AboutScene *about = [AboutScene createWithSize:w_self.frame.size withSettingsOrigin:w_self withSettingsBackText:w_self.backText];
            [w_self.scene.view presentScene: about transition: reveal];
        }
    }];
    aboutButton.text = @"About Pilot Ace";
    aboutButton.fontSize = 25*nodeScale;
    aboutButton.position = CGPointMake(midX, prevNode.position.y - 40*nodeScale);
    [self addChild:aboutButton];
    [self.navigableNodes addObject:@[aboutButton]];

    // make main menu button last in navigable tree
    [self.navigableNodes addObject:@[mainMenuButton]];

    self.selectedNode = music;
}

- (void)setupController:(GCController *)controller {
    [super setupController:controller];

    SettingsScene * __weak w_self = self;
    [controller setControllerPausedHandler:^(GCController * _Nonnull controller) {
        if(w_self) {
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.7];
            [w_self.scene.view presentScene: w_self.sceneToTransitionTo transition: reveal];
        }
    }];
}

- (NSString *)getOnOffForBool:(BOOL)value {
    if(value) {
        return @"On";
    }
    return @"Off";
}

- (BOOL)getBoolForOnOffString:(NSString *)value {
    if([value isEqualToString:@"On"]) {
        return true;
    }
    return false;
}

- (NSString *)getSensitivityLabelForSensitivity:(ControllerSensitivity)sensitivity {
    switch(sensitivity) {
        case ControllerSensitivityLow:
            return @"Low";
        case ControllerSensitivityNormal:
            return @"Med";
        case ControllerSensitivityHigh:
            return @"High";
    }
}

- (ControllerSensitivity)getControllerSensitivityString:(NSString *)value {
    if([value isEqualToString:@"Low"]) {
        return ControllerSensitivityLow;
    } else if([value isEqualToString:@"Med"]) {
        return ControllerSensitivityNormal;
    } else {
        return ControllerSensitivityHigh;
    }
}

- (void)dealloc {
    _sceneToTransitionTo = nil;
}

@end
