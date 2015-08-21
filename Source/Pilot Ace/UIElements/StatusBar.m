//
//  StatusBar.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "StatusBar.h"
#import "FuelIndicator.h"
#import "PilotAceAppDelegate.h"
#import "LabelButton.h"
#import "DistanceUtils.h"

// must be set to PADDING + INTERNAL_HEIGHT
CGFloat const STATUS_BAR_HEIGHT = 25;

@interface StatusBar()

@property (weak, nonatomic) SKScene<PauseGameController> *scenePauseController;

@property (strong, nonatomic) FuelIndicator *fuelIndicator;
@property (strong, nonatomic) SKLabelNode *distanceLabel;
@property (assign, nonatomic) CGFloat yPosition;
@property (assign, nonatomic) CGFloat baseDistanceXPosition;

@end

@implementation StatusBar

static CGFloat const STATUS_BAR_PADDING = 5;
static CGFloat const STATUS_BAR_INTERNAL_HEIGHT = 20;
static CGFloat const STATUS_BAR_FONT_SIZE = 15;

static NSString *const DISTANCE_FORMAT_STRING = @"Distance: %.3f km";

- (id)initWithPauseSceneController:(SKScene<PauseGameController> *)scene {
    self = [super init];
    if(self) {
        _scenePauseController = scene;
    }
    return self;
}

+ (id)createWithPauseSceneController:(SKScene<PauseGameController> *)scene {
    StatusBar *bar = [[StatusBar alloc] initWithPauseSceneController:scene];
    [bar populateStatusBar];
    return bar;
}

- (void)populateStatusBar {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    self.yPosition = self.frame.size.height - (STATUS_BAR_INTERNAL_HEIGHT*nodeScale);

    // fuel static label - far left
    SKLabelNode *fuelLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    fuelLabel.fontSize = STATUS_BAR_FONT_SIZE*nodeScale;
    fuelLabel.text = @"Fuel:";
    fuelLabel.position = CGPointMake(STATUS_BAR_PADDING*nodeScale + (fuelLabel.frame.size.width/2), self.yPosition);
    [self addChild:fuelLabel];

    // fuel dynamic indicator - next to static fuel label
    self.fuelIndicator = [FuelIndicator create];
    self.fuelIndicator.position = CGPointMake(fuelLabel.position.x + (fuelLabel.frame.size.width/2) + STATUS_BAR_PADDING*nodeScale, self.yPosition);
    [self addChild:self.fuelIndicator];

    // pause button - far right
    StatusBar * __weak w_self = self;
    LabelButton *pauseButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            // pause game
            [w_self.scenePauseController pauseGamePlayingSound:YES];
        }
    }];
    pauseButton.fontSize = STATUS_BAR_FONT_SIZE*nodeScale;
    pauseButton.text = @"  | |  ";
    pauseButton.position = CGPointMake(self.scenePauseController.frame.size.width - pauseButton.frame.size.width/2 - STATUS_BAR_PADDING*nodeScale, self.yPosition);
    [self addChild:pauseButton];

    // find center of status bar empty space
    CGFloat endOfIndicator = self.fuelIndicator.position.x + (self.fuelIndicator.frame.size.width/2);
    CGFloat startOfPause =  pauseButton.position.x - (pauseButton.frame.size.width/2);
    self.baseDistanceXPosition = ((startOfPause - endOfIndicator)/2) + STATUS_BAR_PADDING*nodeScale;

    // distance dynamic label - center of remaining space
    self.distanceLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    self.distanceLabel.fontSize = STATUS_BAR_FONT_SIZE*nodeScale;
    self.distanceLabel.text = [self getDistanceLabelForDistance:0];
    self.distanceLabel.position = CGPointMake(self.baseDistanceXPosition + (self.distanceLabel.frame.size.width/2), self.yPosition);
    [self addChild:self.distanceLabel];
}

- (void)updateWithFuelPercent:(float)fuelPercent withDistance:(int64_t)distanceKm {
    // update fuel indicator
    [self.fuelIndicator setFuelIndicator:fuelPercent];

    // update score
    self.distanceLabel.text = [self getDistanceLabelForDistance:distanceKm];
    self.distanceLabel.position = CGPointMake(self.baseDistanceXPosition + (self.distanceLabel.frame.size.width/2), self.yPosition);
}

- (NSString *)getDistanceLabelForDistance:(int64_t)distanceKm {
    return [NSString stringWithFormat:DISTANCE_FORMAT_STRING, [DistanceUtils getFloatScore:distanceKm]];
}

@end
