//
//  OspreyHelicopter.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 6/6/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "OspreyHelicopter.h"
#import "PilotAceAppDelegate.h"

@implementation OspreyHelicopter

static NSString *const HELICOPTER_IMG = @"Osprey";

static SKTexture *_ospreyTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadOspreyTextureOnce;
    dispatch_once(&loadOspreyTextureOnce, ^{
        _ospreyTexture = [SKTexture textureWithImageNamed:HELICOPTER_IMG];
    });
    OspreyHelicopter *heli = [[OspreyHelicopter alloc] initWithTexture:_ospreyTexture forDraggable:dragDirection];

    CGFloat offsetX = heli.frame.size.width * heli.anchorPoint.x;
    CGFloat offsetY = heli.frame.size.height * heli.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 24 - offsetY);
    CGPathAddLineToPoint(path, NULL, 1 - offsetX, 13 - offsetY);
    CGPathAddLineToPoint(path, NULL, 32 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 66 - offsetX, 5 - offsetY);
    CGPathAddLineToPoint(path, NULL, 67 - offsetX, 33 - offsetY);
    CGPathAddLineToPoint(path, NULL, 48 - offsetX, 49 - offsetY);
    CGPathAddLineToPoint(path, NULL, 7 - offsetX, 30 - offsetY);
    CGPathCloseSubpath(path);

    [heli setupPhysicsBodyForPath:path];
    CGPathRelease(path);

    return heli;
}

- (CGPoint)getBulletPosition {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return CGPointMake(self.position.x + self.size.width/2, self.position.y - 24*nodeScale);
}

- (CGFloat)getRelativeBulletHeightFromTop {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return (self.size.height/2) + 24*nodeScale;
}

- (CGFloat)getRelativeBulletHeightFromBottom {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return (self.size.height/2) - 24*nodeScale;
}

@end
