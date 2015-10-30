//
//  Missile.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Missile.h"
#import "CollisionController.h"
#import "SKEmitterNodeFactory.h"
#import "GameSettingsController.h"

@interface Missile()

@property (assign, readonly, nonatomic) int numBulletsToDestroy;
@property (assign, nonatomic) int bulletHitCount;
@property (strong, nonatomic) SKEmitterNode *smokeTrail;

@end

@implementation Missile

static SKTexture *_texture;
static NSString *const MISSILE_IMG = @"Missile";
static NSString *const MISSILE_SMOKE_FILE = @"MissileSmokeParticle";

- (id)initWithTexture:(SKTexture *)texture withNumBulletsToDestroy: (int)bulletsToDestroy {
    self = [super initWithTexture:texture];
    if(self) {
        _bulletHitCount = 0;
        _numBulletsToDestroy = bulletsToDestroy;
    }
    return self;
}

+ (id)createWithNumBulletsToDestroy: (int)numBulletsToDestroy {
    static dispatch_once_t loadMissileTextureOnce;
    dispatch_once(&loadMissileTextureOnce, ^{
        UIImage *image = [UIImage imageNamed:MISSILE_IMG inBundle:[NSBundle bundleForClass:[Missile class]] compatibleWithTraitCollection:nil];
        _texture = [SKTexture textureWithImage:image];
    });

    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    Missile *missile = [[Missile alloc] initWithTexture:_texture withNumBulletsToDestroy:numBulletsToDestroy];

    CGFloat offsetX = missile.frame.size.width * missile.anchorPoint.x;
    CGFloat offsetY = missile.frame.size.height * missile.anchorPoint.y;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0 - offsetX, 21 - offsetY);
    CGPathAddLineToPoint(path, NULL, 0 - offsetX, 7 - offsetY);
    CGPathAddLineToPoint(path, NULL, 67 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 66 - offsetX, 30 - offsetY);
    CGPathCloseSubpath(path);
    missile.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    CGPathRelease(path);

    missile.physicsBody.dynamic = YES;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.physicsBody.categoryBitMask = SpriteColliderTypeMissile;
    // plane handles missile/plane collision
    missile.physicsBody.contactTestBitMask = SpriteColliderTypeBullet | SpriteColliderTypeMountain;
    missile.physicsBody.collisionBitMask = 0;

    missile.smokeTrail = [SKEmitterNodeFactory createForParticleFilename:MISSILE_SMOKE_FILE];
    missile.smokeTrail.position = CGPointMake(missile.position.x + missile.size.width*nodeScale/(2*nodeScale), missile.position.y);
    if(missile && missile.smokeTrail) {
        [missile addChild: missile.smokeTrail];
    } else {
        NSLog(@"Missile or smoketrail is nil");
    }

    [missile setScale:nodeScale];

    return missile;
}

- (BOOL)hitByBullet {
    self.bulletHitCount++;
    if(self.bulletHitCount >= self.numBulletsToDestroy) {
        return true;
    }
    return false;
}

- (void)removeFromParent {
    if(self.smokeTrail) {
        /**
         * skemitternode crash
         * http://stackoverflow.com/questions/20019507/skshapenode-with-emiitter-crashes-with-skaction-removefromparent
         */
        [self.smokeTrail removeFromParent];
        self.smokeTrail = nil;
    }
    [super removeFromParent];
}

@end
