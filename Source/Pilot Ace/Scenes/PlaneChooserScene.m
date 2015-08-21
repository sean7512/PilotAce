//
//  PlaneChooserScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "PlaneChooserScene.h"
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "LabelButton.h"
#import "PilotAceAppDelegate.h"
#import "PlaneOption.h"
#import "StandardPlane.h"
#import "StealthPlane.h"
#import "HerculesPlane.h"
#import "StratotankerPlane.h"
#import "RaptorPlane.h"
#import "BlackbirdPlane.h"
#import "MainLevelScene.h"
#import "ViewController.h"
#import "DifficultyLevel.h"
#import "DifficultyLevel.h"
#import "PlaneAchievementInfo.h"
#import "SKPageControl.h"

@interface PlaneChooserScene()

@property (strong, nonatomic) NSMutableArray *planeOptions;
@property (strong, nonatomic) SKNode *rootNode;
@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) SKPageControl *pageControl;
@property (assign, nonatomic) NSUInteger screenCount;
@property (assign, nonatomic) int currentScreen;

@end

@implementation PlaneChooserScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        _planeOptions = [NSMutableArray new];
        _rootNode = [SKNode new];
        _screenCount = 0;
        _currentScreen = 0;
    }

    return self;
}

+ (id)createWithSize:(CGSize)size {
    PlaneChooserScene *chooser = [[PlaneChooserScene alloc] initWithSize:size];
    [chooser populateScreen];
    return chooser;
}

- (void)didMoveToView:(SKView *)view {
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [self.view addGestureRecognizer:self.gestureRecognizer];
    [super didMoveToView:view];
}

- (void)willMoveFromView:(SKView *)view {
    if(self.gestureRecognizer) {
        [self.view removeGestureRecognizer:self.gestureRecognizer];
    }
    [super willMoveFromView:view];
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    } else if(recognizer.state == UIGestureRecognizerStateEnded) {
        [self snapScrollWithVelocity:[recognizer velocityInView:recognizer.view]];
    }
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = self.rootNode.position;
    CGPoint newPos = CGPointMake(position.x + translation.x, position.y);
    self.rootNode.position = newPos;
}

- (void)snapScrollWithVelocity:(CGPoint)velocity {
    float scrollDuration = 0.5;
    CGFloat screenWidth = self.frame.size.width;

    // determine direction
    if(velocity.x > 0) {
        // gesture was right, move backward
        if(self.currentScreen > 0) {
            self.currentScreen--;
        }
    } else {
        // gesture was left
        if(self.currentScreen+1 < self.screenCount) {
            self.currentScreen++;
        }
    }

    CGFloat newX = self.currentScreen * -(screenWidth);

    [self.rootNode removeAllActions];
    SKAction *moveTo = [SKAction moveToX:newX duration:scrollDuration];
    [moveTo setTimingMode:SKActionTimingEaseOut];
    [self.rootNode runAction:moveTo];
    self.pageControl.currentPage = self.currentScreen;
}


CGPoint mult(const CGPoint v, const CGFloat s) {
	return CGPointMake(v.x*s, v.y*s);
}

- (void)populateScreen {
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    PilotAceAppDelegate *appDelegate = (PilotAceAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat nodeScale = [appDelegate getNodeScale];

    [SceneTimeOfDayFactory setUpScene:self forTimeOfDayData:[DayTimeSceneData sharedInstance] withMovement:NO];

    PlaneChooserScene * __weak w_self = self;
    CGFloat midY = CGRectGetMidY(self.frame);

    int screenOffset = 0;
    NSArray *difficulties = [DifficultyLevel getAllDifficultyLevels];
    self.screenCount = difficulties.count;
    for(DifficultyLevel *level in difficulties) {
        SKLabelNode *sceneTitleLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        sceneTitleLabel.text = [NSString stringWithFormat:@"Choose a %@", level.displayName];
        sceneTitleLabel.fontSize = 30 * nodeScale;
        sceneTitleLabel.position = CGPointMake(CGRectGetMidX(self.frame) + (self.frame.size.width*screenOffset), self.frame.size.height-(30 * nodeScale));
        [self.rootNode addChild:sceneTitleLabel];

        NSMutableArray *levelOptions = [NSMutableArray new];
        for (PlaneAchievementInfo *planeAchievement in level.planeAchievementInfoList) {
            PlaneOption *option = [PlaneOption createForPlane:planeAchievement.planeGenerator() withTouchDownCallback:^{
                PlaneChooserScene *sw_self = w_self;
                if(!sw_self) {
                    return;
                }

                [sw_self startGameForPlane:planeAchievement.planeGenerator() forDifficultyLevel:level];
            } withNotUnlockedMessage:planeAchievement.howToUnlock];
            [option setScale:nodeScale];
            if(!planeAchievement.unlockChecker()) {
                // not unlocked
                [option hideOption];
            }
            [self.rootNode addChild:option];
            [levelOptions addObject:option];
        }
        
        // center plane options
        if(levelOptions.count == 6) {
            // 2 rows of 3
            NSRange topRowRange;
            topRowRange.location = 0;
            topRowRange.length = 3;
            [self centerShapeNodesHorizontally:[levelOptions subarrayWithRange:topRowRange] atYPos:midY+65*nodeScale atScreenMultiplier:screenOffset];

            NSRange bottomRowRange;
            bottomRowRange.location = 3;
            bottomRowRange.length = 3;
            [self centerShapeNodesHorizontally:[levelOptions subarrayWithRange:bottomRowRange] atYPos:midY-50*nodeScale atScreenMultiplier:screenOffset];
        } else if(levelOptions.count == 3) {
            // 1 row of 3
            [self centerShapeNodesHorizontally:levelOptions atYPos:midY atScreenMultiplier:screenOffset];
        }
        [self.planeOptions addObjectsFromArray:levelOptions];
        screenOffset++;
    }

    self.pageControl = [SKPageControl createWithTotalPageSize:self.screenCount];
    CGFloat pageControlWidth = [self.pageControl getSize].width;
    self.pageControl.position = CGPointMake(CGRectGetMidX(self.frame) - pageControlWidth/2 + 7.5*nodeScale, 35*nodeScale);
    [self addChild:self.pageControl];

    self.rootNode.position = CGPointZero;
    [self addChild:self.rootNode];
}

- (void)centerShapeNodesHorizontally:(NSArray *)shapeNodes atYPos:(CGFloat)yPos atScreenMultiplier:(NSUInteger)multiplier {
    CGFloat totalNodeWidth = 0;
    for (SKShapeNode *node in shapeNodes) {
        totalNodeWidth += node.frame.size.width;
    }

    CGFloat optionGap = (self.frame.size.width - totalNodeWidth)/(shapeNodes.count+1);

    CGFloat nextXStart = optionGap + (self.frame.size.width * multiplier);
    for (SKShapeNode *node in shapeNodes) {
        CGFloat halfNodeWidth = node.frame.size.width/2;
        node.position = CGPointMake(nextXStart+halfNodeWidth, yPos);
        nextXStart = node.position.x + halfNodeWidth + optionGap;
    }
}

- (void)startGameForPlane:(Airplane *)plane forDifficultyLevel:(DifficultyLevel *)level {
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_STARTING_NOTIFICATION object:self userInfo:nil];
    SKTransition *reveal = [SKTransition crossFadeWithDuration:0.7];
    MainLevelScene *mainLevel = [MainLevelScene createWithSize:self.size forPlane:plane forDiffucultyLebel:level];
    [self.scene.view presentScene: mainLevel transition: reveal];
}

- (void)removeFromParent {
    for(PlaneOption *option in self.planeOptions) {
        [option removeFromParent];
    }
    [self.planeOptions removeAllObjects];
    [super removeFromParent];
}

@end
