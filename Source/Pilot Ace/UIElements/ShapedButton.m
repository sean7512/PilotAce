//
//  CircleButton.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "ShapedButton.h"
#import "ShapedButton_Protected.h"

@interface ShapedButton()

@property (assign, nonatomic) BOOL isPressedDown;
@property (copy, nonatomic) TouchUpInsideCallback touchUpCallback;
@property (copy, nonatomic) TouchDownInsideCallback touchDownCallback;

@end

@implementation ShapedButton

static CGFloat const BUTTON_PRESS_VARIANCE = 20;

- (id)initWithTouchUpInsideCallback:(TouchUpInsideCallback)touchUp withTouchDownInsideCallback:(TouchDownInsideCallback)touchDown {
    if (self = [super init]) {
        _isPressedDown = NO;
        _touchUpCallback = touchUp;
        _touchDownCallback = touchDown;
    }
    return self;
}

+ (id)createWithTouchUpInsideCallBack:(TouchUpInsideCallback)callback {
    ShapedButton *button = [[ShapedButton alloc] initWithTouchUpInsideCallback:callback withTouchDownInsideCallback:NULL];
    button.userInteractionEnabled = YES;
    return button;
}

+ (id)createWithTouchDownInsideEventCallBack:(TouchDownInsideCallback)callback {
    ShapedButton *button = [[ShapedButton alloc] initWithTouchUpInsideCallback:NULL withTouchDownInsideCallback:callback];
    button.userInteractionEnabled = YES;
    return button;
}

- (void)rectWithWidth:(CGFloat)width height:(CGFloat)height {
    UIBezierPath *buttonPath = [[UIBezierPath alloc] init];
    [buttonPath moveToPoint:CGPointMake(0, 0)];
    [buttonPath addLineToPoint:CGPointMake(0, height)];
    [buttonPath addLineToPoint:CGPointMake(width, height)];
    [buttonPath addLineToPoint:CGPointMake(width, 0)];
    [buttonPath addLineToPoint:CGPointMake(0, 0)];
    self.path = buttonPath.CGPath;
}

- (BOOL)shouldFireCallback {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.touchDownCallback) {
        self.touchDownCallback();
    }
    self.isPressedDown = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isPressedDown = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat minWidth = (self.frame.size.width/2.0 + BUTTON_PRESS_VARIANCE) * -1;
    CGFloat minHeight = -BUTTON_PRESS_VARIANCE;
    CGRect varianceRect = CGRectMake(minWidth, minHeight, self.frame.size.width + (BUTTON_PRESS_VARIANCE*2), self.frame.size.height + (BUTTON_PRESS_VARIANCE*2));

    for(UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        self.isPressedDown = CGRectContainsPoint(varianceRect, location);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.isPressedDown && [self shouldFireCallback] && self.touchUpCallback) {
        // fire event
        self.touchUpCallback();
        self.isPressedDown = NO;
    }
}

- (void)dealloc {
    self.touchUpCallback = NULL;
    self.touchDownCallback = NULL;
}

@end
