//
//  RaptorPlane.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/7/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Airplane.h"

@interface RaptorPlane : Airplane

+ (id)createForDraggable:(AllowableDragDirection)dragDirection;

@end
