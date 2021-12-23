//
//  HerculesPlane.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/4/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "Airplane.h"

@interface HerculesPlane : Airplane

+ (id)createForDraggable:(AllowableDragDirection)dragDirection;

@end
