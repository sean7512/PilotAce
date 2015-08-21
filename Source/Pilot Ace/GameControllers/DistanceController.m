//
//  ScoreController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "DistanceController.h"
#import "DistanceUtils.h"
#import "PilotAceAppDelegate.h"

@interface DistanceController()

@property (assign, readwrite, nonatomic) int64_t distanceTraveledKm;

@end

@implementation DistanceController

static float const PLANE_MOVE_PIXELS_PER_SECOND = 110;

// scores are based on iTunes Connect format (int64_t with 3 decimal...divide by 1000)
static int64_t const MAX_DISTANCE_KM = 999999999; // 999999.999

// constants used for calculation stay in decimal value
static float const KM_PER_SECOND = 0.34; // Mach 1

- (id)init {
    self = [super init];
    if(self) {
        _distanceTraveledKm = 0;
    }

    return self;
}

- (void)update:(NSTimeInterval)elapsed withSpeedMultiplier:(CGFloat)speed {
    if(self.distanceTraveledKm < MAX_DISTANCE_KM) {
        self.distanceTraveledKm += [DistanceUtils getIntScore:(elapsed * KM_PER_SECOND * speed)];
    }

    if(self.distanceTraveledKm > MAX_DISTANCE_KM) {
        self.distanceTraveledKm = MAX_DISTANCE_KM;
    }
}

+ (NSTimeInterval)determineStationaryObjectDuration:(SKSpriteNode *)node {
    return [DistanceController determineStationaryObjectDurationFromPositionX:node.position.x withWidth:node.size.width];
}

+ (NSTimeInterval)determineStationaryObjectDurationFromPositionX:(CGFloat)xPos withWidth:(CGFloat)width {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];

    // have to move all of x plus half the width
    CGFloat pixelsToMove = xPos + (width/2);

    // stationary object scrolls at planes speed
    NSTimeInterval duration = pixelsToMove / (PLANE_MOVE_PIXELS_PER_SECOND * [appDelegate getNodeScale]);
    return duration;
}

+ (NSTimeInterval)determineMovingObjectDuration:(SKSpriteNode *)node withAdditionalSpeed:(CGFloat)percentOfPlaneSpeed {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];

    // have to move all of x plus half the width
    CGFloat pixelsToMove = node.position.x + (node.size.width/2);

    // moving objects move at some percent of the plane speed
    NSTimeInterval duration = pixelsToMove / (PLANE_MOVE_PIXELS_PER_SECOND * percentOfPlaneSpeed * [appDelegate getNodeScale]);
    return duration;
}

@end
