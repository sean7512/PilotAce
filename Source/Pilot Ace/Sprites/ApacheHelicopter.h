//
//  ApacheHelicopter.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 6/6/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Airplane.h"

@interface ApacheHelicopter : Airplane

+ (id)createForDraggable:(AllowableDragDirection)dragDirection;

@end
