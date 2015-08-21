//
//  LabelButton.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ButtonSupport.h"

@interface LabelButton : SKLabelNode

@property (strong, nonatomic) SKColor *highlightedColor;

+ (id)createWithFontNamed:(NSString *)fontName withTouchEventCallback:(TouchUpInsideCallback)callback;

@end
