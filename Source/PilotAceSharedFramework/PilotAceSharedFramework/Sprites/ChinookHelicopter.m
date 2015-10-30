//
//  ChinookHelicopter.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 6/6/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "ChinookHelicopter.h"
#import "GameSettingsController.h"

@implementation ChinookHelicopter

static NSString *const HELICOPTER_IMG = @"Chinook";

static SKTexture *_chinookTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadAChinookTextureOnce;
    dispatch_once(&loadAChinookTextureOnce, ^{
        UIImage *image = [UIImage imageNamed:HELICOPTER_IMG inBundle:[NSBundle bundleForClass:[ChinookHelicopter class]] compatibleWithTraitCollection:nil];
        _chinookTexture = [SKTexture textureWithImage:image];
    });
    ChinookHelicopter *heli = [[ChinookHelicopter alloc] initWithTexture:_chinookTexture forDraggable:dragDirection];

    CGFloat offsetX = heli.frame.size.width * heli.anchorPoint.x;
    CGFloat offsetY = heli.frame.size.height * heli.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 4 - offsetX, 43 - offsetY);
    CGPathAddLineToPoint(path, NULL, 31 - offsetX, 10 - offsetY);
    CGPathAddLineToPoint(path, NULL, 72 - offsetX, 2 - offsetY);
    CGPathAddLineToPoint(path, NULL, 93 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 116 - offsetX, 15 - offsetY);
    CGPathAddLineToPoint(path, NULL, 103 - offsetX, 26 - offsetY);
    CGPathAddLineToPoint(path, NULL, 33 - offsetX, 49 - offsetY);
    CGPathCloseSubpath(path);

    [heli setupPhysicsBodyForPath:path];
    CGPathRelease(path);

    return heli;
}

- (CGPoint)getBulletPosition {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return CGPointMake(self.position.x + self.size.width/2 - 12*nodeScale, self.position.y - 28*nodeScale);
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
