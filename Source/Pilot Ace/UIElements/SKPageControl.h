//
//  SKPageControl.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 7/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKPageControl : SKNode

+ (SKPageControl *)createWithTotalPageSize:(NSUInteger)totalPages;
- (CGSize)getSize;

@property (assign, nonatomic, readonly) NSUInteger totalPages;
@property (assign, nonatomic) NSUInteger currentPage;

@end
