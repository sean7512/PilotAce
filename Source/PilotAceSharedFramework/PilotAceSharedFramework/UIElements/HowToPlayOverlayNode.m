//
//  HowToPlayOverlayNode.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/6/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "HowToPlayOverlayNode.h"
#import <GameController/GameController.h>
#import "FullScreenOverlayNode.h"
#import "LabelButton.h"
#import "GameSettingsController.h"
#import "ShapedButton.h"
#import "GameSettingsController.h"

@interface HowToPlayOverlayNode()

@property (weak, nonatomic) NSObject<PauseGameController> *pauseGameController;
@property (strong, nonatomic) ShapedButton *dragBoxNode;
@property (strong, nonatomic) ShapedButton *shootBoxNode;

@end

@implementation HowToPlayOverlayNode

- (id)initWithPauseGameController:(NSObject<PauseGameController> *)pauseGameController {
    self = [super init];
    if(self) {
        _pauseGameController = pauseGameController;
    }
    return self;
}

+ (id)createForScreenWithSize:(CGSize)size withPauseGameController:(NSObject<PauseGameController> *)pauseGameController {
    HowToPlayOverlayNode *howToPlayNode = [[HowToPlayOverlayNode alloc] initWithPauseGameController:pauseGameController];

    [howToPlayNode populateScreenForSize:size];
    howToPlayNode.userInteractionEnabled = YES;

    return howToPlayNode;
}

- (void)populateScreenForSize:(CGSize)size {
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

    FullScreenOverlayNode *fullScreenNode = [FullScreenOverlayNode createForSceenWithSize:size];
    [self addChild:fullScreenNode];

    NSString *movePlaneInstructions = @"Drag";
    NSString *shootInstructions = @"Tap to Shoot";
    BOOL hasController = [GameSettingsController sharedInstance].mustUseController || [GameSettingsController sharedInstance].controller;

    if(hasController) {
#ifdef TVOS
        if([GameSettingsController sharedInstance].controller.microGamepad) {
#else
        if(NO) {
#endif
            movePlaneInstructions = @"Touchpad";
            shootInstructions = @"Press Play/Pause Button to Shoot";
        } else if([GameSettingsController sharedInstance].controller.gamepad) {
            movePlaneInstructions = @"D-Pad";
            shootInstructions = @"Press X Button to Shoot";
        }
    }

    // plane movement
    self.dragBoxNode = [ShapedButton createWithTouchDownInsideEventCallBack:NULL];
    self.dragBoxNode.userInteractionEnabled = NO;
    UIBezierPath *dragBoxOutline = [[UIBezierPath alloc] init];
    [dragBoxOutline moveToPoint:CGPointMake(0, 0)];
    [dragBoxOutline addLineToPoint:CGPointMake(0, size.height)];
    [dragBoxOutline addLineToPoint:CGPointMake(130*nodeScale, size.height)];
    [dragBoxOutline addLineToPoint:CGPointMake(130*nodeScale, 0)];
    [dragBoxOutline addLineToPoint:CGPointMake(0, 0)];
    self.dragBoxNode.path = dragBoxOutline.CGPath;
    self.dragBoxNode.lineWidth = 1;
    self.dragBoxNode.strokeColor = [[SKColor redColor] colorWithAlphaComponent:0.3];
    self.dragBoxNode.fillColor = [[SKColor redColor] colorWithAlphaComponent:0.3];
    self.dragBoxNode.antialiased = NO;
    [self addChild:self.dragBoxNode];

    SKLabelNode *up = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    up.fontSize = 40*nodeScale;
    up.text = @"^";
    up.position = CGPointMake(65*nodeScale, (size.height/2) + 20*nodeScale);
    [self addChild:up];

    SKLabelNode *down = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    down.fontSize = 40*nodeScale;
    down.text = @"v";
    down.position = CGPointMake(65*nodeScale, (size.height/2) - 50*nodeScale);
    [self addChild:down];

    SKLabelNode *drag = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    drag.fontSize = 20*nodeScale;
    drag.text = movePlaneInstructions;
    drag.position = CGPointMake(65*nodeScale, (size.height/2));
    [self addChild:drag];

    // shooting
    self.shootBoxNode = [ShapedButton createWithTouchUpInsideCallBack:NULL];
    self.shootBoxNode.userInteractionEnabled = NO;
    UIBezierPath *shootBoxOutline = [[UIBezierPath alloc] init];
    [shootBoxOutline moveToPoint:CGPointMake(130*nodeScale, 0)];
    [shootBoxOutline addLineToPoint:CGPointMake(130*nodeScale, size.height)];
    [shootBoxOutline addLineToPoint:CGPointMake(size.width, size.height)];
    [shootBoxOutline addLineToPoint:CGPointMake(size.width, 0)];
    [shootBoxOutline addLineToPoint:CGPointMake(130*nodeScale, 0)];
    self.shootBoxNode.path = shootBoxOutline.CGPath;
    self.shootBoxNode.lineWidth = 1;
    self.shootBoxNode.strokeColor = [[SKColor blueColor] colorWithAlphaComponent:0.3];
    self.shootBoxNode.fillColor = [[SKColor blueColor] colorWithAlphaComponent:0.3];
    self.shootBoxNode.antialiased = NO;
    [self addChild:self.shootBoxNode];

    SKLabelNode *shoot = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    shoot.fontSize = 20*nodeScale;
    shoot.text = shootInstructions;
    shoot.position = CGPointMake((size.width+(130*nodeScale))/2, (size.height/2));
    [self addChild:shoot];

#ifdef TVOS
    if(hasController && [GameSettingsController sharedInstance].controller.microGamepad) {
        UIImage *image = [UIImage imageNamed:@"tvOSRemote" inBundle:[NSBundle bundleForClass:[HowToPlayOverlayNode class]] compatibleWithTraitCollection:nil];
        SKSpriteNode *tvosRemote = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImage:image]];

        tvosRemote.position = CGPointMake(size.width/2 - tvosRemote.size.width/2, size.height - 100*nodeScale);
        SKAction *rotateAction = [SKAction rotateToAngle:1.5708 duration:0.8];
        SKAction *rotateBackUpAction = [SKAction rotateToAngle:0 duration:0];
        SKAction *pauseAction = [SKAction waitForDuration:2];
        SKAction *repeatForever = [SKAction repeatActionForever:[SKAction sequence:@[rotateAction, pauseAction, rotateBackUpAction]]];
        [tvosRemote runAction:repeatForever];
        [self addChild:tvosRemote];

        SKLabelNode *tvRemoteText = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        tvRemoteText.fontSize = 20*nodeScale;
        tvRemoteText.text = @"Please turn the Apple TV remote sideways.";
        tvRemoteText.position = CGPointMake(size.width/2, tvosRemote.position.y - 50*nodeScale);
        [self addChild:tvRemoteText];
    }
#endif
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // no op
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // no op
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // no op
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.pauseGameController resumeGame];
}

- (void)removeFromParent {
    /**
      * hack for 64-bit crash :(
      * http://stackoverflow.com/questions/22399278/sprite-kit-ios-7-1-crash-on-removefromparent
      */
    [self.dragBoxNode removeFromParent];
    [self.shootBoxNode removeFromParent];
    self.dragBoxNode = nil;
    self.shootBoxNode = nil;
    [super removeFromParent];
}

@end
