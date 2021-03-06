//
//  CircleButton.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ButtonSupport.h"
#import "ActionableNode.h"

@interface ShapedButton : SKShapeNode <ActionableNode>

+ (id)createWithTouchUpInsideCallBack:(TouchUpInsideCallback)callback;
+ (id)createWithTouchDownInsideEventCallBack:(TouchDownInsideCallback)callback;
- (void)rectWithWidth:(CGFloat)width height:(CGFloat)height;

@end
