//
//  ObstacleGenerator.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/25/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ObstacleNode.h"

@interface ObstacleGenerator : SKSpriteNode

- (SKSpriteNode<ObstacleNode> *)createRandomObstacle;
- (SKSpriteNode<ObstacleNode> *)createRandomTopObstacle;
- (SKSpriteNode<ObstacleNode> *)createRandomBottomObstacle;

@end
