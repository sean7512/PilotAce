//
//  PlaneOption.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "PlaneOption.h"
#import "Airplane.h"
#import "GameSettingsController.h"

@interface PlaneOption()

@property (strong, nonatomic) Airplane *plane;
@property (strong, nonatomic) SKLabelNode *questionMark;
@property (strong, nonatomic) NSString *notUnlockedMsg;
@property (assign, nonatomic) BOOL optionHidden;

@end

@implementation PlaneOption

static const CGFloat STANDARD_OPTION_HEIGHT = 45;

- (id)initWithPlane:(Airplane *)plane withTouchDownCallback:(TouchUpInsideCallback)callback withNontUnlockedMsg:(NSString *)msg {
    self = [super initWithTouchUpInsideCallback:callback withTouchDownInsideCallback:NULL];
    if(self) {
        _plane = plane;
        _notUnlockedMsg = msg;
        _optionHidden = NO;
    }
    return self;
}

+ (id)createForPlane:(Airplane *)plane withTouchDownCallback:(TouchDownInsideCallback)callback withNotUnlockedMessage:(NSString *)msg {
    PlaneOption *option = [[PlaneOption alloc] initWithPlane:plane withTouchDownCallback:callback withNontUnlockedMsg:msg];
    [option populate];
    return option;
}

- (void)populate {
    self.userInteractionEnabled = YES;

    // create blue circle with a 25% buffer
    CGMutablePathRef circle = CGPathCreateMutable();
    CGPathAddArc(circle, NULL, 0, 0, STANDARD_OPTION_HEIGHT*1.25, 0, M_PI*2, YES);
    self.path = circle;
    self.lineWidth = 0;
    self.fillColor = [SKColor blueColor];
    CGPathRelease(circle);

    CGFloat currScale = 1.0;
    while(self.plane.size.width/2 > STANDARD_OPTION_HEIGHT || self.plane.size.height/2 > STANDARD_OPTION_HEIGHT) {
        currScale -= 0.1;
        [self.plane setScale:currScale];
    }

    self.plane.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:self.plane];

    self.questionMark = [SKLabelNode new];
    self.questionMark.fontColor = [SKColor whiteColor];
    self.questionMark.fontName = GAME_FONT;
    self.questionMark.fontSize = 56;
    self.questionMark.text = @"?";
    self.questionMark.zPosition = -1;
    self.questionMark.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - self.questionMark.frame.size.height/2 + 7);
    [self addChild:self.questionMark];
}

- (void)hideOption {
    self.plane.zPosition = -1;
    self.questionMark.zPosition = 0;
    self.optionHidden = YES;
}

- (BOOL)shouldFireCallback {
    if(self.optionHidden) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Locked" message:self.notUnlockedMsg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // do nothing
        }];
        [alert addAction:okAction];
        [[GameSettingsController sharedInstance].alertDelegate presentAlertController:alert];
    }
    return !self.optionHidden;
}

- (void)removeFromParent {
    [self.plane removeFromParent];
    [self.questionMark removeFromParent];
    self.plane = nil;
    self.questionMark = nil;
    [super removeFromParent];
}

@end
