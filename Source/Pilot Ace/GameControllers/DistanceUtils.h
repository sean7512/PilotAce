//
//  DistanceUtils.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/4/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DistanceUtils : NSObject

/*!
 Converts a score in decimal form to an int64_t.
 @param score The decimal score to convert.
 @return The equivalent score represented as an int64_t.
 */
+ (int64_t)getIntScore:(float)score;

/*!
 Converts a score in int64_t form to a user displayable decimal.
 @param score The int64_t score to convert.
 @return The equivalent score represented as a user displayable decimal.
 */
+ (float)getFloatScore:(int64_t)score;

@end
