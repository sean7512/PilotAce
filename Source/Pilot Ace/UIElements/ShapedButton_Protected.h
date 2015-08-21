//
//  ShapedButton_Protected.h
//  Pilot Ace
//
//  Created by Sean Kosanovich on 6/5/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "ShapedButton.h"

@interface ShapedButton ()

- (id)initWithTouchUpInsideCallback:(TouchUpInsideCallback)touchUp withTouchDownInsideCallback:(TouchDownInsideCallback)touchDown;

/*!
 * Fired before the the TouchUpInside callback is fired.  This allows subclasses a chance to prevent the default callback from happening.
 * @return YES if the callback should be fired; NO otherwise.
 */
- (BOOL)shouldFireCallback;

@end
