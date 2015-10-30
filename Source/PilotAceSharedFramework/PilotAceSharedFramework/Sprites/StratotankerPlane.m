//
//  StratotankerPlae.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/4/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "StratotankerPlane.h"
#import "GameSettingsController.h"

static NSString *const PLANE_IMG = @"Stratotanker";

@implementation StratotankerPlane

static double const STRATOTANKER_FUEL_LOSS_PER_SECIND = 2;
static double const STRATOTANKER_GAINED_COLLECTION = 6.4;

static SKTexture *_stratotankerTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadStratTextureOnce;
    dispatch_once(&loadStratTextureOnce, ^{
        UIImage *image = [UIImage imageNamed:PLANE_IMG inBundle:[NSBundle bundleForClass:[StratotankerPlane class]] compatibleWithTraitCollection:nil];
        _stratotankerTexture = [SKTexture textureWithImage:image];
    });
    StratotankerPlane *plane = [[StratotankerPlane alloc] initWithTexture:_stratotankerTexture forDraggable:dragDirection];

    CGFloat offsetX = plane.frame.size.width * plane.anchorPoint.x;
    CGFloat offsetY = plane.frame.size.height * plane.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 1 - offsetX, 71 - offsetY);
    CGPathAddLineToPoint(path, NULL, 4 - offsetX, 38 - offsetY);
    CGPathAddLineToPoint(path, NULL, 53 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 65 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 85 - offsetX, 6 - offsetY);
    CGPathAddLineToPoint(path, NULL, 118 - offsetX, 39 - offsetY);
    CGPathAddLineToPoint(path, NULL, 120 - offsetX, 45 - offsetY);
    CGPathAddLineToPoint(path, NULL, 111 - offsetX, 53 - offsetY);
    CGPathAddLineToPoint(path, NULL, 50 - offsetX, 74 - offsetY);
    CGPathCloseSubpath(path);

    [plane setupPhysicsBodyForPath:path];
    CGPathRelease(path);

    return plane;
}

- (CGPoint)getBulletPosition {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return CGPointMake(self.position.x + self.size.width/2, self.position.y - 1*nodeScale);
}

- (CGFloat)getRelativeBulletHeightFromTop {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return (self.size.height/2) + 1*nodeScale;
}

- (CGFloat)getRelativeBulletHeightFromBottom {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return (self.size.height/2) - 1*nodeScale;
}

- (double)getFuelLossPerSecond {
    return STRATOTANKER_FUEL_LOSS_PER_SECIND;
}

- (double)getFuelGainPerCollection {
    return STRATOTANKER_GAINED_COLLECTION;
}

@end
