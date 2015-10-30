//
//  ScenInsetProvider.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 2/21/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SceneInsetProvider <NSObject>

@required
- (CGFloat)getTopInset;

@required
- (CGFloat)getBottomInset;

@required
- (CGFloat)getPlaneBulletMaxHeight;

@required
- (CGFloat)getPlaneBulletMinHeight;

@end
