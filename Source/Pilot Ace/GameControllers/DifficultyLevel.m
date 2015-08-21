//
//  DifficultyController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/1/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "DifficultyLevel.h"
#import "PilotAceAppDelegate.h"
#import "PlaneAchievementInfo.h"
#import "AchievementController.h"
#import "StandardPlane.h"
#import "HerculesPlane.h"
#import "StealthPlane.h"
#import "RaptorPlane.h"
#import "BlackbirdPlane.h"
#import "StratotankerPlane.h"
#import "ApacheHelicopter.h"
#import "ChinookHelicopter.h"
#import "OspreyHelicopter.h"

@interface DifficultyLevel()

@property (strong, nonatomic, readonly) NSString *keySuffix;
@property (strong, nonatomic, readwrite) NSArray *planeAchievementInfoList;

@end

@implementation DifficultyLevel

// plane difficulty
static DifficultyLevel *_planeDifficulty;
static NSString *const PLANE_DISPLAY_NAME = @"Plane";
static NSString *const PLANE_SUFFIX = @"";
static int const PLANE_NUM_BULLETS_TO_DESTROY_MISSILE = 1;
static NSTimeInterval const PLANE_SECONDS_BETWEEN_MISSILES = 1;
static NSTimeInterval const PLANE_SECONDS_BETWEEN_OBSTACLES = 5.3;
static BOOL const PLANE_HAS_IN_GAME_ACHIEVEMENTS = YES;

// helicopter difficulty
static DifficultyLevel *_helicopterDifficulty;
static NSString *const HELI_DISPLAY_NAME = @"Helicopter";
static NSString *const HELI_SUFFIX = @"_helicopters";
static int const HELI_NUM_BULLETS_TO_DESTROY_MISSILE = 1;
static NSTimeInterval const HELI_SECONDS_BETWEEN_MISSILES = 0.8;
static NSTimeInterval const HELI_SECONDS_BETWEEN_OBSTACLES = 4.5;
static BOOL const HELI_HAS_IN_GAME_ACHIEVEMENTS = NO;

- (id)initWithNumBullets:(int)numBullets withSecondsBetweenMissiles:(NSTimeInterval)secBetweenMissiles withSecondsBetweenObstacles:(NSTimeInterval)secBetweenObstacles withDisplayName:(NSString *)displayName withKeySuffix:(NSString *)suffix hasInGameAchievements:(BOOL)hasInGameAchievements {
    self = [super init];
    if(self) {
        _numBulletsToDestroyMissile = numBullets;
        _secondsBetweenMissiles = secBetweenMissiles;
        _secondsBetweenObstacles = secBetweenObstacles;
        _displayName = displayName;
        _keySuffix = suffix;
        _hasInGameAchievements = hasInGameAchievements;
    }
    return self;
}

- (NSString *)keyWithSuffix:(NSString *)key {
    return [key stringByAppendingString:self.keySuffix];
}

+ (DifficultyLevel *)planeDifficulty {
    static dispatch_once_t oncePlaneToken;
    dispatch_once(&oncePlaneToken, ^{
        _planeDifficulty = [[DifficultyLevel alloc] initWithNumBullets:PLANE_NUM_BULLETS_TO_DESTROY_MISSILE withSecondsBetweenMissiles:PLANE_SECONDS_BETWEEN_MISSILES withSecondsBetweenObstacles:PLANE_SECONDS_BETWEEN_OBSTACLES withDisplayName:PLANE_DISPLAY_NAME withKeySuffix:PLANE_SUFFIX hasInGameAchievements:PLANE_HAS_IN_GAME_ACHIEVEMENTS];

        PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];

        // plane 1
        PlaneAchievementInfo *standard = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [StandardPlane createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            // always unlocked
            return YES;
        } forUnlockString:@"Never locked"];

        // plane 2
        PlaneAchievementInfo *hercules = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [HerculesPlane createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            return [appDelegate isHerculesUnlocked];
        } forUnlockString:[NSString stringWithFormat:@"This plane is locked! To unlock, you need to fly at least %g km with any plane.", HERCULES_PLANE_SCORE]];

        // plane 3
        PlaneAchievementInfo *stealth = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [StealthPlane createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            return [appDelegate isStealthUnlocked];
        } forUnlockString:[NSString stringWithFormat:@"This plane is locked! To unlock, you need to fly at least %g km with any plane.", STEALTH_PLANE_SCORE]];

        // plane 4
        PlaneAchievementInfo *raptor = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [RaptorPlane createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            return [appDelegate isRaptorUnlocked];
        } forUnlockString:[NSString stringWithFormat:@"This plane is locked! To unlock, you need to fly at least %g km with any plane.", RAPTOR_PLANE_SCORE]];

        // plane 5
        PlaneAchievementInfo *blackbird = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [BlackbirdPlane createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            return [appDelegate isBlackbirdUnlocked];
        } forUnlockString:[NSString stringWithFormat:@"This plane is locked! To unlock, you need to fly at least %g km with any plane.", BLACKBIRD_PLANE_SCORE]];

        // plane 6
        PlaneAchievementInfo *stratotanker = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [StratotankerPlane createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            return [appDelegate isStratotankerUnlocked];
        } forUnlockString:[NSString stringWithFormat:@"This plane is locked! To unlock, you need to fly at least %g km with any plane.", STRATOTANKER_PLANE_SCORE]];

        _planeDifficulty.planeAchievementInfoList = @[standard, hercules, stealth, raptor, blackbird, stratotanker];
    });
    return _planeDifficulty;
}

+ (DifficultyLevel *)helicopterDifficulty {
    static dispatch_once_t onceHelicopterToken;
    dispatch_once(&onceHelicopterToken, ^{
        _helicopterDifficulty = [[DifficultyLevel alloc] initWithNumBullets:HELI_NUM_BULLETS_TO_DESTROY_MISSILE withSecondsBetweenMissiles:HELI_SECONDS_BETWEEN_MISSILES withSecondsBetweenObstacles:HELI_SECONDS_BETWEEN_OBSTACLES withDisplayName:HELI_DISPLAY_NAME withKeySuffix:HELI_SUFFIX hasInGameAchievements:HELI_HAS_IN_GAME_ACHIEVEMENTS];

        PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];

        // heli 1
        PlaneAchievementInfo *apache = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [ApacheHelicopter createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            return [appDelegate isApacheUnlocked];
        } forUnlockString:[NSString stringWithFormat:@"This helicopter is locked! To unlock, you need to fly at least %g km with any plane.", HERCULES_PLANE_SCORE]];

        // heli 2
        PlaneAchievementInfo *chinook = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [ChinookHelicopter createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            return [appDelegate isChinookUnlocked];
        } forUnlockString:[NSString stringWithFormat:@"This helicopter is locked! To unlock, you need to fly at least %g km with any helicopter.", CHINOOK_UNLOCK_SCORE]];

        // heli 3
        PlaneAchievementInfo *osprey = [[PlaneAchievementInfo alloc] initWithGenerator:^Airplane *{
            return [OspreyHelicopter createForDraggable:DraggableNone];
        } withUnlockChecker:^BOOL{
            return [appDelegate isOspreyUnlocked];
        } forUnlockString:[NSString stringWithFormat:@"This helicopter is locked! To unlock, you need to fly at least %g km with any helicopter.", OSPREY_UNLOCK_SCORE]];

        _helicopterDifficulty.planeAchievementInfoList = @[apache, chinook, osprey];
    });
    return _helicopterDifficulty;
}

+ (NSArray *)getAllDifficultyLevels {
    return @[[DifficultyLevel planeDifficulty], [DifficultyLevel helicopterDifficulty]];
}

@end
