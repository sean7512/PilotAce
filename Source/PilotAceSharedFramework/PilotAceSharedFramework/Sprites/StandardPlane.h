//
//  StandardPlane.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/12/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Airplane.h"

@interface StandardPlane : Airplane

+ (id)createForDraggable:(AllowableDragDirection)dragDirection;

@end
