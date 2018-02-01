//
//  MainMenuScene.h
//  Pilot Ace
//

//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "NavigableScene.h"
#import "GameSettingsController.h"

@interface MainMenuScene : NavigableScene <SystemMenuHandlingScene>

+ (id)createWithSize:(CGSize)size withSideInsets:(CGFloat)inset;

@end
