//
//  domViewController.m
//  dominoes
//
//  Created by Stefano Biefeni on 2014-03-08.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domViewController.h"
#import "domMenuScene.h"
#import "clsPlayer.h"
#import "clsCommon.h"

@interface domViewController ()

@end

@implementation domViewController{}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.canDisplayBannerAds=NO;
    
    // Configure the view.
    //SKView * skView = (SKView *)self.view;
    SKView * skView = (SKView*)self.originalContentView;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    //self.removeFromParentViewController;
    
    // Create and configure the scene.
    SKScene * scene = [domMenuScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;

    //add in the gesture recognizers
    UISwipeGestureRecognizer* swipeGesture =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeGesture];
    
    swipeGesture =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeGesture];
    
    swipeGesture =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeGesture];
    
    swipeGesture =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeGesture];

    // Present the Menu scene
    [skView presentScene:scene];
}

//following function called by the iAds if user clicks the ad and ad pops up
-(void)viewWillDisappear:(BOOL)animated
{
    //pause the game
    adsShowing=YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    // Advert has been dismissed. Resume paused activities
    adsShowing=NO;
}

//- (void)keyDown:(nse *)theEvent {
//    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
//}

-(void) swipeRecognized: (UISwipeGestureRecognizer*) swipe{

    int tmpDirection=0;
    
switch (swipe.direction) {
    case UISwipeGestureRecognizerDirectionLeft:
        NSLog(@"swiped Left");
        tmpDirection = left;
        break;

    case UISwipeGestureRecognizerDirectionRight:
        tmpDirection = right;
        NSLog(@"swipe right");
        break;
        
    case UISwipeGestureRecognizerDirectionUp:
        tmpDirection = up;
        NSLog(@"swiped Up");
        break;
        
    case UISwipeGestureRecognizerDirectionDown:
        tmpDirection = down;
        NSLog(@"swiped Down");
        break;
        
        defaut:
        break;
    };

    player.curDirection = tmpDirection;

}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
