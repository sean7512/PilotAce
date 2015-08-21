//
//  LabelButton.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "LabelButton.h"

@interface LabelButton()

@property (assign, nonatomic) BOOL isPressedDown;
@property (strong, nonatomic) SKColor *originalColor;
@property (copy, nonatomic) TouchUpInsideCallback eventCallback;

@end

@implementation LabelButton

static CGFloat const BUTTON_PRESS_VARIANCE = 20;

#pragma mark Initializers
- (id)initWithFontNamed:(NSString *)fontName {
    self = [super initWithFontNamed:fontName];
    if(self) {
        _isPressedDown = NO;
        _highlightedColor = [SKColor whiteColor];
    }

    return self;
}

+ (id)createWithFontNamed:(NSString *)fontName withTouchEventCallback:(TouchUpInsideCallback)callback {
    LabelButton *button = [[LabelButton alloc] initWithFontNamed:fontName];
    button.eventCallback = callback;
    button.userInteractionEnabled = YES;
    button.fontColor = [SKColor blueColor];
    button.originalColor = button.fontColor;
    return button;
}

- (void)dealloc {
    self.eventCallback = NULL;
}

#pragma mark Color Override
- (void)setFontColor:(UIColor *)fontColor {
    [super setFontColor:fontColor];
    if(!self.isPressedDown) {
        // we may be setting the font color from a press
        self.originalColor = fontColor;
    }
}

#pragma mark Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
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
    if(self.isPressedDown) {
        // fire event
        if(self.eventCallback) {
            self.eventCallback();
        }
        self.isPressedDown = NO;
    }
}

#pragma mark Button State Setter Override
- (void)setIsPressedDown:(BOOL)isPressedDown {
    _isPressedDown = isPressedDown;
    if(isPressedDown) {
        self.fontColor = self.highlightedColor;
    } else {
        self.fontColor = self.originalColor;
    }
}

@end
