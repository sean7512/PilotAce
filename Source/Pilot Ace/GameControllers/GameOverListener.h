//
//  CollisionListener.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/18/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameOverListener <NSObject>

@required
- (void)gameOver;

@end
