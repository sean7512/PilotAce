//
//  AirplaneController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/20/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "AirplaneController.h"
#import "Airplane.h"
#import "GameSettingsController.h"

@interface AirplaneController()

@property (weak, nonatomic) SKScene<GameOverListener, SceneInsetProvider> *sceneGameOverListener;
@property (strong, nonatomic) Airplane *plane;
@property (assign, nonatomic) CGFloat bulletMaxHeight;
@property (assign, nonatomic) CGFloat bulletMinHeight;

@end

@implementation AirplaneController

static CGFloat const MAX_MIN_HEIGHT_NOT_SET = -1;

- (id)initWithScene:(SKScene<GameOverListener, SceneInsetProvider> *)scene withPlane:(Airplane *)plane withPlaneXPos:(CGFloat)xPos {
    self = [super init];
    if(self) {
        CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

        _sceneGameOverListener = scene;
        _bulletMaxHeight = MAX_MIN_HEIGHT_NOT_SET;
        _bulletMinHeight = MAX_MIN_HEIGHT_NOT_SET;

        _plane = plane;
        _plane.topInset = [scene getTopInset];
        _plane.bottomInset = [scene getBottomInset];
        [_plane setScale:nodeScale];
        _plane.position = CGPointMake(xPos, CGRectGetMidY(scene.frame));
        [scene addChild:_plane];
    }

    return self;
}

- (void)update:(NSTimeInterval)elapsedTime withSpeedMultiplier:(CGFloat)speed {
    if([self.plane calculateFuelLoss:elapsedTime withSpeedMultiplier:speed]) {
        // plane fuel is empty
        [self.plane noseDive];
    }
}

- (CGPoint)getPlanePosition {
    return self.plane.position;
}

- (CGFloat)getPlaneFuelTankPercentFull {
    return [self.plane getFuelTankFillPercent];
}

- (void)receivedFuel {
    [self.plane receivedFuel];
}

- (CGPoint)getPlaneBulletPosition {
    return [self.plane getBulletPosition];
}

- (CGFloat)getPlaneBulletMaxHeight {
    if(self.bulletMaxHeight == MAX_MIN_HEIGHT_NOT_SET) {
        self.bulletMaxHeight = self.sceneGameOverListener.frame.size.height - [self.sceneGameOverListener getTopInset] - [self.plane getRelativeBulletHeightFromTop];
    }
    return self.bulletMaxHeight;
}

- (CGFloat)getPlaneBulletMinHeight {
    if(self.bulletMinHeight == MAX_MIN_HEIGHT_NOT_SET) {
        self.bulletMinHeight = [self.sceneGameOverListener getBottomInset] + [self.plane getRelativeBulletHeightFromBottom];
    }
    return self.bulletMinHeight;
}

- (BOOL)didPlaneNosedive {
    return self.plane.didNoseDive;
}

- (void)movePlaneToY:(CGFloat)yPos {
    CGFloat adjustedY = yPos;
    CGFloat maxY = self.sceneGameOverListener.size.height - (self.plane.size.height/2) - self.plane.topInset;
    CGFloat minY = (self.plane.size.height/2) + self.plane.bottomInset + 5;

    if(adjustedY > maxY) {
        adjustedY = maxY;
    }
    if(adjustedY < minY) {
        adjustedY = minY;
    }

    self.plane.position = CGPointMake(self.plane.position.x, adjustedY);
}

@end
