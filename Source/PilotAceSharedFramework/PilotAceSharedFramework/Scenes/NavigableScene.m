//
//  NavigableScene.m
//  PilotAceSharedFramework
//
//  Created by Sean Kosanovich on 10/21/15.
//  Copyright © 2015 seko. All rights reserved.
//

#import "NavigableScene.h"
#import <GameController/GameController.h>
#import "LabelButton.h"
#import "GameSettingsController.h"
#import "NavigableScene_Protected.h"

typedef struct {
    NSUInteger x;
    NSUInteger y;
} MenuCoordinate;

static const MenuCoordinate MenuCoordinateNull = {
    .x = NSUIntegerMax,
    .y = NSUIntegerMax
};

@interface NavigableScene()
@property (nonatomic, strong) NSDate *lastTimeMenuChanged;
@property (nonatomic, assign) CGFloat originalNodeScale;
@end

@implementation NavigableScene

static NSTimeInterval const SECONDS_BETWEEN_MENU_ITEM_CHANGES = 0.3;
static float const VALUE_CHANGE_THRESHOLD = 0.5;

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if(self) {
        _navigableNodes = [NSMutableArray new];
        _lastTimeMenuChanged = [NSDate date];

        NavigableScene * __weak w_self = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:GAME_CONTROLLER_CONNECTED_NOTIFICATION object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [w_self setupController: [GameSettingsController sharedInstance].controller];
        }];

        [[NSNotificationCenter defaultCenter] addObserverForName:ALERT_CONTROLLER_DISMISSED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [w_self setupController: [GameSettingsController sharedInstance].controller];
        }];
    }
    
    return self;
}

- (void)willMoveFromView:(SKView *)view {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super willMoveFromView:view];
}

- (void)didMoveToView:(SKView *)view {
    if([GameSettingsController sharedInstance].controller) {
        [self setupController:[GameSettingsController sharedInstance].controller];
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

- (MenuCoordinate)getCoordinateForMenuItem:(SKNode<ActionableNode> *)menuItem {
    NSUInteger currY = 0;
    for (NSArray<SKNode<ActionableNode> *> *subArray in self.navigableNodes) {
        NSUInteger x = [subArray indexOfObject:menuItem];
        if(x != NSNotFound) {
            MenuCoordinate coordinate;
            coordinate.x = x;
            coordinate.y = currY;
            return coordinate;
        }

        currY++;
    }

    return MenuCoordinateNull;
}

- (void)cleanupControllerHandlers {
    GCController *controller = [GameSettingsController sharedInstance].controller;

    // all extended controllers also support gamepad, ignore extended
    if (controller && controller.extendedGamepad) {
        [controller.extendedGamepad.buttonX setPressedChangedHandler:NULL];
        [controller.extendedGamepad.buttonA setPressedChangedHandler:NULL];
        [controller.extendedGamepad.dpad setValueChangedHandler:NULL];
        [controller.extendedGamepad.buttonMenu setValueChangedHandler:NULL];
    }

    if (controller && controller.microGamepad) {
        [controller.microGamepad.buttonX setPressedChangedHandler:NULL];
        [controller.microGamepad.buttonA setPressedChangedHandler:NULL];
        [controller.microGamepad.dpad setValueChangedHandler:NULL];
        [controller.microGamepad.buttonMenu setValueChangedHandler:NULL];
    }

    if (controller && controller.extendedGamepad) {
        [controller.extendedGamepad.leftThumbstick setValueChangedHandler:NULL];
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
    MenuCoordinate currCoordinate = [self getCoordinateForMenuItem:self.selectedNode];
    if(currCoordinate.x == MenuCoordinateNull.x) {
        // not found -- should not happen
        return;
    }

    float yChange = fabsf(yValue);
    float xChange = fabsf(xValue);
    if(yChange >= xChange && [self shouldChangeSelectedNode:yChange]) {
        // move selected item up/down
        if(yValue > 0) {
            // scroll up
            NSUInteger currYIdx = currCoordinate.y;
            NSUInteger newYIdx;
            if(currYIdx > 0) {
                // there is something above, move towards the front of the array
                newYIdx = currYIdx - 1;
            } else {
                // we are at the top of the menu items, loop back to the last element
                newYIdx = self.navigableNodes.count - 1;
            }

            self.selectedNode = self.navigableNodes[newYIdx][currCoordinate.x];
        } else if (yValue < 0) {
            // scroll down
            NSUInteger currYIdx = currCoordinate.y;
            NSUInteger newYIdx;
            if(currYIdx < self.navigableNodes.count-1) {
                // there is something below, move towards the end of the array
                newYIdx = currYIdx + 1;
            } else {
                // we are at the end of the array, loop back to the first element
                newYIdx = 0;
            }

            self.selectedNode = self.navigableNodes[newYIdx][currCoordinate.x];
        }
    } else if([self shouldChangeSelectedNode:xChange] && self.navigableNodes[0].count > 0){
        // move selected left/right (only if there is a left/right option
        if(xValue > 0) {
            // scroll right
            NSUInteger currYIdx = currCoordinate.y;
            NSUInteger currXIdx = currCoordinate.x;
            NSUInteger newXIdx;
            if(currXIdx < self.navigableNodes[currYIdx].count-1) {
                // there is something to the right, move towards the end of the array
                newXIdx = currXIdx + 1;
            } else {
                // we are at the end of the array, move down and over
                newXIdx = 0;
            }

            self.selectedNode = self.navigableNodes[currYIdx][newXIdx];
        } else if (xValue < 0) {
            // scroll left
            NSUInteger currYIdx = currCoordinate.y;
            NSUInteger currXIdx = currCoordinate.x;
            NSUInteger newXIdx;
            if(currXIdx > 0) {
                // there is something to the left, move towards the front of the array
                newXIdx = currXIdx - 1;
            } else {
                // we are at the front of the array, move to the end and up
                newXIdx = self.navigableNodes[currYIdx].count-1;
            }

            self.selectedNode = self.navigableNodes[currYIdx][newXIdx];
        }
    }
}

- (void)setupController:(GCController *)controller {
    NavigableScene * __weak w_self = self;

    // handles gamepad or extended gamepad (all extended gamepads support gamepad)
    if (controller.extendedGamepad) {
        [controller.extendedGamepad.buttonX setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonXChanged:button withValue:value isPressed:pressed];
        }];

        [controller.extendedGamepad.buttonA setPressedChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            [w_self buttonAChanged:button withValue:value isPressed:pressed];
        }];

        [controller.extendedGamepad.dpad setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            [w_self dpadChanged:dpad withXValue:xValue withYValue:yValue];
        }];
    } else if (controller.microGamepad) {
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

    
    if (controller.extendedGamepad) {
        [controller.extendedGamepad.leftThumbstick setValueChangedHandler:^(GCControllerDirectionPad *joystick, float xValue, float yValue) {
            [w_self dpadChanged:joystick withXValue:xValue withYValue:yValue];
        }];
    }
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
        SKAction *scale = [SKAction scaleTo:self.originalNodeScale duration:SECONDS_BETWEEN_MENU_ITEM_CHANGES];
        [_selectedNode runAction:scale];
    }

    _selectedNode = selectedNode;
    self.originalNodeScale = _selectedNode.yScale;

    // only scale up if we must use a controller or are using one already
    if([GameSettingsController sharedInstance].mustUseController || [GameSettingsController sharedInstance].controller) {
        SKAction *scale = [SKAction scaleTo:self.originalNodeScale * 1.5 duration:SECONDS_BETWEEN_MENU_ITEM_CHANGES];
        [_selectedNode runAction:scale];
    }
}

@end
