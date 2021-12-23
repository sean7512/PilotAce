//
//  MyScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "MainMenuScene.h"
#import <GameController/GameController.h>
#import "GameSettingsController.h"
#import "LabelButton.h"
#import "MainLevelScene.h"
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "GameCenterController.h"
#import "PlaneChooserScene.h"
#import "StandardPlane.h"
#import "SettingsScene.h"
#import "NavigableScene_Protected.h"

@interface MainMenuScene()
@property (nonatomic, strong) Airplane *titlePlane;
@property (assign, nonatomic, readonly) CGFloat sideInset;
@end

@implementation MainMenuScene

- (id)initWithSize:(CGSize)size withSideInsets:(CGFloat)inset {
    if (self = [super initWithSize:size]) {
        _sideInset = inset;
    }
    return self;
}

+ (id)createWithSize:(CGSize)size withSideInsets:(CGFloat)inset {
    MainMenuScene *mainMenu = [[MainMenuScene alloc] initWithSize:size withSideInsets:inset];
    [mainMenu populateInitialScreen];
    return mainMenu;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    [[GameSettingsController sharedInstance].menuHandlerDelegate setUseNativeMenuHandling:YES];

    // move plane back
    CGFloat midX = CGRectGetMidX(self.frame);
    CGFloat midY = CGRectGetMidY(self.frame);
    self.titlePlane.position = CGPointMake(midX, midY);
}

- (void)populateInitialScreen {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    self.physicsWorld.gravity = CGVectorMake(0,0);

    CGFloat midX = CGRectGetMidX(self.frame);
    CGFloat midY = CGRectGetMidY(self.frame);

    [SceneTimeOfDayFactory setUpScene:self forTimeOfDayData:[DayTimeSceneData sharedInstance] withMovement:YES];
    MainMenuScene * __weak w_self = self;

    // settings
    LabelButton *settingsButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            [w_self cleanupControllerHandlers];
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.7];
            SettingsScene *settings = [SettingsScene createWithSize:w_self.frame.size withBackScene:w_self withBackTitle:@"Main Menu"];
            [w_self.scene.view presentScene: settings transition: reveal];
        }
    }];
    settingsButton.text = @"Settings";
    settingsButton.fontSize = 15 * nodeScale;
    settingsButton.position = CGPointMake(self.frame.size.width - settingsButton.frame.size.width/2 -25*nodeScale, self.frame.size.height - settingsButton.frame.size.height/2 - 20*nodeScale);
    [self addChild:settingsButton];
    [self.navigableNodes addObject:@[settingsButton]];

    // title
    SKLabelNode *gameTitleLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    gameTitleLabel.text = @"Pilot Ace";
    gameTitleLabel.fontSize = 50 * nodeScale;
    gameTitleLabel.position = CGPointMake(midX, self.frame.size.height-(100 * nodeScale));
    gameTitleLabel.name = @"background";
    [self addChild:gameTitleLabel];

    // plane
    self.titlePlane = [StandardPlane createForDraggable:DraggableNone];
    [self.titlePlane setScale:nodeScale];
    self.titlePlane.name = @"background";
    self.titlePlane.position = CGPointMake(midX, midY);
    [self addChild:self.titlePlane];

    BOOL canUseShare = [[GameSettingsController sharedInstance].shareDelegate canUseShare];

    // play button
    LabelButton *playButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKAction *planeFlyAction = [SKAction moveToX:w_self.size.width + w_self.titlePlane.size.width/2 duration:0.6];
            [w_self.titlePlane runAction:planeFlyAction completion:^{
                [w_self cleanupControllerHandlers];
                SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.7];
                PlaneChooserScene *planeChooser = [PlaneChooserScene createWithSize:w_self.frame.size withSideInsets:w_self.sideInset withPreviousScene:w_self];
                [w_self.scene.view presentScene: planeChooser transition: reveal];
            }];
        }
    }];
    playButton.text = @"Play";
    playButton.fontSize = 20 * nodeScale;
    playButton.position = CGPointMake(self.titlePlane.position.x - playButton.frame.size.width*2.9, midY+((canUseShare ? 30 : 8)*nodeScale));
    [self addChild:playButton];
    [self.navigableNodes addObject:@[playButton]];

    // leaderboard button
    LabelButton *leaderboardButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            [w_self cleanupControllerHandlers];
            [[NSNotificationCenter defaultCenter] postNotificationName:DISPLAY_LEADERBOARD_REQUEST object:w_self userInfo:nil];
        }
    }];
    leaderboardButton.text = @"High Scores";
    leaderboardButton.fontSize = 20 * nodeScale;
    leaderboardButton.position = CGPointMake(playButton.position.x, midY-((canUseShare ? 10 : 22)*nodeScale));
    [self addChild:leaderboardButton];
    [self.navigableNodes addObject:@[leaderboardButton]];

    if(canUseShare) {
        // tell a friend button
        LabelButton __block *tellFriendButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
            if(w_self) {
                NSString *tellFriendText = [NSString stringWithFormat:@"Check out Pilot Ace for iOS - %@", ITUNES_URL];
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SHARE_SHEET object:w_self userInfo:@{SHARE_TEXT_KEY: tellFriendText, SHARE_RECT_KEY: tellFriendButton}];
            }
        }];
        tellFriendButton.text = @"Tell a Friend";
        tellFriendButton.fontSize = 20 * nodeScale;
        tellFriendButton.position = CGPointMake(playButton.position.x, midY-(50*nodeScale));
        [self addChild:tellFriendButton];
        [self.navigableNodes addObject:@[tellFriendButton]];
    }

    self.selectedNode = playButton;
}

@end
