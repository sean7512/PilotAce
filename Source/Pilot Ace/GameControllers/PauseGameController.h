//
//  PauseGameController.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/27/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PauseGameController <NSObject>

@required
/*!
 Pauses the game without playing any sounds.
 */
- (void)pauseGame;

@required
/*!
 Pauses the game with optionally playing the pause sound.
 @param playSound YES if the pause sound should be played; NO otherwise.
 */
- (void)pauseGamePlayingSound:(BOOL)playSound;

@required
- (void)resumeGame;

@end
