//
//  PlaneAchievementInfo.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 6/4/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "PlaneAchievementInfo.h"
#import "Airplane.h"

@interface PlaneAchievementInfo()

@property (copy, nonatomic, readwrite) PlaneGenerator planeGenerator;
@property (copy, nonatomic, readwrite) UnlockChecker unlockChecker;

@end

@implementation PlaneAchievementInfo

- (id)initWithGenerator:(PlaneGenerator)generator withUnlockChecker:(UnlockChecker)unlockChecker forUnlockString:(NSString *)howToUnlock {
    self = [super init];
    if(self) {
        _planeGenerator = generator;
        _unlockChecker = unlockChecker;
        _howToUnlock = howToUnlock;
    }
    return self;
}

- (void)dealloc {
    self.planeGenerator = NULL;
    self.unlockChecker = NULL;
}

@end
