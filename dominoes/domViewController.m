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


#define isRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}

#define REVMOB_ID           @"54bdc126adbec59c09b96903"

ADBannerView *adView;
int iHeight;
int iWidth;
BOOL bOnTop;
GKLocalPlayer *gcPlayer;
BOOL showingLeaderboard;



@interface domViewController () <ADBannerViewDelegate>

@property (nonatomic, strong)RevMobFullscreen *fullscreen;
@property (nonatomic, strong)RevMobBannerView *banner;
@property (nonatomic, strong)RevMobBanner *bannerWindow;






@end

@implementation domViewController{
    
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
     [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    //[super viewDidAppear:animated];

}


//------------------------------------------------------------------------------------------------------------//
//------- GameCenter Manager Delegate ------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - GameCenter Manager Delegate

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
        [self presentViewController:gameCenterLoginController animated:YES completion:^{
        NSLog(@"Finished Presenting Authentication Controller");
        }];
}

- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation {
    NSLog(@"GC Availabilty: %@", availabilityInformation);
    if ([[availabilityInformation objectForKey:@"status"] isEqualToString:@"GameCenter Available"]) {
           // statusDetailLabel.text = @"Game Center is online, the current player is logged in, and this app is setup.";
        gameCenterEnabled = true;
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error {
    NSLog(@"GCM Error: %@", error);
    //actionBarLabel.title = error.domain;
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedAchievement:(GKAchievement *)achievement withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Achievement: %@", achievement);
        //actionBarLabel.title = [NSString stringWithFormat:@"Reported achievement with %.1f percent completed", achievement.percentComplete];
    } else {
        NSLog(@"GCM Error while reporting achievement: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedScore:(GKScore *)score withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Score: %@", score);
        //actionBarLabel.title = [NSString stringWithFormat:@"Reported leaderboard score: %lld", score.value];
    } else {
        NSLog(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveScore:(GKScore *)score {
    NSLog(@"Saved GCM Score with value: %lld", score.value);
    //actionBarLabel.title = [NSString stringWithFormat:@"Score saved for upload to GameCenter."];
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveAchievement:(GKAchievement *)achievement {
    NSLog(@"Saved GCM Achievement: %@", achievement);
    //actionBarLabel.title = [NSString stringWithFormat:@"Achievement saved for upload to GameCenter."];
}


+(void)setAdView:(BOOL)showAd ShowOnTop:(BOOL)onTop ChooseRandom:(BOOL)useRandom{
    

    if(bannerIsLoaded && areAdsRemoved==0){
        
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
        floorOn=0;
    }
}
//-(void)showLeaderBoard:(BOOL)shouldShowLeaderboard{
//    domViewController *dv;
//    [dv showLeaderboardAndAchievements:shouldShowLeaderboard];
//    
//}



- (void)viewDidLoad
{
    [super viewDidLoad];
    iHeight=CGRectGetHeight(self.view.bounds);
    iWidth=CGRectGetWidth(self.view.bounds);
    //CGFloat width =
    //CGFloat height = CGRectGetHeight(self.view.bounds);

    soundEnabled = YES;
    
    CGRect aRect=CGRectMake(0, CGRectGetHeight(self.view.bounds)-iWidth==320? 50:66, iWidth, iWidth==320? 50:66);
    
    adView=[[ADBannerView alloc]initWithFrame:aRect];
    adView.delegate=self;
    [adView setAlpha:0];
    [self.view addSubview:adView];



    SKView * skView = (SKView*)self.originalContentView;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;

    [self startRevMobSession];

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

    


    // Set GameCenter Manager Delegate
    [[GameCenterManager sharedManager] setDelegate:self];

    // Present the Menu scene
    [skView presentScene:scene];

}

#pragma mark RevMob Ads

- (void)startRevMobSession {
    [RevMobAds startSessionWithAppID:REVMOB_ID
                  withSuccessHandler:^{
                      NSLog(@"Session started with block");
                  } andFailHandler:^(NSError *error) {
                      NSLog(@"Session failed to start with block");
                  }];
}




- (void)revmobSessionNotStartedWithError:(NSError *)error {
    NSLog(@"[RevMob Sample App] Session failed to start: %@", error);
}

#pragma mark - RevMobAdsDelegate methods

- (void)revmobSessionIsStarted {
    NSLog(@"[RevMob Sample App] Session started again.");
}

- (void)revmobSessionNotStarted:(NSError *)error {
    NSLog(@"[RevMob Sample App] Session not started again: %@", error);
}

- (void)revmobAdDidReceive {
    NSLog(@"[RevMob Sample App] Ad loaded.");
}

- (void)revmobAdDidFailWithError:(NSError *)error {
    NSLog(@"[RevMob Sample App] Ad failed: %@", error);
}

- (void)revmobAdDisplayed {
    NSLog(@"[RevMob Sample App] Ad displayed.");
//    if (mainSceneShowing == true) {
//        [mainScene pausePressed:YES withLabel:YES];
//    }
}

- (void)revmobUserClosedTheAd {
    NSLog(@"[RevMob Sample App] User clicked in the close button.");
//    if (mainSceneShowing == true) {
//        [mainScene pausePressed:NO withLabel:NO];
//    }
}

- (void)revmobUserClickedInTheAd {
    NSLog(@"[RevMob Sample App] User clicked in the Ad.");
}

- (void)installDidReceive {
    NSLog(@"[RevMob Sample App] Install did receive.");
}

- (void)installDidFail {
    NSLog(@"[RevMob Sample App] Install did fail.");
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
    //[domViewController setAdView:NO ShowOnTop:NO ChooseRandom:NO];
    [adView setAlpha:0];

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

    tmpDirection = 0;
    
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
        tmpDirection = 10;

    [clsCommon playSound:@"swipe.mp3" withVolume:.3];
 
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
