//
//  BlackbirdPlane.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/15/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "BlackbirdPlane.h"
#import "GameSettingsController.h"

@implementation BlackbirdPlane

static NSString *const PLANE_IMG = @"Blackbird";

static SKTexture *_blackbirdTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadBlackbirdTextureOnce;
    dispatch_once(&loadBlackbirdTextureOnce, ^{
        UIImage *image = [UIImage imageNamed:PLANE_IMG inBundle:[NSBundle bundleForClass:[BlackbirdPlane class]] compatibleWithTraitCollection:nil];
        _blackbirdTexture = [SKTexture textureWithImage:image];
    });
    BlackbirdPlane *plane = [[BlackbirdPlane alloc] initWithTexture:_blackbirdTexture forDraggable:dragDirection];

    CGFloat offsetX = plane.frame.size.width * plane.anchorPoint.x;
    CGFloat offsetY = plane.frame.size.height * plane.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 24 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 45 - offsetX, 10 - offsetY);
    CGPathAddLineToPoint(path, NULL, 104 - offsetX, 23 - offsetY);
    CGPathAddLineToPoint(path, NULL, 104 - offsetX, 28 - offsetY);
    CGPathAddLineToPoint(path, NULL, 49 - offsetX, 38 - offsetY);
    CGPathAddLineToPoint(path, NULL, 20 - offsetX, 43 - offsetY);
    CGPathAddLineToPoint(path, NULL, 11 - offsetX, 42 - offsetY);
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

@end
