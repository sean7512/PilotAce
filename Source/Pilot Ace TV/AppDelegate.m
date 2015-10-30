//
//  AppDelegate.m
//  Pilot Ace TV
//
//  Created by Sean Kosanovich on 10/19/15.
//  Copyright © 2015 Sean Kosanovich. All rights reserved.
//

#import "AppDelegate.h"
#import <SpriteKit/SpriteKit.h>
#import <PilotAceSharedFrameworkTVOS/PilotAceSharedFrameworkTVOS.h>
#import <AVFoundation/AVFoundation.h>
#import "GameViewController.h"

@interface AppDelegate () <NodeScaleSizeDelegate, SocialShareDelegate>
@end

@implementation AppDelegate

static CGFloat const TV_NODE_SCALE = 2.2;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // initialize the gamecenter controller
    [GameCenterController sharedInstance];

    // register as the delegates
    [GameSettingsController sharedInstance].nodeScaleDelegate = self;
    [GameSettingsController sharedInstance].shareDelegate = self;

    NSError *error = nil;
    if(![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error]) {
        NSLog(@"An error setting the shared audio category: %@", error);
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self pauseGame];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self pauseGame];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self resumeGame];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self resumeGame];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[GameCenterController sharedInstance] cleanup];
    [[GameSettingsController sharedInstance] cleanup];
}

- (void)resumeGame {
    GameViewController *viewController = (GameViewController *)self.window.rootViewController;
    [viewController resumeGame];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)pauseGame {
    GameViewController *viewController = (GameViewController *)self.window.rootViewController;
    [viewController pauseGame];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (CGFloat)getNodeScaleSize {
    return TV_NODE_SCALE;
}

- (BOOL)canUseShare {
    return NO;
}

@end
