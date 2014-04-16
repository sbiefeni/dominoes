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
#import "GameKitHelper.h"

ADBannerView *adView;
int iHeight;
int iWidth;
BOOL bOnTop;
GKLocalPlayer *gcPlayer;
BOOL showingLeaderboard;

@interface domViewController () <ADBannerViewDelegate>

@end

@implementation domViewController{
    
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
     [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showLeaderBoard:(BOOL)shouldShowLeaderboard{
    showingLeaderboard=true;
    [self showLeaderboardAndAchievements:shouldShowLeaderboard];
}


-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    // Init the following view controller object.
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    // Set self as its delegate.
    gcViewController.gameCenterDelegate = self;
    
    // Depending on the parameter, show either the leaderboard or the achievements.
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = @"300hs";
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    // Finally present the view controller.
    [self presentViewController:gcViewController animated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    //[super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];

    //[[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    
}

- (void)showAuthenticationViewController
{
    GameKitHelper *gameKitHelper =
    [GameKitHelper sharedGameKitHelper];
    
    [self presentViewController:
     gameKitHelper.authenticationViewController
                                         animated:YES
                                       completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+(void)setAdView:(BOOL)showAd ShowOnTop:(BOOL)onTop ChooseRandom:(BOOL)useRandom{
    
    //following commented code to randomize between top and bottom
//    int rand = arc4random() % 4;
//    if (rand=0) {
//
//    }
        if(bannerIsLoaded){
        
        if (showAd) {
            BOOL blOnTop;
            if(useRandom){
                if([clsCommon getRanInt:0 maxNumber:1]==0){
                    blOnTop=NO;
                }
                else {
                    blOnTop=YES;
                }
            }
            else{
                blOnTop=onTop;
            }

            if (blOnTop) {
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
        //bannerIsVisible=showAd;
    }else{
        [adView setAlpha:0];
        bannerIsVisible=NO;
        ceilingOn=0;
        floorOn=1;
    }
}
//-(void)showLeaderBoard:(BOOL)shouldShowLeaderboard{
//    domViewController *dv;
//    [dv showLeaderboardAndAchievements:shouldShowLeaderboard];
//    
//}



- (void)viewDidLoad
{
    if(showingLeaderboard){
        return;
    }
    [super viewDidLoad];
    iHeight=CGRectGetHeight(self.view.bounds);
    iWidth=CGRectGetWidth(self.view.bounds);
    //CGFloat width =
    //CGFloat height = CGRectGetHeight(self.view.bounds);
    
    gcPlayer=[[GKLocalPlayer alloc]init];
    NSLog(@"Number of friends:%i", (int)gcPlayer.friends.count);
    
    CGRect aRect=CGRectMake(0, CGRectGetHeight(self.view.bounds)-iWidth==320? 50:66, iWidth, iWidth==320? 50:66);
//    aRect.origin.x =0;
//    aRect.origin.y = CGRectGetHeight(self.view.bounds)-50;
    //self.canDisplayBannerAds=YES;
    
    adView=[[ADBannerView alloc]initWithFrame:aRect];
    adView.delegate=self;
    [adView setAlpha:0];
    [self.view addSubview:adView];
    
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

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    //hide the ad banner as error detected
    [domViewController setAdView:NO ShowOnTop:NO ChooseRandom:NO];
    //show the error in NSLog
    NSLog(@"Failed to receive banner with error '%@'",error.description);
    bannerIsLoaded=NO;
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    bannerIsLoaded=YES;
}

//- (void)keyDown:(nse *)theEvent {
//    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
//}

-(void) swipeRecognized: (UISwipeGestureRecognizer*) swipe{

    int tmpDirection=0;
    
switch (swipe.direction) {
    case UISwipeGestureRecognizerDirectionLeft:
        NSLog(@"swiped Left");
        if (player.lastDirection != right){
            tmpDirection = left;
        }else{
            tmpDirection = right;
        }
        break;

    case UISwipeGestureRecognizerDirectionRight:
        if (player.lastDirection != left) {
            tmpDirection = right;
        }else{
            tmpDirection = left;
        }
        NSLog(@"swipe right");
        break;
        
    case UISwipeGestureRecognizerDirectionUp:
        if (player.lastDirection != down) {
            tmpDirection = up;
        }else{
            tmpDirection = down;
        }
        NSLog(@"swiped Up");
        break;
        
    case UISwipeGestureRecognizerDirectionDown:
       if (player.lastDirection != up) {
           tmpDirection = down;
       }else{
           tmpDirection = up;
       }
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
