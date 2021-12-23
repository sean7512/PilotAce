//
//  StealthPlane.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/12/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "StealthPlane.h"
#import "GameSettingsController.h"

@implementation StealthPlane

static NSString *const STEALTH_IMG = @"Stealth";

static SKTexture *_stealthTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadStealthTextureOnce;
    dispatch_once(&loadStealthTextureOnce, ^{
        UIImage *image = [UIImage imageNamed:STEALTH_IMG inBundle:[NSBundle bundleForClass:[StealthPlane class]] compatibleWithTraitCollection:nil];
        _stealthTexture = [SKTexture textureWithImage:image];
    });
    StealthPlane *stealth = [[StealthPlane alloc] initWithTexture:_stealthTexture forDraggable:dragDirection];

    CGFloat offsetX = stealth.frame.size.width * stealth.anchorPoint.x;
    CGFloat offsetY = stealth.frame.size.height * stealth.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 43 - offsetY);
    CGPathAddLineToPoint(path, NULL, 18 - offsetX, 5 - offsetY);
    CGPathAddLineToPoint(path, NULL, 32 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 97 - offsetX, 45 - offsetY);
    CGPathAddLineToPoint(path, NULL, 74 - offsetX, 62 - offsetY);
    CGPathAddLineToPoint(path, NULL, 10 - offsetX, 74 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 70 - offsetY);
    CGPathCloseSubpath(path);

    [stealth setupPhysicsBodyForPath:path];
    CGPathRelease(path);

    return stealth;
}

- (CGPoint)getBulletPosition {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return CGPointMake(self.position.x + self.size.width/2, self.position.y + 2*nodeScale);
}

- (CGFloat)getRelativeBulletHeightFromTop {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return (self.size.height/2) - 2*nodeScale;
}

- (CGFloat)getRelativeBulletHeightFromBottom {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];
    return (self.size.height/2) + 2*nodeScale;
}


@end
