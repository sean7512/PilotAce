//
//  SKPageControl.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 7/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "SKPageControl.h"
#import "PilotAceAppDelegate.h"

@interface SKPageControl()

@property (strong, nonatomic) NSMutableArray *pageIndicators;
@property (strong, nonatomic) UIColor *activeColor;
@property (strong, nonatomic) UIColor *inActiveColor;

@end

@implementation SKPageControl

static int const kMinPageCount = 1;
static int const kFirstPage = 0;
static CGFloat const kIndicatorDiameter = 15;
static CGFloat const kIndicatorSpacing = 25;

- (id)initWithTotalPageSize:(NSUInteger)totalPages {
    self = [super init];
    if(self) {
        _totalPages = (totalPages > kMinPageCount) ? totalPages : kMinPageCount;
        _currentPage = kFirstPage;
        _pageIndicators = [NSMutableArray arrayWithCapacity:_totalPages];
        _activeColor = [UIColor whiteColor];
        _inActiveColor = [UIColor grayColor];
    }
    return self;
}

+ (SKPageControl *)createWithTotalPageSize:(NSUInteger)totalPages {
    SKPageControl *pageControl = [[SKPageControl alloc] initWithTotalPageSize:totalPages];
    [pageControl initializeContent];
    return pageControl;
}

- (void)initializeContent {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    for(int i=0; i<self.totalPages; i++) {
        SKShapeNode *indicator = [SKShapeNode node];
        indicator.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(i*kIndicatorSpacing*nodeScale, 0, kIndicatorDiameter*nodeScale, kIndicatorDiameter*nodeScale)].CGPath;
        indicator.fillColor = self.inActiveColor;
        indicator.strokeColor = [UIColor blackColor];
        [self addChild:indicator];

        self.pageIndicators[i] = indicator;
    }

    self.currentPage = kFirstPage;
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    if(currentPage < kFirstPage || currentPage > self.totalPages-1) {
        // invalid, do nothing
        return;
    }

    // turn off old page light
    SKShapeNode *indicator = self.pageIndicators[self.currentPage];
    indicator.fillColor = self.inActiveColor;
    //indicator.strokeColor = self.inActiveColor;

    // turn on new page light
    indicator = self.pageIndicators[currentPage];
    indicator.fillColor = self.activeColor;
    //indicator.strokeColor = self.activeColor;

    // set
    _currentPage = currentPage;
}

- (CGSize)getSize {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    CGFloat width = kIndicatorDiameter*nodeScale*self.totalPages + (kIndicatorSpacing*nodeScale*(self.totalPages-1));
    return CGSizeMake(width, kIndicatorDiameter*nodeScale);
}

- (void)dealloc {
    for (SKShapeNode *indicator in self.pageIndicators) {
        [indicator removeFromParent];
    }
    [self.pageIndicators removeAllObjects];
}

@end
