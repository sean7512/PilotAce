//
//  SettingsScene.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "NavigableScene.h"

@interface SettingsScene : NavigableScene

+ (id)createWithSize:(CGSize)size withBackScene:(SKScene *)scene withBackTitle:(NSString *)backText;

@end
