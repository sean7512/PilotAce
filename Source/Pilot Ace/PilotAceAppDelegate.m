//
//  AppDelegate.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/13/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <PilotAceSharedFramework/PilotAceSharedFramework.h>
#import <AVFoundation/AVFoundation.h>
#import "PilotAceAppDelegate.h"
#import "ViewController.h"

@interface PilotAceAppDelegate() <NodeScaleSizeDelegate, SocialShareDelegate>
@end

@implementation PilotAceAppDelegate

static CGFloat const IPAD_NODE_SCALE = 2.2;
static CGFloat const IPONE_NODE_SCALE = 1;
static CGFloat nodeScale;

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

- (void)resumeGame {
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    [viewController resumeGame];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)pauseGame {
    ViewController *viewController = (ViewController *)self.window.rootViewController;
    [viewController pauseGame];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[GameCenterController sharedInstance] cleanup];
    [[GameSettingsController sharedInstance] cleanup];
}

- (CGFloat)getNodeScaleSize {
    if(!nodeScale) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nodeScale = IPONE_NODE_SCALE;
        } else {
            nodeScale = IPAD_NODE_SCALE;
        }
    }
    return nodeScale;
}

- (BOOL)canUseShare {
    return YES;
}

@end
