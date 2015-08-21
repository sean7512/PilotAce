//
//  AboutScene.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface AboutScene : SKScene

+ (id)createWithSize:(CGSize)size withSettingsOrigin:(SKScene *)scene withSettingsBackText:(NSString *)originBackText;

@end
