//
//  MultiOptionSelect.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ActionableNode.h"

typedef void(^SelectedOptionChangeListener)(id);
typedef enum {
#ifndef TVOS
    SlideOutOptionSelect,
#endif
    ToggleOptionSelect
} OptionSelectMode;

@interface MultiOptionSelect : SKNode <ActionableNode>

/*!
 Allocs and inits the select with the given options.  The first option in the array is the default selection.
 @param label The label text for the select option.
 @param options The list of options this select is for. The description method will be used as the display string.
 @param changeListener The listener to call when the selected option changes.
 @return An initialized select control for use in a SKScene.
 */
+ (id)createWithLabel:(NSString *)label withOptions:(NSArray *)options withSelectedValueChangeListener:(SelectedOptionChangeListener)changeListener;

@property (strong, nonatomic) id selectedOption;
@property (assign, nonatomic) OptionSelectMode optionSelectMode;

@end
