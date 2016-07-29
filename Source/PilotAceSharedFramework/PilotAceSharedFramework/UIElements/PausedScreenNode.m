//
//  PausedScreenNode.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/27/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "PausedScreenNode.h"
#import <GameController/GameController.h>
#import "GameSettingsController.h"
#import "FullScreenOverlayNode.h"
#import "LabelButton.h"
#import "ActionableNode.h"

@interface PausedScreenNode()

@property (weak, nonatomic) NSObject<PauseGameController> *pauseGameController;
@property (strong, nonatomic) NSMutableArray<SKNode<ActionableNode> *> *menuItems;
@property (strong, nonatomic) SKNode<ActionableNode> *selectedNode;
@property (nonatomic, strong) NSDate *lastTimeMenuChanged;
@property (nonatomic, assign) CGFloat originalNodeScale;

@end

@implementation PausedScreenNode

static NSTimeInterval const SECONDS_BETWEEN_MENU_ITEM_CHANGES = 0.3;
static float const VALUE_CHANGE_THRESHOLD = 0.5;

- (id)initWithPauseGameController:(NSObject<PauseGameController> *)pauseGameController {
    self = [super init];
    if(self) {
        _pauseGameController = pauseGameController;
        _menuItems = [NSMutableArray new];
        _selectedNode = nil;
        _lastTimeMenuChanged = [NSDate date];
    }
    return self;
}

+ (id)createForScreenWithSize:(CGSize)size withPauseGameController:(NSObject<PauseGameController> *)pauseGameController {
    PausedScreenNode *indicator = [[PausedScreenNode alloc] initWithPauseGameController:pauseGameController];
    [indicator populateScreenForSize:size];
    return indicator;
}

- (void)populateScreenForSize:(CGSize)size {
    BOOL hasController = [GameSettingsController sharedInstance].mustUseController || [GameSettingsController sharedInstance].controller;
    self.userInteractionEnabled = !hasController;

    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    FullScreenOverlayNode *fullScreenNode = [FullScreenOverlayNode createForSceenWithSize:size];
    [self addChild:fullScreenNode];

    // title
    SKLabelNode *pauseLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    pauseLabel.fontSize = 40 * nodeScale;
    pauseLabel.text = @"Game Paused";
    pauseLabel.position = CGPointMake(size.width/2, (size.height/2) + 40*nodeScale);
    [self addChild:pauseLabel];

    // resume button
    PausedScreenNode * __weak w_self = self;
    LabelButton *resumeButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            // resume game
            [w_self cleanupControllerHandlers];
            [w_self.pauseGameController resumeGame];
        }
    }];
    resumeButton.speed = 1.0;
    resumeButton.fontSize = 20 * nodeScale;
    resumeButton.text = @"Resume";
    resumeButton.zPosition = 100;
    resumeButton.position = CGPointMake(size.width/2, (size.height/2));
    resumeButton.userInteractionEnabled = !hasController;
    [self addChild:resumeButton];
    [self.menuItems addObject:resumeButton];
    self.selectedNode = resumeButton;

    // quit game button
    LabelButton *quitButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Are you sure you want to quit the current game?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [w_self setupController];
            }];
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // quit game
                [w_self.pauseGameController quitGame];
            }];
            [alert addAction:yesAction];
            [alert addAction:noAction];

            // let the alert view handle controller input
            [w_self cleanupControllerHandlers];
            [[GameSettingsController sharedInstance].alertDelegate presentAlertController:alert];
        }
    }];
    quitButton.speed = 1.0;
    quitButton.fontSize = 20 * nodeScale;
    quitButton.text = @"Quit Game";
    quitButton.zPosition = 100;
    quitButton.position = CGPointMake(size.width/2, (size.height/2) - (40*nodeScale));
    quitButton.userInteractionEnabled = !hasController;
    [self addChild:quitButton];
    [self.menuItems addObject:quitButton];
}

- (void)cleanupControllerHandlers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    GCController *controller = [GameSettingsController sharedInstance].controller;

    // all extended controllers also support gamepad, ignore extended
    if (controller && controller.gamepad) {
        [controller.gamepad.buttonX setPressedChangedHandler:NULL];
        [controller.gamepad.buttonA setPressedChangedHandler:NULL];
        [controller.gamepad.dpad setValueChangedHandler:NULL];
        [controller setControllerPausedHandler:NULL];
    }
#ifdef TVOS
    else if (controller && controller.microGamepad) {
        [controller.microGamepad.buttonX setPressedChangedHandler:NULL];
        [controller.microGamepad.buttonA setPressedChangedHandler:NULL];
        [controller.microGamepad.dpad setValueChangedHandler:NULL];
        [controller setControllerPausedHandler:NULL];
    }
#endif
    
    if (controller && controller.extendedGamepad) {
        [controller.extendedGamepad.leftThumbstick setValueChangedHandler:NULL];
    }
}

- (void)setupController {
    PausedScreenNode * __weak w_self = self;
    // register for a new controller
    [[NSNotificationCenter defaultCenter] addObserverForName:GAME_CONTROLLER_CONNECTED_NOTIFICATION object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [w_self setupController];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:GAME_CONTROLLER_DISCONNECTED_NOTIFICATION object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // controller was disconnected, ensure we re-enable the label buttons for touch controls

        for(SKNode *node in [w_self children]) {
            if([node isKindOfClass:[LabelButton class]]) {
                node.userInteractionEnabled = YES;
            }
        }
    }];

    GCController *controller = [GameSettingsController sharedInstance].controller;

    if(controller) {
        [controller setControllerPausedHandler:^(GCController * _Nonnull controller) {
            [w_self cleanupControllerHandlers];
            [w_self.pauseGameController resumeGame];
        }];
    }

    // handles gamepad or extended gamepad (all extended gamepads support gamepad)
    if (controller && controller.gamepad) {
        [controller.gamepad.buttonX setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonXChanged:button withValue:value isPressed:pressed];
        }];

        [controller.gamepad.buttonA setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonAChanged:button withValue:value isPressed:pressed];
        }];

        [controller.gamepad.dpad setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            [w_self dpadChanged:dpad withXValue:xValue withYValue:yValue];
        }];
    }
#ifdef TVOS
    // ensure we have a micropad
    else if (controller && controller.microGamepad) {
        controller.microGamepad.reportsAbsoluteDpadValues = NO;

        [controller.microGamepad.buttonX setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonXChanged:button withValue:value isPressed:pressed];
        }];

        [controller.microGamepad.buttonA setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonAChanged:button withValue:value isPressed:pressed];
        }];

        [controller.microGamepad.dpad setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            [w_self dpadChanged:dpad withXValue:xValue withYValue:yValue];
        }];
    }
#endif

    if (controller && controller.extendedGamepad) {
        [controller.extendedGamepad.leftThumbstick setValueChangedHandler:^(GCControllerDirectionPad *joystick, float xValue, float yValue) {
            [w_self dpadChanged:joystick withXValue:xValue withYValue:yValue];
        }];
    }
}

- (void)buttonXChanged:(GCControllerButtonInput *)button withValue:(float)value isPressed:(BOOL)pressed {
    if(pressed && self.selectedNode) {
        [self.selectedNode performAction];
    }
}

- (void)buttonAChanged:(GCControllerButtonInput *)button withValue:(float)value isPressed:(BOOL)pressed {
    if(pressed && self.selectedNode) {
        [self.selectedNode performAction];
    }
}

- (void)dpadChanged:(GCControllerDirectionPad *)dpad withXValue:(float)xValue withYValue:(float)yValue {
    float yChange = fabsf(yValue);
    float xChange = fabsf(xValue);
    if(yChange >= xChange && [self shouldChangeSelectedNode:yChange]) {
        NSUInteger currIdx = [self.menuItems indexOfObject:self.selectedNode];
        NSUInteger newIdx = currIdx;

        // move selected item up/down
        if(yValue > 0) {
            // scroll up
            if(currIdx > 0) {
                // there is something above, move towards the front of the array
                newIdx = currIdx - 1;
            } else {
                // we are at the top of the menu items, loop back to the last element
                newIdx = self.menuItems.count - 1;
            }
        } else if (yValue < 0) {
            // scroll down
            if(currIdx < self.menuItems.count-1) {
                // there is something below, move towards the end of the array
                newIdx = currIdx + 1;
            } else {
                // we are at the end of the array, loop back to the first element
                newIdx = 0;
            }
        }

        self.selectedNode = self.menuItems[newIdx];
    }
}

- (BOOL)shouldChangeSelectedNode:(float)changeValue {
    if(changeValue < VALUE_CHANGE_THRESHOLD || fabs(self.lastTimeMenuChanged.timeIntervalSinceNow) < SECONDS_BETWEEN_MENU_ITEM_CHANGES) {
        // stablize selected node, only move up/down/left/right if a threshold (distance and time) has been met
        return NO;
    }
    self.lastTimeMenuChanged = [NSDate date];
    return YES;
}

- (void)setSelectedNode:(SKNode<ActionableNode> *)selectedNode {
    if(!selectedNode) {
        // bad state to have a button that isn't selected
        return;
    }

    if (selectedNode == _selectedNode) {
        // node is already selected
        return;
    }

    if(_selectedNode) {
        // deselect a previous selected node

        // scale doesn't work since the scene's speed is 0m just set the scale
        _selectedNode.yScale = _selectedNode.xScale = self.originalNodeScale;
    }

    _selectedNode = selectedNode;
    self.originalNodeScale = _selectedNode.yScale;

    // only scale up if we must use a controller or are using one already
    if([GameSettingsController sharedInstance].mustUseController || [GameSettingsController sharedInstance].controller) {
        // scale doesn't work since the scene's speed is 0m just set the scale
        _selectedNode.yScale = _selectedNode.xScale = self.originalNodeScale * 1.5;
    }
}

- (void)removeFromParent {
    self.selectedNode = self.menuItems[0]; // reset selected node
    [super removeFromParent];
}

@end
