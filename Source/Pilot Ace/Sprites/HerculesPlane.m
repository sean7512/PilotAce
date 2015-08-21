//
//  HerculesPlane.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/4/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "HerculesPlane.h"
#import "PilotAceAppDelegate.h"

@implementation HerculesPlane

static NSString *const PLANE_IMG = @"Hercules";

static SKTexture *_herculesTexture;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture forDraggable:dragDirection];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)createForDraggable:(AllowableDragDirection)dragDirection {
    static dispatch_once_t loadHerculesTextureOnce;
    dispatch_once(&loadHerculesTextureOnce, ^{
        _herculesTexture = [SKTexture textureWithImageNamed:PLANE_IMG];
    });
    HerculesPlane *plane = [[HerculesPlane alloc] initWithTexture:_herculesTexture forDraggable:dragDirection];

    CGFloat offsetX = plane.frame.size.width * plane.anchorPoint.x;
    CGFloat offsetY = plane.frame.size.height * plane.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 69 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 35 - offsetY);
    CGPathAddLineToPoint(path, NULL, 56 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(path, NULL, 65 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 103 - offsetX, 32 - offsetY);
    CGPathAddLineToPoint(path, NULL, 103 - offsetX, 41 - offsetY);
    CGPathAddLineToPoint(path, NULL, 52 - offsetX, 74 - offsetY);
    CGPathCloseSubpath(path);

    [plane setupPhysicsBodyForPath:path];
    CGPathRelease(path);

    return plane;
}

- (CGPoint)getBulletPosition {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return CGPointMake(self.position.x + self.size.width/2, self.position.y - 5*nodeScale);
}

- (CGFloat)getRelativeBulletHeightFromTop {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return (self.size.height/2) + 5*nodeScale;
}

- (CGFloat)getRelativeBulletHeightFromBottom {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];
    return (self.size.height/2) - 5*nodeScale;
}


@end
