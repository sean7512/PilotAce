//
//  FuelIndicator.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "FuelIndicator.h"
#import "PilotAceAppDelegate.h"

@interface FuelIndicator()

@property (strong, nonatomic) SKShapeNode *fuelOutline;
@property (strong, nonatomic) SKShapeNode *fuelFill;
@property (assign, nonatomic) CGFloat nodeScale;

@end

@implementation FuelIndicator

// 100, 1 pixel per percent
static float const INDICATOR_WIDTH = 100;
static float const INDICATOR_HEIGHT = 10;
static float const MAX_PERCENT = 100;
static float const MIN_PERCENT = 0;

- (id) init {
    if (self = [super init]) {
        // nothing to init
    }
    return self;
}

+ (id)create {
    FuelIndicator *indicator = [[FuelIndicator alloc] init];

    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    indicator.nodeScale = [appDelegate getNodeScale];

    indicator.fuelOutline = [SKShapeNode node];

    UIBezierPath *outlinePath = [[UIBezierPath alloc] init];
    [outlinePath moveToPoint:CGPointMake(0, 0)];
    [outlinePath addLineToPoint:CGPointMake(0, INDICATOR_HEIGHT*indicator.nodeScale)];
    [outlinePath addLineToPoint:CGPointMake(INDICATOR_WIDTH*indicator.nodeScale, INDICATOR_HEIGHT*indicator.nodeScale)];
    [outlinePath addLineToPoint:CGPointMake(INDICATOR_WIDTH*indicator.nodeScale, 0)];
    [outlinePath addLineToPoint:CGPointMake(0, 0)];

    indicator.fuelOutline.path = outlinePath.CGPath;
    indicator.fuelOutline.lineWidth = 1;
    indicator.fuelOutline.strokeColor = [SKColor whiteColor];
    indicator.fuelOutline.antialiased = NO;
    [indicator addChild:indicator.fuelOutline];

    indicator.fuelFill = [SKShapeNode node];
    [indicator setFuelIndicator:MAX_PERCENT];
    indicator.fuelFill.lineWidth = 1*indicator.nodeScale;
    indicator.fuelFill.strokeColor = [SKColor whiteColor];
    indicator.fuelFill.antialiased = NO;
    [indicator addChild:indicator.fuelFill];

    return indicator;
}

- (void)setFuelIndicator:(double)percentFull {
    self.fuelFill.path = [self getFillPath:percentFull].CGPath;
    SKColor *fillColor;
    if(percentFull > 80) {
        fillColor = [SKColor greenColor];
    } else if(percentFull > 50) {
        fillColor = [SKColor yellowColor];
    } else if(percentFull > 20) {
        fillColor = [SKColor orangeColor];
    } else {
        fillColor = [SKColor redColor];
    }
    self.fuelFill.fillColor = fillColor;
}

- (UIBezierPath *)getFillPath:(float)percent {
    if(percent < MIN_PERCENT || percent > MAX_PERCENT) {
        percent = MAX_PERCENT;
    }
    UIBezierPath *fillPath = [[UIBezierPath alloc] init];
    [fillPath moveToPoint:CGPointMake(0, 0)];
    [fillPath addLineToPoint:CGPointMake(0, INDICATOR_HEIGHT*self.nodeScale)];
    [fillPath addLineToPoint:CGPointMake(percent*self.nodeScale, INDICATOR_HEIGHT*self.nodeScale)];
    [fillPath addLineToPoint:CGPointMake(percent*self.nodeScale, 0)];
    [fillPath addLineToPoint:CGPointMake(0, 0)];
    return fillPath;
}

- (void)removeFromParent {
    [self.fuelOutline removeFromParent];
    [self.fuelFill removeFromParent];
    self.fuelOutline = nil;
    self.fuelFill = nil;
    [super removeFromParent];
}

@end
