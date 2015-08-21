//
//  ViewController.h
//  Pilot Ace
//

//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const GAME_STARTING_NOTIFICATION;
extern NSString *const GAME_MUSIC_SETTING_CHANGED;
extern NSString *const GAME_MUSIC_SETTING_KEY;
extern NSString *const SHOW_SHARE_SHEET;
extern NSString *const SHARE_TEXT_KEY;

@interface ViewController : UIViewController

- (void)pauseGame;
- (void)resumeGame;

@end
