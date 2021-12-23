//
//  DistanceUtils.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/4/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "DistanceUtils.h"

@implementation DistanceUtils

+ (int64_t)getIntScore:(float)score {
    int64_t intScore = (int64_t)(score * 1000.0f);
    return intScore;
}

+ (float)getFloatScore:(int64_t)score {
    float floatScore = (float)(score / 1000.0f);
    return floatScore;
}

@end
