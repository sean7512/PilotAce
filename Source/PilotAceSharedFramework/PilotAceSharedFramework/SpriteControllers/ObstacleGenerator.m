//
//  ObstacleGenerator.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/25/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "ObstacleGenerator.h"
#import "Lightning.h"
#import "Mountain.h"

@implementation ObstacleGenerator

- (id)init {
    self = [super init];
    if(self) {
        // nothing to init
    }

    return self;
}

- (SKSpriteNode<ObstacleNode> *)createRandomObstacle {
    if([self shouldGetTopObstacle]) {
        return [self createRandomTopObstacle];
    } else {
        return [self createRandomBottomObstacle];
    }
}

- (SKSpriteNode<ObstacleNode> *)createRandomTopObstacle {
    return [Lightning create];
}

- (SKSpriteNode<ObstacleNode> *)createRandomBottomObstacle {
    return [Mountain create];
}

- (BOOL)shouldGetTopObstacle {
    // random number from 0 - 10
    return arc4random_uniform(11) % 2 == 0;
}

@end
