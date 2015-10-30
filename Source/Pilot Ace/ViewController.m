//
//  ViewController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Social/Social.h>
#import <PilotAceSharedFramework/PilotAceSharedFramework.h>
#import "ViewController.h"

@interface ViewController() <AlertControllerPresenter, MenuHandler>

@property (strong, nonatomic) AVAudioPlayer *themeMusicPlayer;

@end

@implementation ViewController

static NSString *const MUSIC_EXTENSION = @"caf";
static NSString *const THEME_MUSIC_FILE = @"main_theme";

- (void)viewDidLoad {
    [super viewDidLoad];

    // authenticate with GC
    [self authenticateLocalPlayer];

    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGCLeaderboard:) name:DISPLAY_LEADERBOARD_REQUEST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameStarting:) name:GAME_STARTING_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameMusicSettingChanged:) name:GAME_MUSIC_SETTING_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareText:) name:SHOW_SHARE_SHEET object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    // Configure the view.
    SKView * skView = (SKView *)self.view;

    // only do once...
    if(!skView.scene) {
        skView.showsFields = NO;
        skView.showsFPS = NO;
        skView.showsNodeCount = NO;
        skView.showsPhysics = NO;

        [GameSettingsController sharedInstance].alertDelegate = self;
        [GameSettingsController sharedInstance].menuHandlerDelegate = self;

        // theme music
        NSError *error;
        NSURL *backgroundMusicURL = [[NSBundle bundleForClass:[MainMenuScene class]] URLForResource:THEME_MUSIC_FILE withExtension:MUSIC_EXTENSION];
        self.themeMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        if(!self.themeMusicPlayer) {
            NSLog(@"An error occurred while laoding the theme music: %@", error);
        } else {
            self.themeMusicPlayer.numberOfLoops = -1;
            [self playThemeMusic];
        }

        // Create and configure the scene.
        SKScene * scene = [MainMenuScene createWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;

        // Present the scene.
        [skView presentScene:scene];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // only support landscape in both ipad and iphone
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pauseGame {
    SKView *skView = (SKView *)self.view;
    SKScene *scene = skView.scene;
    if([scene conformsToProtocol:@protocol(PauseGameController)]) {
        SKScene<PauseGameController> *pauseScene = (SKScene<PauseGameController> *)scene;
        [pauseScene pauseGame];
    }

    if(self.themeMusicPlayer) {
        [self.themeMusicPlayer stop];
    }

    // always pause the view
    skView.paused = YES;
}

- (void)resumeGame {
    SKView *skView = (SKView *)self.view;
    skView.paused = NO;
    [self playThemeMusic];
}

- (void)playThemeMusic {
    GameSettingsController *gameSettings = [GameSettingsController sharedInstance];
    if((![gameSettings isOtherAudioPlaying]) && [gameSettings isGameMusicEnabled] && self.themeMusicPlayer) {
        [self.themeMusicPlayer play];
    }
}

- (void)stopThemeMusic {
    if(self.themeMusicPlayer && [self.themeMusicPlayer isPlaying]) {
        [self.themeMusicPlayer stop];
    }
}

- (void)gameMusicSettingChanged:(NSNotification *)notification {
    NSNumber *gameMusicEnabledNum = notification.userInfo[GAME_MUSIC_SETTING_KEY];
    if([gameMusicEnabledNum boolValue]) {
        [self playThemeMusic];
    } else {
        [self stopThemeMusic];
    }
}

- (void)gameStarting:(NSNotification *)notification {
    if(self.themeMusicPlayer) {
        [self fadeThemeMusic];
    }
}

- (void)fadeThemeMusic {
    if(self.themeMusicPlayer && [self.themeMusicPlayer isPlaying]) {
        if (self.themeMusicPlayer.volume > 0) {
            self.themeMusicPlayer.volume -= 0.2;
            [self performSelector:@selector(fadeThemeMusic) withObject:nil afterDelay:0.1];
        } else {
            // get rid of theme music - it isn't used after the 1st game is played
            [self.themeMusicPlayer stop];
            self.themeMusicPlayer = nil;
        }
    } else {
        self.themeMusicPlayer = nil;
    }
}

- (void)setUseNativeMenuHandling:(BOOL)useNativeMenuHandling {
    // do nothing
}

- (void)shareText:(NSNotification *)notification {
    NSString *shareText = notification.userInfo[SHARE_TEXT_KEY];
    SKNode *popOverLocation = (notification.userInfo[SHARE_RECT_KEY]);
    UIImage *img = [UIImage imageNamed:@"iTunesArtwork"];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText, img] applicationActivities:nil];
    if(activityVC.popoverPresentationController) {
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = popOverLocation.frame;
    }
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - GameKit Code

- (void) authenticateLocalPlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

    ViewController * __weak w_self = self;
    GKLocalPlayer * __weak w_localPlayer = localPlayer;
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if(!w_self || !w_localPlayer) {
            return;
        }

        if (viewController != nil) {
            // show login screen
            [w_self pauseGame];
            [w_self presentViewController:viewController animated:YES completion:NULL];
        } else if (w_localPlayer.isAuthenticated) {
            [w_self resumeGame];
            [[NSNotificationCenter defaultCenter] postNotificationName:GAME_CENTER_LOCAL_PLAYER_AUTHENTICATED object:w_self userInfo:@{GAME_CENTER_LOCAL_PLAYER_ID: w_localPlayer}];
        } else {
            // no gamecenter here, just resume game that was paused when the login screen was shown
            [w_self resumeGame];
        }
    };
}

- (void)showGCLeaderboard:(NSNotification *)notification {
    if(![GKLocalPlayer localPlayer].isAuthenticated) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Signed In" message:@"You need to sign in to Game Center to view the Leaderboards. Please sign in and try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // nothing to do
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [[GameCenterController sharedInstance] displayLeaderBoardWithViewController:self];
}

- (void)presentAlertController:(UIAlertController *)alertViewController {
    [self presentViewController:alertViewController animated:YES completion:nil];
}

@end
