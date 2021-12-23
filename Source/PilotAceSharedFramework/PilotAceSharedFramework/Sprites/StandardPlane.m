//
//  StandardPlane.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/12/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "StandardPlane.h"
#import "GameSettingsController.h"

@implementation StandardPlane

static NSString *const PLANE_IMG = @"StandardPlane";

static SKTexture *_standardPlaneTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadStandardPlaneTextureOnce;
    dispatch_once(&loadStandardPlaneTextureOnce, ^{
        UIImage *image = [UIImage imageNamed:PLANE_IMG inBundle:[NSBundle bundleForClass:[StandardPlane class]] compatibleWithTraitCollection:nil];
        _standardPlaneTexture = [SKTexture textureWithImage:image];
    });
    StandardPlane *plane = [[StandardPlane alloc] initWithTexture:_standardPlaneTexture forDraggable:dragDirection];

    CGFloat offsetX = plane.frame.size.width * plane.anchorPoint.x;
    CGFloat offsetY = plane.frame.size.height * plane.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 53 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 5 - offsetY);
    CGPathAddLineToPoint(path, NULL, 7 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 27 - offsetX, 2 - offsetY);
    CGPathAddLineToPoint(path, NULL, 103 - offsetX, 39 - offsetY);
    CGPathAddLineToPoint(path, NULL, 55 - offsetX, 74 - offsetY);
    CGPathAddLineToPoint(path, NULL, 22 - offsetX, 65 - offsetY);
    CGPathCloseSubpath(path);

    [plane setupPhysicsBodyForPath:path];
    CGPathRelease(path);

    return plane;
}

- (CGPoint)getBulletPosition {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return CGPointMake(self.position.x + self.size.width/2, self.position.y - 3*nodeScale);
}

- (CGFloat)getRelativeBulletHeightFromTop {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return (self.size.height/2) + 3*nodeScale;
}

- (CGFloat)getRelativeBulletHeightFromBottom {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return (self.size.height/2) - 3*nodeScale;
}

@end
