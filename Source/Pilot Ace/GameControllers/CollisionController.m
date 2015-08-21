//
//  CollisionController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "CollisionController.h"
#import "Bullet.h"
#import "Missile.h"
#import "Airplane.h"
#import "SKEmitterNodeFactory.h"
#import "Fuel.h"
#import "MissileController.h"
#import "DistanceController.h"
#import "AirplaneController.h"
#import "DistanceController.h"
#import "PilotAceAppDelegate.h"

@interface CollisionController()

@property (weak, nonatomic) SKScene<GameOverListener> *sceneGameOverListener;
@property (weak, nonatomic) AirplaneController *planeController;
@property (assign, nonatomic) int missilesDestroyed;
@property (assign, nonatomic) CGFloat nodeScale;

@end

@implementation CollisionController

static CGFloat const PLANE_SMOKE_Y_OFFSET = 35;
static CGFloat const INVISBILE_ALPHA = 0;
static NSTimeInterval const FUEL_FADE_IN_SECONDS = 0.3;
static int const MISSILES_DESTROYED_FOR_FUEL = 3;
static int const DEF_MISSILED_DESTROYED = 0;
static NSString *const PLANE_FIRE_PARTICLE = @"PlaneFireExplosionParticle";
static NSString *const PLANE_SMOKE_PARTICLE = @"PlaneSmokeExplosionParticle";
static NSString *const MISSILE_FIRE_PARTICLE = @"MissileFireExplosion";
static NSString *const MISSILE_EXPLOSION_SOUND = @"missile_explosion.caf";
static NSString *const BULLET_OBJECT_HIT_SOUND = @"bullet_object_hit.caf";
static NSString *const PLANE_EXPLOSION_SOUND = @"plane_explosion.caf";
static NSString *const GAS_RECEIVED_SOUND = @"gas_can.caf";
static NSString *const BULLET_HIT_MISSILE_NO_EXPLODE_SOUND = @"missile_tink.caf";

static SKAction *_missileExplosionSound;
static SKAction *_bulletObjectHitSound;
static SKAction *_planeExplosionSound;
static SKAction *_gasCanSound;
static SKAction *_bulletHitMissileNoExplodeSound;

- (id)initWithScene:(SKScene<GameOverListener> *)scene withPlaneController:(AirplaneController *)planeController {
    self = [super init];
    if(self) {
        PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
        _sceneGameOverListener = scene;
        _planeController = planeController;
        _missilesDestroyed = DEF_MISSILED_DESTROYED;
        _nodeScale = [appDelegate getNodeScale];

        static dispatch_once_t loadActionSoundsOnceToken;
        dispatch_once(&loadActionSoundsOnceToken, ^{
            _missileExplosionSound = [SKAction playSoundFileNamed:MISSILE_EXPLOSION_SOUND waitForCompletion:NO];
            _bulletObjectHitSound = [SKAction playSoundFileNamed:BULLET_OBJECT_HIT_SOUND waitForCompletion:NO];
            _planeExplosionSound = _gasCanSound = [SKAction playSoundFileNamed:PLANE_EXPLOSION_SOUND waitForCompletion:NO];
            _gasCanSound = [SKAction playSoundFileNamed:GAS_RECEIVED_SOUND waitForCompletion:NO];
            _bulletHitMissileNoExplodeSound = [SKAction playSoundFileNamed:BULLET_HIT_MISSILE_NO_EXPLODE_SOUND waitForCompletion:NO];
        });
    }

    return self;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;

    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }

    // plane hit by missile
    if ((firstBody.categoryBitMask & SpriteColliderTypePlane) != 0 &&
        (secondBody.categoryBitMask & SpriteColliderTypeMissile) != 0) {
        [self plane:(Airplane *)firstBody.node hitByMissile:(Missile *)secondBody.node];
    }

    // plane hit mountain
    if ((firstBody.categoryBitMask & SpriteColliderTypePlane) != 0 &&
        (secondBody.categoryBitMask & SpriteColliderTypeMountain) != 0) {
        [self planeHitMountain:(Airplane *)firstBody.node];
    }

    // plane hit lightning
    if ((firstBody.categoryBitMask & SpriteColliderTypePlane) != 0 &&
        (secondBody.categoryBitMask & SpriteColliderTypeLightning) != 0) {
        [self planeHitLightning:(Airplane *)firstBody.node];
    }

    // plane hit fuel
    if ((firstBody.categoryBitMask & SpriteColliderTypePlane) != 0 &&
        (secondBody.categoryBitMask & SpriteColliderTypeFuel) != 0) {
        [self planeHitFuel:(Fuel *)secondBody.node];
    }

    // bullet hit missile
    if ((firstBody.categoryBitMask & SpriteColliderTypeBullet) != 0 &&
        (secondBody.categoryBitMask & SpriteColliderTypeMissile) != 0) {
        [self missile:(Missile *)secondBody.node hitByBullet:(Bullet *)firstBody.node];
    }

    // bullet hit mountain
    if ((firstBody.categoryBitMask & SpriteColliderTypeBullet) != 0 &&
        (secondBody.categoryBitMask & SpriteColliderTypeMountain) != 0) {
        [self bulletHitMountain:(Bullet *)firstBody.node];
    }

    // missile hit mountain
    if ((firstBody.categoryBitMask & SpriteColliderTypeMissile) != 0 &&
        (secondBody.categoryBitMask & SpriteColliderTypeMountain) != 0) {
        [self missileHitMountain:(Missile *)firstBody.node];
    }

}

- (void)didEndContact:(SKPhysicsContact *)contact {
    // nothing to do
}

- (void)playActionSound:(SKAction *)actionSound {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if((![appDelegate isOtherAudioPlaying]) && [appDelegate isSoundEffectsEnabled] && actionSound) {
        [self.sceneGameOverListener runAction:actionSound];
    }
}

- (void)plane:(Airplane *)plane hitByMissile:(Missile *)missile {
    CGPoint firePos = CGPointMake(plane.position.x, missile.position.y);

    [self planeHitGameEndingObject:plane withFireAtPosition:firePos];

    // remove missile
    [missile removeFromParent];
}

- (void)planeHitMountain:(Airplane *)plane {
    if(plane.didNoseDive) {
        CGPoint firePos = CGPointMake(plane.position.x, plane.position.y - (plane.size.width/2));
        [self planeHitGameEndingObject:plane withFireAtPosition:firePos];
    } else {
        [self planeHitGameEndingObject:plane];
    }
}

- (void)planeHitLightning:(Airplane *)plane {
    [self planeHitGameEndingObject:plane withFireAtPosition:plane.position];
}

- (void)planeHitGameEndingObject:(Airplane *)plane {
    CGPoint firePos = CGPointMake(plane.position.x, plane.position.y - (plane.size.height/2));
    [self planeHitGameEndingObject:plane withFireAtPosition:firePos];
}

- (void)planeHitGameEndingObject:(Airplane *)plane withFireAtPosition:(CGPoint)firePosition {
    // show explosion
    SKEmitterNode *fire = [SKEmitterNodeFactory createForParticleFilename:PLANE_FIRE_PARTICLE];
    SKEmitterNode *smoke = [SKEmitterNodeFactory createForParticleFilename:PLANE_SMOKE_PARTICLE];
    [fire setScale:self.nodeScale];
    [smoke setScale:self.nodeScale];
    fire.position = firePosition;
    smoke.position = CGPointMake(fire.position.x, fire.position.y + PLANE_SMOKE_Y_OFFSET);
    if(smoke && fire) {
        [self.sceneGameOverListener addChild:smoke];
        [self.sceneGameOverListener addChild:fire];
    } else {
        NSLog(@"plane fire or smoke not initialized.");
    }
    [plane removeFromParent];

    // play sound
    [self playActionSound:_planeExplosionSound];

    // notify of game over
    [self.sceneGameOverListener gameOver];
}

- (void)planeHitFuel:(Fuel *)fuel {
    // play fuel sound
    [self playActionSound:_gasCanSound];

    // update fuel level
    [self.planeController receivedFuel];

    // remove fuel
    [fuel removeFromParent];
}

- (void)bulletHitMountain:(Bullet *)bullet {
    [self bulletHitSolidObject:bullet];
}

- (void)bulletHitSolidObject:(Bullet *)bullet {
    // play sound
    [self playActionSound:_bulletObjectHitSound];

    [bullet removeFromParent];
}

- (BOOL)isMissileOffscreen:(Missile *)missile {
    return (missile.position.x - (missile.size.width/2) >= self.sceneGameOverListener.frame.size.width);
}

- (void)missile:(Missile *)missile hitByBullet:(Bullet *)bullet {
    if([self isMissileOffscreen:missile]) {
        return;
    }

    if([missile hitByBullet]) {
        [self missileHitDestroyingObject:missile];
    } else {
        // missile not destroyed yet, play *tink* sound
        [self playActionSound:_bulletHitMissileNoExplodeSound];
    }

    // always remove bullet
    [bullet removeFromParent];
}

- (void)missileHitMountain:(Missile *)missile {
    [self missileHitDestroyingObject:missile];
}

- (void)missileHitDestroyingObject:(Missile *)missile {
    // missile is destroyed
    self.missilesDestroyed++;
    CGPoint missilePosition = missile.position;

    // show fire particle affect
    SKEmitterNode *fire = [SKEmitterNodeFactory createForParticleFilename:MISSILE_FIRE_PARTICLE];
    [fire setScale:self.nodeScale];
    fire.position = missilePosition;
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-fire.frame.size.width/2, missilePosition.y) duration:[DistanceController determineStationaryObjectDurationFromPositionX:fire.position.x withWidth:fire.frame.size.width]];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [fire runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    if(fire) {
        [self.sceneGameOverListener addChild:fire];
    } else {
        NSLog(@"Fire is not initialized!");
    }

    // add fuel if necessary
    if(self.missilesDestroyed >= MISSILES_DESTROYED_FOR_FUEL) {
        // add fuel to scene

        CGPoint fuelPosition = missilePosition;
        NSArray *nodes = [self.sceneGameOverListener nodesAtPoint:missilePosition];
        for (SKNode *node in nodes) {
            uint32_t nodeCategory = node.physicsBody.categoryBitMask;
            if((nodeCategory & SpriteColliderTypeLightning) != 0 || (nodeCategory & SpriteColliderTypeMountain) != 0) {
                // the fuel position is in lightning or mountain
                fuelPosition = CGPointMake(node.position.x + node.frame.size.width/2, fuelPosition.y);
            }
        }

        Fuel *fuel = [Fuel createAtPosition:fuelPosition];
        fuel.alpha = INVISBILE_ALPHA;
        NSTimeInterval moveDuration = [DistanceController determineStationaryObjectDuration:fuel];
        SKAction *fadeIn = [SKAction fadeInWithDuration:FUEL_FADE_IN_SECONDS];
        SKAction *move = [SKAction moveTo:CGPointMake(-fuel.size.width/2, fuel.position.y) duration:moveDuration];
        SKAction *done = [SKAction removeFromParent];
        [self.sceneGameOverListener addChild:fuel];
        [fuel runAction:[SKAction sequence:@[fadeIn, move, done]]];

        // reset missile destroy count
        self.missilesDestroyed = DEF_MISSILED_DESTROYED;
    }

    // play sound
    [self playActionSound:_missileExplosionSound];
    
    // remove missile from scene
    [missile removeFromParent];
}

@end
