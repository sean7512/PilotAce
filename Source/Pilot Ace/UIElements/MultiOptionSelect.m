//
//  MultiOptionSelect.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "MultiOptionSelect.h"
#import "PilotAceAppDelegate.h"
#import "LabelButton.h"

@interface MultiOptionSelect()

@property (copy, readonly) SelectedOptionChangeListener changeListener;
@property (strong, nonatomic, readonly) NSString *label;
@property (strong, nonatomic, readonly) NSArray *options;
@property (strong, nonatomic, readonly) SKNode *optionButtons;
@property (strong, nonatomic, readonly) LabelButton *selectedOptionLabel;
@property (assign, nonatomic) CGFloat labelEndX;

@end

@implementation MultiOptionSelect

static SKColor *_labelColor;
static SKColor *_optionsColor;
static const CGFloat FONT_SIZE = 25;
static const CGFloat PADDING = 10;

+ (id)createWithLabel:(NSString *)label withOptions:(NSArray *)options withSelectedValueChangeListener:(SelectedOptionChangeListener)changeListener {
    MultiOptionSelect *select = [[MultiOptionSelect alloc] initWithLabel:label withOptions:options withSelectedValueChangeListener:changeListener];
    [select populate];
    return select;
}

- (id)initWithLabel:(NSString *)label withOptions:(NSArray *)options withSelectedValueChangeListener:(SelectedOptionChangeListener)changeListener {
    self = [super init];
    if(self) {
        _labelColor = [SKColor whiteColor];
        _optionsColor = [SKColor blueColor];
        _optionSelectMode = ToggleOptionSelect;

        _label = label;
        _options = options;
        _changeListener = changeListener;
        _selectedOption = _options[0];
        _optionButtons = [SKNode new];
        MultiOptionSelect * __weak w_self = self;
        _selectedOptionLabel = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
            if(w_self) {
                if(w_self.optionSelectMode == SlideOutOptionSelect) {
                    [w_self.selectedOptionLabel removeFromParent];
                    [w_self addChild:w_self.optionButtons];
                } else if(w_self.optionSelectMode == ToggleOptionSelect) {
                    NSUInteger nextIndex = [w_self.options indexOfObject:w_self.selectedOption] + 1;
                    if(nextIndex == w_self.options.count) {
                        // start back at the beginning
                        w_self.selectedOption = w_self.options[0];
                    } else {
                        w_self.selectedOption = w_self.options[nextIndex];
                    }
                    if(w_self.changeListener) {
                        w_self.changeListener(w_self.selectedOption);
                    }
                } else {
                    NSLog(@"Unknown option select mode: %i", w_self.optionSelectMode);
                }
            }
        }];
        _labelEndX = 0;
    }
    return self;
}

- (void)populate {
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    SKLabelNode *label = [[SKLabelNode alloc] initWithFontNamed:GAME_FONT];
    label.fontColor = _labelColor;
    label.fontSize = FONT_SIZE*nodeScale;
    label.text = self.label;
    label.position = CGPointMake(0, 0);
    [self addChild:label];
    self.labelEndX = label.position.x + label.frame.size.width/2;

    self.selectedOptionLabel.fontColor = _optionsColor;
    self.selectedOptionLabel.fontSize = FONT_SIZE*nodeScale;
    self.selectedOptionLabel.text = [self.selectedOption description];
    [self adjustSelectedOptionLabelPosition];
    [self addChild:self.selectedOptionLabel];

    CGFloat lastXEnd = 0;
    MultiOptionSelect * __weak w_self = self;
    for(id item in self.options) {
        LabelButton *b = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
            if(w_self) {
                w_self.selectedOption = item;
                [w_self.optionButtons removeFromParent];
                [w_self addChild:w_self.selectedOptionLabel];
                if(w_self.changeListener) {
                    w_self.changeListener(item);
                }
            }
        }];
        b.fontSize = FONT_SIZE*nodeScale;
        b.text = [item description];
        if(lastXEnd == 0) {
            b.position = CGPointMake(0, 0);
        } else {
            b.position = CGPointMake(lastXEnd + PADDING + b.frame.size.width/2, 0);
        }
        lastXEnd += b.frame.size.width;
        [self.optionButtons addChild:b];
    }
    self.optionButtons.position = CGPointMake(self.selectedOptionLabel.position.x, 0);
}

- (void)adjustSelectedOptionLabelPosition {
    CGFloat centeredX = self.labelEndX + PADDING + self.selectedOptionLabel.frame.size.width/2;
    self.selectedOptionLabel.position = CGPointMake(centeredX, 0);
}

- (void)setSelectedOption:(id)option {
    if([self.options containsObject:option]) {
        _selectedOption = option;
        self.selectedOptionLabel.text = [option description];
        [self adjustSelectedOptionLabelPosition];
    } else {
        NSLog(@"Cannot make given option (%@) the selected value; it does not exist!", option);
    }
}

- (void)dealloc {
    _changeListener = NULL;
}

@end
