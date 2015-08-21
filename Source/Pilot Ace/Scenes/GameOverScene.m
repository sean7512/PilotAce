//
//  GameOverScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "GameOverScene.h"
#import "PilotAceAppDelegate.h"
#import "PlaneChooserScene.h"
#import "LabelButton.h"
#import "DayTimeSceneData.h"
#import "PilotAceAppDelegate.h"
#import "GameCenterController.h"
#import "DistanceUtils.h"
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "DifficultyLevel.h"
#import "SettingsScene.h"
#import "ViewController.h"

@interface GameOverScene()

@property (strong, nonatomic, readonly) DifficultyLevel *difficultyLevel;

@end

@implementation GameOverScene

static NSString *const HIGHSCORE_SOUND = @"game_over_highscore.caf";
static NSString *const NO_HIGHSCORE_SOUND = @"game_over_no_highscore.caf";

static SKAction *_highscoreSoundAction;
static SKAction *_noHighscoreSoundAction;

- (id)initWithSize:(CGSize)size forDifficulty:(DifficultyLevel *)difficulty {
    if (self = [super initWithSize:size]) {
        _difficultyLevel = difficulty;

        static dispatch_once_t loadGameOverSoundsOnce;
        dispatch_once(&loadGameOverSoundsOnce, ^{
            _highscoreSoundAction = [SKAction playSoundFileNamed:HIGHSCORE_SOUND waitForCompletion:NO];
            _noHighscoreSoundAction = [SKAction playSoundFileNamed:NO_HIGHSCORE_SOUND waitForCompletion:NO];
        });
    }

    return self;
}

+ (id)createWithSize:(CGSize)size withDistanceTraveled:(int64_t)distanceKm forDifficulty:(DifficultyLevel *)difficulty {
    GameOverScene *gameOver = [[GameOverScene alloc] initWithSize:size forDifficulty:difficulty];
    [gameOver populateInitialScreenWithDistanceTraveled:distanceKm];
    return gameOver;
}

- (void)populateInitialScreenWithDistanceTraveled:(int64_t)distanceKm {
    self.physicsWorld.gravity = CGVectorMake(0, 0);

    [SceneTimeOfDayFactory setUpScene:self forTimeOfDayData:[DayTimeSceneData sharedInstance] withMovement:NO];

    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    int64_t highscore = [appDelegate recordScore:distanceKm forDifficultyLevel:self.difficultyLevel];
    CGFloat nodeScale = [appDelegate getNodeScale];

    CGFloat midX = CGRectGetMidX(self.frame);
    CGFloat midY = CGRectGetMidY(self.frame);

    // settings
    GameOverScene * __weak w_self = self;
    LabelButton *settingsButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.7];
            SettingsScene *settings = [SettingsScene createWithSize:w_self.frame.size withBackScene:w_self withBackTitle:@"Game Over"];
            [w_self.scene.view presentScene: settings transition: reveal];
        }
    }];
    settingsButton.text = @"Settings";
    settingsButton.fontSize = 15 * nodeScale;
    settingsButton.position = CGPointMake(self.frame.size.width - settingsButton.frame.size.width/2 -20*nodeScale, self.frame.size.height - settingsButton.frame.size.height/2 - 20*nodeScale);
    [self addChild:settingsButton];

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

    if((![appDelegate isOtherAudioPlaying]) && [appDelegate isGameMusicEnabled] && gameOverSoundAction) {
        [self runAction:gameOverSoundAction];
    }

    LabelButton *playButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKTransition *reveal = [SKTransition doorsOpenHorizontalWithDuration:0.7];
            PlaneChooserScene *planeChooser = [PlaneChooserScene createWithSize:w_self.frame.size];
            [w_self.scene.view presentScene:planeChooser transition: reveal];
        }
    }];
    playButton.text = @"Replay";
    playButton.fontSize = 20*nodeScale;
    playButton.position = CGPointMake(midX - playButton.frame.size.width*2, midY + (30*nodeScale));
    [self addChild:playButton];

    LabelButton *leaderboardButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DISPLAY_LEADERBOARD_REQUEST object:w_self userInfo:nil];
        }
    }];
    leaderboardButton.text = @"High Scores";
    leaderboardButton.fontSize = 20*nodeScale;
    leaderboardButton.position = CGPointMake(playButton.position.x, midY - (10*nodeScale));
    [self addChild:leaderboardButton];

    // share score button
    LabelButton *shareScoreButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            if(w_self) {
                NSString *tellFriendText = [NSString stringWithFormat:@"I just flew %.3f km in Pilot Ace. Can you beat me? %@", [DistanceUtils getFloatScore:distanceKm], ITUNES_URL];
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SHARE_SHEET object:w_self userInfo:@{SHARE_TEXT_KEY: tellFriendText}];
            }
        }
    }];
    shareScoreButton.text = @"Share Score";
    shareScoreButton.fontSize = 20 * nodeScale;
    shareScoreButton.position = CGPointMake(playButton.position.x, midY-(50*nodeScale));
    [self addChild:shareScoreButton];
}

@end
