//
//  ApacheHelicopter.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 6/6/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "ApacheHelicopter.h"
#import "GameSettingsController.h"

@implementation ApacheHelicopter

static NSString *const HELICOPTER_IMG = @"Apache";

static SKTexture *_apacheTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadApacheTextureOnce;
    dispatch_once(&loadApacheTextureOnce, ^{
        UIImage *image = [UIImage imageNamed:HELICOPTER_IMG inBundle:[NSBundle bundleForClass:[ApacheHelicopter class]] compatibleWithTraitCollection:nil];
        _apacheTexture = [SKTexture textureWithImage:image];
    });
    ApacheHelicopter *heli = [[ApacheHelicopter alloc] initWithTexture:_apacheTexture forDraggable:dragDirection];

    CGFloat offsetX = heli.frame.size.width * heli.anchorPoint.x;
    CGFloat offsetY = heli.frame.size.height * heli.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 48 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 29 - offsetY);
    CGPathAddLineToPoint(path, NULL, 82 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 99 - offsetX, 6 - offsetY);
    CGPathAddLineToPoint(path, NULL, 114 - offsetX, 20 - offsetY);
    CGPathAddLineToPoint(path, NULL, 53 - offsetX, 41 - offsetY);
    CGPathAddLineToPoint(path, NULL, 12 - offsetX, 48 - offsetY);
    CGPathCloseSubpath(path);

    [heli setupPhysicsBodyForPath:path];
    CGPathRelease(path);

    return heli;
}

- (CGPoint)getBulletPosition {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return CGPointMake(self.position.x + 20*nodeScale, self.position.y - 28*nodeScale);
}

- (CGFloat)getRelativeBulletHeightFromTop {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return (self.size.height/2) + 28*nodeScale;
}

- (CGFloat)getRelativeBulletHeightFromBottom {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return (self.size.height/2) - 28*nodeScale;
}

@end
