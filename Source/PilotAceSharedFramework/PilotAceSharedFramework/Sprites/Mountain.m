//
//  Mountain.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/25/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Mountain.h"
#import "CollisionController.h"
#import "GameSettingsController.h"

@interface Mountain()

@property (assign, nonatomic) CGFloat nodeScale;

@end

@implementation Mountain

static NSString *const IMG_NAME = @"MountainBrown";

static SKTexture *_texture;

- (id)initWithTexture:(SKTexture *)texture {
    self = [super initWithTexture:texture];
    if(self) {
        // nothing to init
    }
    return self;
}

+ (id)create {
    static dispatch_once_t loadMountainTextureOnce;
    dispatch_once(&loadMountainTextureOnce, ^{
        UIImage *image = [UIImage imageNamed:IMG_NAME inBundle:[NSBundle bundleForClass:[Mountain class]] compatibleWithTraitCollection:nil];
        _texture = [SKTexture textureWithImage:image];
    });

    Mountain *mountain = [[Mountain alloc] initWithTexture:_texture];

    mountain.nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    CGFloat offsetX = mountain.frame.size.width * mountain.anchorPoint.x;
    CGFloat offsetY = mountain.frame.size.height * mountain.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 180 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 122 - offsetX, 77 - offsetY);
    CGPathAddLineToPoint(path, NULL, 88 - offsetX, 104 - offsetY);
    CGPathAddLineToPoint(path, NULL, 48 - offsetX, 76 - offsetY);
    CGPathCloseSubpath(path);
    mountain.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    CGPathRelease(path);

    [mountain setScale:mountain.nodeScale];

    mountain.physicsBody.dynamic = YES;
    mountain.physicsBody.categoryBitMask = SpriteColliderTypeMountain;
    // plane/missile looks for collisions
    mountain.physicsBody.collisionBitMask = 0;

    return mountain;
}

- (CGFloat)getPreferredYPositionForScene:(SKScene<SceneInsetProvider> *)scene {
    return [scene getBottomInset] + (self.size.height/2) - (15*self.nodeScale);
}

@end
