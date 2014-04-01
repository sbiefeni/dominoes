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

ADBannerView *adView;
int iHeight;
int iWidth;
BOOL bOnTop;

@interface domViewController ()

@end

@implementation domViewController{
    
}

//(float)getRanFloat:(float)smallNumber and:(float)bigNumber {

+(void)setAdView:(BOOL)showAd ShowOnTop:(BOOL)onTop{
    
    //following commented code to randomize between top and bottom
//    int rand = arc4random() % 4;
//    if (rand=0) {
//        <#statements#>
//    }
    if (showAd) {
        if (onTop) {
            ceilingOn = 1;
            floorOn = 0;
            adView.frame=CGRectMake(0,0, iWidth, iWidth==320? 50:66);
        }
        else{
            ceilingOn = 0;
            floorOn = 1;
            adView.frame=CGRectMake(0,iHeight-50, iWidth, iWidth==320? 50:66);
        }
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:showAd==YES?3:0];
    [adView setAlpha:showAd==YES?1:0];
    
    [UIView commitAnimations];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    iHeight=CGRectGetHeight(self.view.bounds);
    iWidth=CGRectGetWidth(self.view.bounds);
    //CGFloat width = 
    //CGFloat height = CGRectGetHeight(self.view.bounds);
    
    CGRect aRect;
    aRect.origin.x =0;
    aRect.origin.y = CGRectGetHeight(self.view.bounds)-50;
    //self.canDisplayBannerAds=YES;
    
    adView=[[ADBannerView alloc]initWithFrame:aRect];
    [adView setAlpha:0];
    [self.view addSubview:adView];
    
    // Configure the view.
    //SKView * skView = (SKView *)self.view;
    SKView * skView = (SKView*)self.originalContentView;
    skView.showsFPS = NO;
    skView.showsNodeCount = YES;
    
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
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    //hide the ad banner as error detected
    [domViewController setAdView:NO ShowOnTop:NO];
    //show the error in NSLog
    NSLog(@"Failed to receive banner with error '%@'",error.description);
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


    player.lastDirection = player.curDirection;
    player.curDirection = tmpDirection;
 
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    //} else {
        //return UIInterfaceOrientationMaskAll;
    //}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
