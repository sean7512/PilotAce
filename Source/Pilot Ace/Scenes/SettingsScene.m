//
//  SettingsScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "SettingsScene.h"
#import "PilotAceAppDelegate.h"
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "LabelButton.h"
#import "MainMenuScene.h"
#import "AboutScene.h"
#import "MultiOptionSelect.h"
#import "ViewController.h"

@interface SettingsScene()

@property (strong, nonatomic, readonly) SKScene *sceneToTransitionTo;
@property (strong, nonatomic, readonly) NSString *backText;

@end

@implementation SettingsScene

- (id)initWithSize:(CGSize)size withBackScene:(SKScene *)scene withBackTitle:(NSString *)backText {
    if (self = [super initWithSize:size]) {
        _sceneToTransitionTo = scene;
        _backText = backText;
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

    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

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
    mainMenuButton.position = CGPointMake(mainMenuButton.frame.size.width/2 + 20*nodeScale, self.frame.size.height - mainMenuButton.frame.size.height/2 - 20*nodeScale);
    [self addChild:mainMenuButton];

    SKLabelNode *settings = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    settings.text = @"Settings";
    settings.fontSize = 50*nodeScale;
    settings.position = CGPointMake(midX, mainMenuButton.position.y - settings.frame.size.height/2);
    [self addChild:settings];

    MultiOptionSelect *music = [MultiOptionSelect createWithLabel:@"Game Music:" withOptions:@[@"On", @"Off"] withSelectedValueChangeListener:^(id selectedOption){
        if(w_self) {
            BOOL gameMusicEnabled = [w_self getBoolForOnOffString:selectedOption];
            [appDelegate setGameMusicEnabled:gameMusicEnabled];
            [[NSNotificationCenter defaultCenter] postNotificationName:GAME_MUSIC_SETTING_CHANGED object:w_self userInfo:@{GAME_MUSIC_SETTING_KEY: [NSNumber numberWithBool:gameMusicEnabled]}];
        }
    }];
    music.position = CGPointMake(midX-25*nodeScale, settings.position.y - 65*nodeScale);
    [self addChild:music];
    music.selectedOption = [self getOnOffForBool:[appDelegate isGameMusicEnabled]];

    MultiOptionSelect *soundFx = [MultiOptionSelect createWithLabel:@"Sound Effects:" withOptions:@[@"On", @"Off"] withSelectedValueChangeListener:^(id selectedOption){
        if(w_self) {
            [appDelegate setSoundEffectsEnabled:[w_self getBoolForOnOffString:selectedOption]];
        }
    }];
    soundFx.position = CGPointMake(midX-25*nodeScale, music.position.y - 40*nodeScale);
    [self addChild:soundFx];
    soundFx.selectedOption = [self getOnOffForBool:[appDelegate isSoundEffectsEnabled]];

    LabelButton *aboutButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.7];
            AboutScene *about = [AboutScene createWithSize:w_self.frame.size withSettingsOrigin:w_self.sceneToTransitionTo withSettingsBackText:w_self.backText];
            [w_self.scene.view presentScene: about transition: reveal];
        }
    }];
    aboutButton.text = @"About Pilot Ace";
    aboutButton.fontSize = 25*nodeScale;
    aboutButton.position = CGPointMake(midX, soundFx.position.y - 40*nodeScale);
    [self addChild:aboutButton];
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

- (void)dealloc {
    _sceneToTransitionTo = nil;
}

@end
