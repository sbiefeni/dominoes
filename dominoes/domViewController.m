//
//  domViewController.m
//  dominoes
//
//  Created by Stefano Biefeni on 2014-03-08.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domViewController.h"
#import "domMyScene.h"

@implementation domViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [domMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    UISwipeGestureRecognizer* swipeLeft =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer* swipeRight =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    // Present the scene.
    [skView presentScene:scene];
}

-(void) swipeRecognized: (UISwipeGestureRecognizer*) swipe{
    
switch (swipe.direction) {
    case UISwipeGestureRecognizerDirectionLeft:
        NSLog(@"swiped Left");
        break;

    case UISwipeGestureRecognizerDirectionRight:
        NSLog(@"swipe right");
        break;
        
    case UISwipeGestureRecognizerDirectionUp:
        NSLog(@"swiped Up");
        break;
        
    case UISwipeGestureRecognizerDirectionDown:
        NSLog(@"swiped Down");
        break;
        
        defaut:
        break;
    };
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
