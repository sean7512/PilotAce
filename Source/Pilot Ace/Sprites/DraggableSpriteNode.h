//
//  DraggableSpriteNode.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    DraggableVerticalOnly,
    DraggableHorizontalOnly,
    DraggableBoth,
    DraggableNone
} AllowableDragDirection;

@interface DraggableSpriteNode : SKSpriteNode

@property (assign, nonatomic) CGFloat topInset;
@property (assign, nonatomic) CGFloat bottomInset;

- (id)initWithTexture:(SKTexture *)texture forDraggable:(AllowableDragDirection)dragDirection;

@end
