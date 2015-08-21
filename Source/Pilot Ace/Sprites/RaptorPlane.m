//
//  RaptorPlane.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/7/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "RaptorPlane.h"
#import "PilotAceAppDelegate.h"

@implementation RaptorPlane

static NSString *const PLANE_IMG = @"Raptor";

static SKTexture *_raptorTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadRaptorTextureOnce;
    dispatch_once(&loadRaptorTextureOnce, ^{
        _raptorTexture = [SKTexture textureWithImageNamed:PLANE_IMG];
    });
    RaptorPlane *plane = [[RaptorPlane alloc] initWithTexture:_raptorTexture forDraggable:dragDirection];

    CGFloat offsetX = plane.frame.size.width * plane.anchorPoint.x;
    CGFloat offsetY = plane.frame.size.height * plane.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 18 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 12 - offsetY);
    CGPathAddLineToPoint(path, NULL, 15 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(path, NULL, 22 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 104 - offsetX, 16 - offsetY);
    CGPathAddLineToPoint(path, NULL, 104 - offsetX, 19 - offsetY);
    CGPathAddLineToPoint(path, NULL, 84 - offsetX, 29 - offsetY);
    CGPathAddLineToPoint(path, NULL, 29 - offsetX, 44 - offsetY);
    CGPathAddLineToPoint(path, NULL, 23 - offsetX, 44 - offsetY);
    CGPathAddLineToPoint(path, NULL, 7 - offsetX, 32 - offsetY);
    CGPathCloseSubpath(path);

    [plane setupPhysicsBodyForPath:path];
    CGPathRelease(path);

    return plane;
}

- (CGPoint)getBulletPosition {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return CGPointMake(self.position.x + self.size.width/2, self.position.y - 10*nodeScale);
}

- (CGFloat)getRelativeBulletHeightFromTop {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return (self.size.height/2) + 10*nodeScale;
}

- (CGFloat)getRelativeBulletHeightFromBottom {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return (self.size.height/2) - 10*nodeScale;
}

@end

