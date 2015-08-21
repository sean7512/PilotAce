//
//  PausedScreenNode.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/27/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "PausedScreenNode.h"
#import "PilotAceAppDelegate.h"
#import "FullScreenOverlayNode.h"
#import "LabelButton.h"

@interface PausedScreenNode()

@property (weak, nonatomic) NSObject<PauseGameController> *pauseGameController;

@end

@implementation PausedScreenNode

- (id)initWithPauseGameController:(NSObject<PauseGameController> *)pauseGameController {
    self = [super init];
    if(self) {
        _pauseGameController = pauseGameController;
    }
    return self;
}

+ (id)createForScreenWithSize:(CGSize)size withPauseGameController:(NSObject<PauseGameController> *)pauseGameController {
    PausedScreenNode *indicator = [[PausedScreenNode alloc] initWithPauseGameController:pauseGameController];
    [indicator populateScreenForSize:size];
    return indicator;
}

- (void)populateScreenForSize:(CGSize)size {
    self.userInteractionEnabled = YES;

    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    FullScreenOverlayNode *fullScreenNode = [FullScreenOverlayNode createForSceenWithSize:size];
    [self addChild:fullScreenNode];

    // title
    SKLabelNode *pauseLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    pauseLabel.fontSize = 40 * nodeScale;
    pauseLabel.text = @"Game Paused";
    pauseLabel.position = CGPointMake(size.width/2, (size.height/2) + (20*nodeScale));
    [self addChild:pauseLabel];

    // resume button
    PausedScreenNode * __weak w_self = self;
    LabelButton *resumeButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            // resume game
            [w_self.pauseGameController resumeGame];
        }
    }];
    resumeButton.speed = 1.0;
    resumeButton.fontSize = 20 * nodeScale;
    resumeButton.text = @"Resume";
    resumeButton.zPosition = 100;
    resumeButton.position = CGPointMake(size.width/2, (size.height/2) - (20*nodeScale));
    [self addChild:resumeButton];
}

@end
