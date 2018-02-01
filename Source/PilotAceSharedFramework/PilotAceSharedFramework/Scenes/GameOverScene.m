//
//  GameOverScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "GameOverScene.h"
#import "GameSettingsController.h"
#import "PlaneChooserScene.h"
#import "LabelButton.h"
#import "DayTimeSceneData.h"
#import "GameCenterController.h"
#import "DistanceUtils.h"
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "DifficultyLevel.h"
#import "SettingsScene.h"
#import "NavigableScene_Protected.h"

@interface GameOverScene()

@property (strong, nonatomic, readonly) DifficultyLevel *difficultyLevel;
@property (assign, nonatomic, readonly) CGFloat sideInset;

@end

@implementation GameOverScene

static NSString *const HIGHSCORE_SOUND = @"game_over_highscore.caf";
static NSString *const NO_HIGHSCORE_SOUND = @"game_over_no_highscore.caf";

static SKAction *_highscoreSoundAction;
static SKAction *_noHighscoreSoundAction;

- (id)initWithSize:(CGSize)size withSideInsets:(CGFloat)inset forDifficulty:(DifficultyLevel *)difficulty {
    if (self = [super initWithSize:size]) {
        _difficultyLevel = difficulty;
        _sideInset = inset;

        static dispatch_once_t loadGameOverSoundsOnce;
        dispatch_once(&loadGameOverSoundsOnce, ^{
            _highscoreSoundAction = [SKAction playSoundFileNamed:HIGHSCORE_SOUND waitForCompletion:NO];
            _noHighscoreSoundAction = [SKAction playSoundFileNamed:NO_HIGHSCORE_SOUND waitForCompletion:NO];
        });
    }

    return self;
}

+ (id)createWithSize:(CGSize)size withSideInsets:(CGFloat)inset withDistanceTraveled:(int64_t)distanceKm forDifficulty:(DifficultyLevel *)difficulty {
    GameOverScene *gameOver = [[GameOverScene alloc] initWithSize:size withSideInsets:inset forDifficulty:difficulty];
    [gameOver populateInitialScreenWithDistanceTraveled:distanceKm];
    return gameOver;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    [[GameSettingsController sharedInstance].menuHandlerDelegate setUseNativeMenuHandling:YES];
}

- (void)populateInitialScreenWithDistanceTraveled:(int64_t)distanceKm {
    self.physicsWorld.gravity = CGVectorMake(0, 0);

    [SceneTimeOfDayFactory setUpScene:self forTimeOfDayData:[DayTimeSceneData sharedInstance] withMovement:NO];

    int64_t highscore = [[GameSettingsController sharedInstance] recordScore:distanceKm forDifficultyLevel:self.difficultyLevel];
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    CGFloat midX = CGRectGetMidX(self.frame);
    CGFloat midY = CGRectGetMidY(self.frame);

    GameOverScene * __weak w_self = self;

    // settings
    LabelButton *settingsButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            [w_self cleanupControllerHandlers];
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.7];
            SettingsScene *settings = [SettingsScene createWithSize:w_self.frame.size withBackScene:w_self withBackTitle:@"Game Over"];
            [w_self.scene.view presentScene: settings transition: reveal];
        }
    }];
    settingsButton.text = @"Settings";
    settingsButton.fontSize = 15 * nodeScale;
    settingsButton.position = CGPointMake(self.frame.size.width - settingsButton.frame.size.width/2 -20*nodeScale, self.frame.size.height - settingsButton.frame.size.height/2 - 20*nodeScale);
    [self addChild:settingsButton];
    [self.navigableNodes addObject:@[settingsButton]];

    SKLabelNode *gameOver = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    gameOver.text = @"Game Over";
    gameOver.fontSize = 50*nodeScale;
    gameOver.position = CGPointMake(midX, self.frame.size.height - (75*nodeScale));
    [self addChild:gameOver];

    SKLabelNode *distanceLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    distanceLabel.text = [NSString stringWithFormat:@"Distance: %.3f km", [DistanceUtils getFloatScore:distanceKm]];
    distanceLabel.fontSize = 15*nodeScale;
    distanceLabel.position = CGPointMake(midX + distanceLabel.frame.size.width/1.5, midY + (10*nodeScale));
    [self addChild:distanceLabel];

    SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    highScoreLabel.text = [NSString stringWithFormat:@"Highscore: %.3f km", [DistanceUtils getFloatScore:highscore]];
    highScoreLabel.fontSize = 15*nodeScale;
    highScoreLabel.position = CGPointMake(distanceLabel.position.x, midY - (30*nodeScale));
    [self addChild:highScoreLabel];

    SKAction *gameOverSoundAction = _noHighscoreSoundAction;
    if(distanceKm == highscore) {
        // this was a new highscore
        SKLabelNode *newLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        newLabel.text = @"NEW";
        newLabel.fontColor = [SKColor redColor];
        newLabel.fontSize = 15*nodeScale;
        newLabel.position = CGPointMake(highScoreLabel.position.x - highScoreLabel.frame.size.width/2 - newLabel.frame.size.width/2 - (5*nodeScale), highScoreLabel.position.y);
        [self addChild:newLabel];
        gameOverSoundAction = _highscoreSoundAction;

        SKAction *zoomInAction = [SKAction scaleBy:1.5 duration:0.5];
        SKAction *zoomOutAction = [SKAction scaleTo:1 duration:0.5];
        SKAction *repeatZoom = [SKAction repeatActionForever:[SKAction sequence:@[zoomInAction, zoomOutAction]]];
        [newLabel runAction:repeatZoom];
    }

    if((![[GameSettingsController sharedInstance] isOtherAudioPlaying]) && [[GameSettingsController sharedInstance] isGameMusicEnabled] && gameOverSoundAction) {
        [self runAction:gameOverSoundAction];
    }

    BOOL showsShareOption = [[GameSettingsController sharedInstance].shareDelegate canUseShare];

    LabelButton *playButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            [w_self cleanupControllerHandlers];
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.7];
            PlaneChooserScene *planeChooser = [PlaneChooserScene createWithSize:w_self.frame.size withSideInsets:self.sideInset withPreviousScene:w_self];
            [w_self.scene.view presentScene:planeChooser transition: reveal];
        }
    }];
    playButton.text = @"Replay";
    playButton.fontSize = 20*nodeScale;
    playButton.position = CGPointMake(midX - playButton.frame.size.width*2, (showsShareOption ? (midY + (30*nodeScale)) : distanceLabel.position.y));
    [self addChild:playButton];
    [self.navigableNodes addObject:@[playButton]];

    LabelButton *leaderboardButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            [w_self cleanupControllerHandlers];
            [[NSNotificationCenter defaultCenter] postNotificationName:DISPLAY_LEADERBOARD_REQUEST object:w_self userInfo:nil];
        }
    }];
    leaderboardButton.text = @"High Scores";
    leaderboardButton.fontSize = 20*nodeScale;
    leaderboardButton.position = CGPointMake(playButton.position.x, (showsShareOption ? (midY - (10*nodeScale)) : highScoreLabel.position.y));
    [self addChild:leaderboardButton];
    [self.navigableNodes addObject:@[leaderboardButton]];

    if(showsShareOption) {
        // share score button
        LabelButton __block *shareScoreButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
            if(w_self) {
                if(w_self) {
                    NSString *tellFriendText = [NSString stringWithFormat:@"I just flew %.3f km in Pilot Ace. Can you beat me? %@", [DistanceUtils getFloatScore:distanceKm], ITUNES_URL];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SHARE_SHEET object:w_self userInfo:@{SHARE_TEXT_KEY: tellFriendText, SHARE_RECT_KEY: shareScoreButton}];
                }
            }
        }];
        shareScoreButton.text = @"Share Score";
        shareScoreButton.fontSize = 20 * nodeScale;
        shareScoreButton.position = CGPointMake(playButton.position.x, midY-(50*nodeScale));
        [self addChild:shareScoreButton];
        [self.navigableNodes addObject:@[shareScoreButton]];
    }

    self.selectedNode = playButton;
}

@end
