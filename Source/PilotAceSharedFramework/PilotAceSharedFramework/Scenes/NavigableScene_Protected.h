//
//  NavigableScene_Protected.h
//  PilotAceSharedFramework
//
//  Created by Sean Kosanovich on 10/24/15.
//  Copyright © 2015 seko. All rights reserved.
//

#import "NavigableScene.h"

@interface NavigableScene()

@property (nonatomic, strong) SKNode<ActionableNode> *selectedNode;
@property (nonatomic, strong) NSMutableArray<NSArray<SKNode<ActionableNode> *> *> *navigableNodes; // 2d array of menu items

- (void)cleanupControllerHandlers;
- (void)setupController:(GCController *)controller;

@end