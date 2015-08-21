//
//  MyScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "MainMenuScene.h"
#import "PilotAceAppDelegate.h"
#import "LabelButton.h"
#import "MainLevelScene.h"
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "GameCenterController.h"
#import "PlaneChooserScene.h"
#import "StandardPlane.h"
#import "SettingsScene.h"
#import "ViewController.h"

@implementation MainMenuScene

- (id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        // nothing to init
    }
    return self;
}

+ (id)createWithSize:(CGSize)size {
    MainMenuScene *mainMenu = [[MainMenuScene alloc] initWithSize:size];
    [mainMenu populateInitialScreen];
    return mainMenu;
}

- (void)populateInitialScreen {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    self.physicsWorld.gravity = CGVectorMake(0,0);

    CGFloat midX = CGRectGetMidX(self.frame);
    CGFloat midY = CGRectGetMidY(self.frame);

    [SceneTimeOfDayFactory setUpScene:self forTimeOfDayData:[DayTimeSceneData sharedInstance] withMovement:YES];

    // title
    SKLabelNode *gameTitleLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    gameTitleLabel.text = @"Pilot Ace";
    gameTitleLabel.fontSize = 50 * nodeScale;
    gameTitleLabel.position = CGPointMake(midX, self.frame.size.height-(100 * nodeScale));
    [self addChild:gameTitleLabel];

    // settings
    MainMenuScene * __weak w_self = self;
    LabelButton *settingsButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.7];
            SettingsScene *settings = [SettingsScene createWithSize:w_self.frame.size withBackScene:w_self withBackTitle:@"Main Menu"];
            [w_self.scene.view presentScene: settings transition: reveal];
        }
    }];
    settingsButton.text = @"Settings";
    settingsButton.fontSize = 15 * nodeScale;
    settingsButton.position = CGPointMake(self.frame.size.width - settingsButton.frame.size.width/2 -20*nodeScale, self.frame.size.height - settingsButton.frame.size.height/2 - 20*nodeScale);
    [self addChild:settingsButton];

    // plane
    Airplane *plane = [StandardPlane createForDraggable:DraggableNone];
    [plane setScale:nodeScale];
    plane.position = CGPointMake(midX, midY);
    [self addChild:plane];

    // play button
    LabelButton *playButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKAction *planeFlyAction = [SKAction moveToX:w_self.size.width + plane.size.width/2 duration:0.6];
            [plane runAction:planeFlyAction completion:^{
                SKTransition *reveal = [SKTransition crossFadeWithDuration:0.7];
                PlaneChooserScene *planeChooser = [PlaneChooserScene createWithSize:w_self.frame.size];
                [w_self.scene.view presentScene: planeChooser transition: reveal];
            }];
        }
    }];
    playButton.text = @"Play";
    playButton.fontSize = 20 * nodeScale;
    playButton.position = CGPointMake(plane.position.x - playButton.frame.size.width*2.7, midY+(30*nodeScale));
    [self addChild:playButton];

    // leaderboard button
    LabelButton *leaderboardButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DISPLAY_LEADERBOARD_REQUEST object:w_self userInfo:nil];
        }
    }];
    leaderboardButton.text = @"High Scores";
    leaderboardButton.fontSize = 20 * nodeScale;
    leaderboardButton.position = CGPointMake(playButton.position.x, midY-(10*nodeScale));
    [self addChild:leaderboardButton];

    // tell a friend button
    LabelButton *tellFriendButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            NSString *tellFriendText = [NSString stringWithFormat:@"Check out Pilot Ace for iOS - %@", ITUNES_URL];
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SHARE_SHEET object:w_self userInfo:@{SHARE_TEXT_KEY: tellFriendText}];
        }
    }];
    tellFriendButton.text = @"Tell a Friend";
    tellFriendButton.fontSize = 20 * nodeScale;
    tellFriendButton.position = CGPointMake(playButton.position.x, midY-(50*nodeScale));
    [self addChild:tellFriendButton];
}

@end
