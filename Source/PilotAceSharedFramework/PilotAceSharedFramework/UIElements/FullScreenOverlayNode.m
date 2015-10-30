//
//  FullScreenOverlayNode.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/6/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "FullScreenOverlayNode.h"

@interface FullScreenOverlayNode()

@property (strong, nonatomic) SKShapeNode *screenOutline;

@end

@implementation FullScreenOverlayNode

- (id)init {
    if (self = [super init]) {
        // nothing to init
    }
    return self;
}

+ (id)createForSceenWithSize:(CGSize)size {
    FullScreenOverlayNode *indicator = [[FullScreenOverlayNode alloc] init];
    [indicator populateScreenForSize:size];
    return indicator;
}

- (void)populateScreenForSize:(CGSize)size {
    // see-through overlay
    self.screenOutline = [SKShapeNode node];
    UIBezierPath *outlinePath = [[UIBezierPath alloc] init];
    [outlinePath moveToPoint:CGPointMake(0, 0)];
    [outlinePath addLineToPoint:CGPointMake(0.0, size.height)];
    [outlinePath addLineToPoint:CGPointMake(size.width, size.height)];
    [outlinePath addLineToPoint:CGPointMake(size.width, 0)];
    [outlinePath addLineToPoint:CGPointMake(0, 0)];
    self.screenOutline.path = outlinePath.CGPath;
    self.screenOutline.lineWidth = 1;
    self.screenOutline.strokeColor = self.screenOutline.fillColor = [[SKColor grayColor] colorWithAlphaComponent:0.5];
    self.screenOutline.antialiased = NO;
    [self addChild:self.screenOutline];
}

- (void)removeFromParent {
    /**
     * hack for 64-bit crash :(
     * http://stackoverflow.com/questions/22399278/sprite-kit-ios-7-1-crash-on-removefromparent
     */
    [self.screenOutline removeFromParent];
    self.screenOutline = nil;
    [super removeFromParent];
}

@end
