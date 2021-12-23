//
//  PlaneAchievementInfo.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 6/4/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Airplane;

typedef Airplane*(^PlaneGenerator)(void);
typedef BOOL(^UnlockChecker)(void);

@interface PlaneAchievementInfo : NSObject

@property (copy, nonatomic, readonly) PlaneGenerator planeGenerator;
@property (copy, nonatomic, readonly) UnlockChecker unlockChecker;
@property (strong, nonatomic, readonly) NSString *howToUnlock;

- (id)initWithGenerator:(PlaneGenerator)generator withUnlockChecker:(UnlockChecker)unlockChecker forUnlockString:(NSString *)howToUnlock;

@end
