//
//  Lightning.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/25/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Lightning.h"
#import "CollisionController.h"
#import "PilotAceAppDelegate.h"

@implementation Lightning

static NSString *const IMG_NAME = @"Lightning";

static SKTexture *_texture;

- (id)initWithTexture:(SKTexture *)texture {
    self = [super initWithTexture:texture];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)create {
    static dispatch_once_t loadLightningTextureOnce;
    dispatch_once(&loadLightningTextureOnce, ^{
        _texture = [SKTexture textureWithImageNamed:IMG_NAME];
    });

    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    Lightning *lightning = [[Lightning alloc] initWithTexture:_texture];

    CGFloat offsetX = lightning.frame.size.width * lightning.anchorPoint.x;
    CGFloat offsetY = lightning.frame.size.height * lightning.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 38 - offsetX, 67 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 34 - offsetY);
    CGPathAddLineToPoint(path, NULL, 2 - offsetX, 23 - offsetY);
    CGPathAddLineToPoint(path, NULL, 46 - offsetX, 2 - offsetY);
    CGPathAddLineToPoint(path, NULL, 63 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(path, NULL, 80 - offsetX, 23 - offsetY);
    CGPathAddLineToPoint(path, NULL, 81 - offsetX, 35 - offsetY);
    CGPathAddLineToPoint(path, NULL, 60 - offsetX, 60 - offsetY);
    CGPathCloseSubpath(path);
    lightning.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    CGPathRelease(path);

    [lightning setScale:nodeScale];

    lightning.physicsBody.dynamic = YES;
    lightning.physicsBody.categoryBitMask = SpriteColliderTypeLightning;
    // plane looks for collisions
    lightning.physicsBody.collisionBitMask = 0;

    return lightning;
}

- (CGFloat)getPreferredYPositionForScene:(SKScene<SceneInsetProvider> *)scene {
    return scene.size.height - [scene getTopInset] - self.size.height/2;
}

@end
