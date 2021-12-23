//
//  SceneTimeOfDayFactory.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/21/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "SceneTimeOfDayFactory.h"
#import "NightTimeSceneData.h"
#import "DayTimeSceneData.h"
#import "CollisionController.h"
#import "DistanceController.h"
#import "GameSettingsController.h"

@implementation SceneTimeOfDayFactory

+ (NSObject<TimeOfDaySceneData> *)setUpSceneWithRandomTimeOfDayData:(SKScene *)scene withMovement:(BOOL)isMoving {
    NSObject<TimeOfDaySceneData> *sceneData = [SceneTimeOfDayFactory getRandomTimeOfDaySceneData];
    [SceneTimeOfDayFactory setUpScene:scene forTimeOfDayData:sceneData withMovement:isMoving];
    return sceneData;
}

+ (void)setUpScene:(SKScene *)scene forTimeOfDayData:(NSObject<TimeOfDaySceneData> *)sceneData withMovement:(BOOL)isMoving {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    // set scene
    scene.backgroundColor = sceneData.backgroundColor;

    SKTexture *groundTexture = sceneData.foregroundTexture;
    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width*2*nodeScale y:0 duration:[DistanceController determineStationaryObjectDurationFromPositionX:0 withWidth:groundTexture.size.width*4*nodeScale]];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width*2*nodeScale y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];

    for(int i=0; i<2+scene.frame.size.width/(groundTexture.size.width*2); i++) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        sprite.name = @"background";

        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        sprite.physicsBody.dynamic = YES;
        sprite.physicsBody.categoryBitMask = SpriteColliderTypeMountain;
        sprite.physicsBody.collisionBitMask = 0;

        [sprite setScale:2.0 * [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize]];
        sprite.position = CGPointMake(i * sprite.size.width, 0);
        [scene addChild:sprite];
        if(isMoving) {
            [sprite runAction:moveGroundSpritesForever];
        }
    }

    SKTexture *distantTexture = sceneData.distantBackgroundTexture;
    SKAction* moveDistantSprite = [SKAction moveByX:-distantTexture.size.width*nodeScale y:0 duration:0.05*nodeScale * distantTexture.size.width];
    SKAction* resetDistantSprite = [SKAction moveByX:distantTexture.size.width*nodeScale y:0 duration:0];
    SKAction* moveDistantSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveDistantSprite, resetDistantSprite]]];
    for(int i=0; i<2+scene.frame.size.width/(distantTexture.size.width); ++i) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:distantTexture];
        sprite.name = @"background";
        
        [sprite setScale:1.0 * [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize]];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height/2 + groundTexture.size.height*nodeScale);
        [scene addChild:sprite];
        if(isMoving) {
            [sprite runAction:moveDistantSpritesForever];
        }
    }

}

+ (NSObject<TimeOfDaySceneData> *)getRandomTimeOfDaySceneData {
    NSObject<TimeOfDaySceneData> *sceneData;
    if([SceneTimeOfDayFactory shouldBeNighttime]) {
        sceneData = [NightTimeSceneData sharedInstance];
    } else {
        sceneData = [DayTimeSceneData sharedInstance];
    }

    return sceneData;
}

+ (BOOL)shouldBeNighttime {
    // random number from 0 - 10
    return arc4random_uniform(11) % 2 == 0;
}

@end
