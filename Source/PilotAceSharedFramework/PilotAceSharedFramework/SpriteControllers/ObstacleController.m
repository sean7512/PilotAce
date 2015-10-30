//
//  ObstacleController.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/25/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "ObstacleController.h"
#import "DistanceController.h"
#import "ObstacleNode.h"
#import "ObstacleGenerator.h"
#import "DifficultyLevel.h"

@interface ObstacleController()

@property (weak, nonatomic) SKScene<SceneInsetProvider> *scene;
@property (strong, nonatomic) ObstacleGenerator *obstacleGenerator;
@property (assign, nonatomic) NSTimeInterval timeSinceLastObstacle;
@property (assign, readonly, nonatomic) NSTimeInterval secondsBetweenObstacles;

@end

@implementation ObstacleController

static NSTimeInterval const DEF_OBSTACLE_ADDED_TIME = 0;

- (id)initWithScene:(SKScene<SceneInsetProvider> *)scene forDifficulty:(DifficultyLevel *)difficulty {
    self = [super init];
    if(self) {
        _scene = scene;
        _timeSinceLastObstacle = DEF_OBSTACLE_ADDED_TIME;
        _obstacleGenerator = [[ObstacleGenerator alloc] init];
        _secondsBetweenObstacles = difficulty.secondsBetweenObstacles;
    }
    return self;
}

- (void)update:(NSTimeInterval)elapsed withSpeedMultiplier:(CGFloat)speed {
    self.timeSinceLastObstacle += elapsed;

    // if 1 second or more has passed, add an obstacle
    if(self.timeSinceLastObstacle >= (self.secondsBetweenObstacles / speed)) {
        // Add an obstacle
        [self addObstacle];
        self.timeSinceLastObstacle = DEF_OBSTACLE_ADDED_TIME;
    }
}

- (void)addObstacle {
    if([self shoulHaveDualObstacle]) {
        // get top and bottom obstacle
        [self setupNodeAndMove:[self.obstacleGenerator createRandomTopObstacle]];
        [self setupNodeAndMove:[self.obstacleGenerator createRandomBottomObstacle]];
    } else {
        // get a random obstacle and add
        [self setupNodeAndMove:[self.obstacleGenerator createRandomObstacle]];
    }
}

- (void)setupNodeAndMove:(SKSpriteNode<ObstacleNode> *)node {
    CGFloat nodeY = [node getPreferredYPositionForScene:self.scene];
    node.position = CGPointMake(self.scene.size.width + (node.size.width/2) , nodeY);
    [self.scene addChild:node];

    // Create the actions
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-node.size.width/2, nodeY) duration:[DistanceController determineStationaryObjectDuration:node]];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [node runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (BOOL)shoulHaveDualObstacle {
    // random number from 0 - 10
    // 30% chance of a dual obstacle
    return arc4random_uniform(11) % 3 == 0;
}

@end
