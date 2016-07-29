//
//  PlaneChooserScene.m
//  Pilot Ace
//
//  Created by Sean Kosanovich on 3/14/14.
//  Copyright (c) 2014 Sean Kosanovich. All rights reserved.
//

#import "PlaneChooserScene.h"
#import <GameController/GameController.h>
#import "SceneTimeOfDayFactory.h"
#import "DayTimeSceneData.h"
#import "LabelButton.h"
#import "GameSettingsController.h"
#import "PlaneOption.h"
#import "StandardPlane.h"
#import "StealthPlane.h"
#import "HerculesPlane.h"
#import "StratotankerPlane.h"
#import "RaptorPlane.h"
#import "BlackbirdPlane.h"
#import "MainLevelScene.h"
#import "MainMenuScene.h"
#import "DifficultyLevel.h"
#import "DifficultyLevel.h"
#import "PlaneAchievementInfo.h"
#import "SKPageControl.h"
#import "NavigableScene_Protected.h"

@interface PlaneChooserScene()

@property (strong, nonatomic, readonly) SKScene *previousScene;
@property (strong, nonatomic) NSMutableArray<PlaneOption *> *planeOptions;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSMutableArray<NSArray<SKNode<ActionableNode> *> *> *> *navigableNodesByPage;
@property (strong, nonatomic) SKNode *rootNode;
@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) SKPageControl *pageControl;
@property (assign, nonatomic) NSUInteger screenCount;
@property (assign, nonatomic) int currentScreen;

@end

@implementation PlaneChooserScene

- (id)initWithSize:(CGSize)size withPreviousScene:(SKScene *)prevSecene {
    if (self = [super initWithSize:size]) {
        _planeOptions = [NSMutableArray new];
        _navigableNodesByPage = [NSMutableDictionary new];
        _rootNode = [SKNode new];
        _screenCount = 0;
        _currentScreen = 0;
        _previousScene = prevSecene;

        [[GameSettingsController sharedInstance].menuHandlerDelegate setUseNativeMenuHandling:NO];
    }

    return self;
}

+ (id)createWithSize:(CGSize)size withPreviousScene:(SKScene *)prevSecene {
    PlaneChooserScene *chooser = [[PlaneChooserScene alloc] initWithSize:size withPreviousScene:prevSecene];
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

- (void)setupController:(GCController *)controller {
    [super setupController:controller];

    PlaneChooserScene * __weak w_self = self;
    [controller setControllerPausedHandler:^(GCController * _Nonnull controller) {
        if(w_self) {
            SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.7];
            [w_self.scene.view presentScene: w_self.previousScene transition: reveal];
        }
    }];
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if([GameSettingsController sharedInstance].mustUseController || [GameSettingsController sharedInstance].controller) {
        // controller will control the plane selection
        return;
    }

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
    CGFloat nodeScale = [[GameSettingsController sharedInstance].nodeScaleDelegate getNodeScaleSize];

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
            } withNotUnlockedMessage:planeAchievement.howToUnlock withAlwaysTouchDownCallback:^{
                PlaneChooserScene *sw_self = w_self;
                if(!sw_self) {
                    return;
                }

                [sw_self cleanupControllerHandlers];
            }];
            [option setScale:nodeScale];
            if(!planeAchievement.unlockChecker()) {
                // not unlocked
                [option hideOption];
            }
            [self.rootNode addChild:option];
            [levelOptions addObject:option];
        }

        // if we must use a controller (tvOS only) then space out the menu items, we have lots of room
        BOOL mustUseController = [GameSettingsController sharedInstance].mustUseController;
        BOOL hasController = mustUseController || [GameSettingsController sharedInstance].controller;

        // may be used if there is a controller
        LabelButton *nextPage = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
            w_self.navigableNodes = w_self.navigableNodesByPage[@(screenOffset+1)];
            w_self.selectedNode = w_self.navigableNodes[0][1]; // [0][0] is the prev button, dont make it selected

            // go to next page
            float scrollDuration = 0.5;
            CGFloat screenWidth = w_self.frame.size.width;
            CGFloat newX = (screenOffset+1) * -(screenWidth);

            [w_self.rootNode removeAllActions];
            SKAction *moveTo = [SKAction moveToX:newX duration:scrollDuration];
            [moveTo setTimingMode:SKActionTimingEaseOut];
            [w_self.rootNode runAction:moveTo];
            w_self.pageControl.currentPage = (screenOffset+1);
        }];
        nextPage.text = @">";
        nextPage.fontSize = 65*nodeScale;
        nextPage.fontColor = [UIColor blueColor];
        nextPage.position = CGPointMake(self.frame.size.width*(screenOffset+1) - (25*nodeScale), midY-(nextPage.frame.size.height/2));
        if(screenOffset < difficulties.count-1 && hasController) {
            [self.rootNode addChild:nextPage];
        }

        LabelButton *previousPage = [LabelButton createWithFontNamed:GAME_FONT withTouchEventCallback:^{
            w_self.navigableNodes = w_self.navigableNodesByPage[@(screenOffset-1)];
            if(screenOffset == 1) {
                w_self.selectedNode = w_self.navigableNodes[0][0];
            } else {
                w_self.selectedNode = w_self.navigableNodes[0][1]; // [0][0] is the prev button, dont make it selected
            }

            // go to prev page
            float scrollDuration = 0.5;
            CGFloat screenWidth = w_self.frame.size.width;
            CGFloat newX = (screenOffset-1) * -(screenWidth);

            [w_self.rootNode removeAllActions];
            SKAction *moveTo = [SKAction moveToX:newX duration:scrollDuration];
            [moveTo setTimingMode:SKActionTimingEaseOut];
            [w_self.rootNode runAction:moveTo];
            w_self.pageControl.currentPage = (screenOffset-1);
        }];
        previousPage.text = @"<";
        previousPage.fontSize = 65*nodeScale;
        previousPage.fontColor = [UIColor blueColor];
        previousPage.position = CGPointMake(self.frame.size.width*(screenOffset+1) - self.frame.size.width + (25*nodeScale), midY-(nextPage.frame.size.height/2));
        if(screenOffset > 0 && hasController) {
            [self.rootNode addChild:previousPage];
        }

        // prepare to store the navigable nodes by page
        NSNumber *pageNumber = [NSNumber numberWithInt:screenOffset];
        NSMutableArray<NSArray<SKNode<ActionableNode> *> *> *navigableNodesForPage = [NSMutableArray new];

        // center plane options
        if(levelOptions.count == 6) {
            // 2 rows of 3 options
            NSRange topRowRange;
            topRowRange.location = 0;
            topRowRange.length = 3;
            NSArray *topRow = [levelOptions subarrayWithRange:topRowRange];
            [self centerShapeNodesHorizontally:topRow atYPos:midY+(mustUseController ? 85 : 65)*nodeScale atScreenMultiplier:screenOffset];

            NSRange bottomRowRange;
            bottomRowRange.location = 3;
            bottomRowRange.length = 3;
            NSArray *bottomRow = [levelOptions subarrayWithRange:bottomRowRange];
            [self centerShapeNodesHorizontally:bottomRow atYPos:midY-(mustUseController ? 70 : 50)*nodeScale atScreenMultiplier:screenOffset];

            if(screenOffset == 0) {
                // no previous, just a next button
                [navigableNodesForPage addObject:[topRow arrayByAddingObject:nextPage]];
                [navigableNodesForPage addObject:[bottomRow arrayByAddingObject:nextPage]];
            } else if(screenOffset > 0 && screenOffset < self.screenCount-1) {
                // need both a previous and next button
                [navigableNodesForPage addObject:[@[previousPage] arrayByAddingObjectsFromArray:[topRow arrayByAddingObject:nextPage]]];
                [navigableNodesForPage addObject:[@[previousPage] arrayByAddingObjectsFromArray:[bottomRow arrayByAddingObject:nextPage]]];
            } else if(screenOffset > 0 && screenOffset == self.screenCount-1) {
                // just a previous button
                [navigableNodesForPage addObject:[@[previousPage] arrayByAddingObjectsFromArray:topRow]];
                [navigableNodesForPage addObject:[@[previousPage] arrayByAddingObjectsFromArray:bottomRow]];
            } else {
                // no nav buttons
                [navigableNodesForPage addObject:topRow];
                [navigableNodesForPage addObject:bottomRow];
            }
            self.navigableNodesByPage[pageNumber] = navigableNodesForPage;

        } else if(levelOptions.count == 3) {
            // 1 row of 3 options
            [self centerShapeNodesHorizontally:levelOptions atYPos:midY atScreenMultiplier:screenOffset];

            if(screenOffset == 0) {
                // no previous, just a next button
                [navigableNodesForPage addObject:[levelOptions arrayByAddingObject:nextPage]];
            } else if(screenOffset > 0 && screenOffset < self.screenCount-1) {
                // need both a previous and next button
                [navigableNodesForPage addObject:[@[previousPage] arrayByAddingObjectsFromArray:[levelOptions arrayByAddingObject:nextPage]]];
            } else if(screenOffset > 0 && screenOffset == self.screenCount-1) {
                // just a previous button
                [navigableNodesForPage addObject:[@[previousPage] arrayByAddingObjectsFromArray:levelOptions]];
            } else {
                // no nav buttons
                [navigableNodesForPage addObject:levelOptions];
            }
            self.navigableNodesByPage[pageNumber] = navigableNodesForPage;
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

    self.navigableNodes = self.navigableNodesByPage[@0];
    self.selectedNode = self.navigableNodes[0][0];
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
