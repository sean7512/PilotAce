//
//  DraggableSpriteNode.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "DraggableSpriteNode.h"

@interface DraggableSpriteNode()

@property (assign, nonatomic) BOOL isPressedDown;
@property (assign, nonatomic) AllowableDragDirection dragAllow;
@property (assign, nonatomic) BOOL isEdgeInitialized;
@property (assign, nonatomic) CGFloat minX;
@property (assign, nonatomic) CGFloat minY;
@property (assign, nonatomic) CGFloat maxX;
@property (assign, nonatomic) CGFloat maxY;

@end

@implementation  DraggableSpriteNode

static CGFloat const DEF_INSET = 0;
static CGFloat const VARIANCE_DISTANCE = 20;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection {
    self = [super initWithTexture:texture];
    if(self) {
        self.userInteractionEnabled = (dragDirection != DraggableNone);
        _isPressedDown = NO;
        _minX = _minY = _maxX = _maxY = 0;
        _isEdgeInitialized = NO;
        _dragAllow = dragDirection;
        _topInset = DEF_INSET;
        _bottomInset = DEF_INSET;
    }
    return self;
}

- (void)setTopInset:(CGFloat)topInset {
    if(topInset > DEF_INSET) {
        _topInset = topInset;
    }
    self.isEdgeInitialized = NO;
}

- (void)setBottomInset:(CGFloat)bottomInset {
    if(bottomInset > DEF_INSET) {
        _bottomInset = bottomInset;
    }
    self.isEdgeInitialized = NO;
}

- (void)setDragAllow:(AllowableDragDirection)dragAllow {
    _dragAllow = dragAllow;
    self.userInteractionEnabled = (dragAllow != DraggableNone);
}

#pragma mark Touch Overrides
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.dragAllow == DraggableNone) {
        return;
    }

    if(!self.isEdgeInitialized) {
        self.minY = self.size.height/2 + self.bottomInset;
        self.minX = self.size.width/2;
        self.maxY = self.scene.view.bounds.size.height - (self.size.height/2) - self.topInset;
        self.maxX = self.scene.view.bounds.size.width - (self.size.width/2);
        self.isEdgeInitialized = YES;
    }
    self.isPressedDown = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!self.isPressedDown || self.dragAllow == DraggableNone) {
        return;
    }

    for(UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInNode:self.scene];

        CGRect varianceSelf = CGRectMake(self.frame.origin.x-VARIANCE_DISTANCE, self.frame.origin.y-VARIANCE_DISTANCE, self.frame.size.width+(VARIANCE_DISTANCE*2), self.frame.size.height+(VARIANCE_DISTANCE*2));
        if(!CGRectContainsPoint(varianceSelf, touchPoint)) {
            return;
        }

        // make sure we're in bounds!
        if(touchPoint.y < self.minY) {
            touchPoint.y = self.minY;
        }
        if(touchPoint.y > self.maxY) {
            touchPoint.y = self.maxY;
        }
        if(touchPoint.x < self.minX) {
            touchPoint.x = self.minX;
        }
        if(touchPoint.x > self.maxX) {
            touchPoint.x = self.maxX;
        }

        // only allow drag in direction user wanted
        if(self.dragAllow == DraggableVerticalOnly) {
            touchPoint.x = self.position.x;
        } else if(self.dragAllow == DraggableHorizontalOnly) {
            touchPoint.y = self.position.y;
        }

        // set position
        self.position = touchPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isPressedDown = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isPressedDown = NO;
}

@end
