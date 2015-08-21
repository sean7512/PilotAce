//
//  AboutScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 4/3/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "AboutScene.h"
#import "PilotAceAppDelegate.h"
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "LabelButton.h"
#import "SettingsScene.h"

@interface AboutScene()

@property (strong, nonatomic, readonly) SKScene *sceneOrigin;
@property (strong, nonatomic, readonly) NSString *originBackText;

@end

@implementation AboutScene

- (id)initWithSize:(CGSize)size withSettingsOrigin:(SKScene *)scene withSettingsBackText:(NSString *)originBackText {
    if (self = [super initWithSize:size]) {
        _sceneOrigin = scene;
        _originBackText = originBackText;
    }

    return self;
}

+ (id)createWithSize:(CGSize)size withSettingsOrigin:(SKScene *)scene withSettingsBackText:(NSString *)originBackText {
    AboutScene *about = [[AboutScene alloc] initWithSize:size withSettingsOrigin:scene withSettingsBackText:originBackText];
    [about populate];
    return about;
}

- (void)populate {
    self.physicsWorld.gravity = CGVectorMake(0, 0);

    [SceneTimeOfDayFactory setUpScene:self forTimeOfDayData:[DayTimeSceneData sharedInstance] withMovement:NO];

    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    CGFloat midX = CGRectGetMidX(self.frame);

    AboutScene * __weak w_self = self;
    LabelButton *settingsButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        if(w_self) {
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.7];
            SettingsScene *settings = [SettingsScene createWithSize:w_self.frame.size withBackScene:w_self.sceneOrigin withBackTitle:w_self.originBackText];
            [w_self.scene.view presentScene: settings transition: reveal];
        }
    }];
    settingsButton.text = @"< Settings";
    settingsButton.fontSize = 15*nodeScale;
    settingsButton.position = CGPointMake(settingsButton.frame.size.width/2 + 20*nodeScale, self.frame.size.height - settingsButton.frame.size.height/2 - 20*nodeScale);
    [self addChild:settingsButton];

    SKLabelNode *about = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    about.text = @"About";
    about.fontSize = 50*nodeScale;
    about.position = CGPointMake(midX, settingsButton.position.y - about.frame.size.height/2);
    [self addChild:about];

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    SKLabelNode *pilotAce = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    pilotAce.text = [NSString stringWithFormat:@"Pilot Ace - Version %@", version];
    pilotAce.fontSize = 20*nodeScale;
    pilotAce.position = CGPointMake(midX, about.position.y - 40*nodeScale);
    [self addChild:pilotAce];

    SKLabelNode *graphics = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    graphics.text = @"Graphics By Clara Kosanovich";
    graphics.fontSize = 20*nodeScale;
    graphics.position = CGPointMake(midX, pilotAce.position.y - 40*nodeScale);
    [self addChild:graphics];

    SKLabelNode *sounds = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    sounds.text = @"Sounds By Jamie Sweetland";
    sounds.fontSize = 20*nodeScale;
    sounds.position = CGPointMake(midX, graphics.position.y - 40*nodeScale);
    [self addChild:sounds];

    LabelButton *twitterButton = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/PilotAceiOS"]];
    }];
    twitterButton.text = @"Follow Us on Twitter";
    twitterButton.fontSize = 20*nodeScale;
    twitterButton.position = CGPointMake(midX, sounds.position.y - 40*nodeScale);
    [self addChild:twitterButton];
}

- (void)positionNode:(SKNode *)node atLeftEdge:(CGFloat)xPos atYPos:(CGFloat)yPos {
    CGFloat centeredX = xPos + (node.frame.size.width/2);
    node.position = CGPointMake(centeredX, yPos);
}

- (void)dealloc {
    _sceneOrigin = nil;
}

@end
