//
//  domMenuScene.m
//  dominoes
//
//  Created by Mauro Biefeni on 2014-03-14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//
#define isRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}

#define itunesURL   @"http://goo.gl/EZPeMw"

//shortened with google URL shortener service
//@"https://itunes.apple.com/us/app/300-brickd/id859320677?ls=1&mt=8"


#import "domMenuScene.h"
#import "domGameScene.h"
#import "clsCommon.h"
#import "domViewController.h"
#import "clsGameSettings.h"
#import "GameCenterManager.h"

#import "AppFlood.h"

#define appFloodScenesRandomInterval 4
#define kRemoveAdsProductIDentifier @"300_NoAds"

#import "SKEmitterNode+fromFile.h"

//#import <AudioToolbox/AudioServices.h>

@implementation domMenuScene  {
    CGSize mySize;
    NSTimer *aTimer;
    int levelHighScore;


    NSTimer *tapTimer;
    
}

-(instancetype)initWithSize:(CGSize)size
{
    //debug code
    //  [clsCommon storeUserSetting:@"areAdsRemoved" value:[NSString stringWithFormat:@"%i",0]];

    areAdsRemoved = [[clsCommon getUserSettingForKey: @"areAdsRemoved"] intValue];

    //this will load wether or not they bought the in-app purchase
    
    if(self = [super initWithSize:size]) {


        //start the background music track playing
        [domViewController setAdView:NO ShowOnTop:NO ChooseRandom:YES];
        [clsCommon playBackgroundMusicWithVolume:.2];

        mySize = size;




        //timer to disable tap for a few seconds, to wait for game center
        tapTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(enableTapTimer) userInfo:nil repeats:YES];

        SKEmitterNode *background = [SKEmitterNode dom_emitterNamed:@"Background_Stars"];
        background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
        [background advanceSimulationTime:10];

        background.alpha = .5;

        self.backgroundColor = [SKColor blackColor];
        
        [self addChild:background];

        sizeDoubler = 1;
        if (size.width > 320){ //make fonts and spacing bigger on larger screen
            sizeDoubler = 2;
        }

        int highScore = [self getHighScore];
        levelHighScore = [self getLevelHighscore];
        maxLevels = [self getMaxLevels];
#pragma mark - Opening Screen
        if (gameStatus != game_Started ) {  //game hasn't started.. show initial screen


            SKLabelNode* hlscore = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
            [self createLabel:hlscore text:[NSString stringWithFormat:@"Best Level: %i",levelHighScore] fontSize:30 posY:210 color:[SKColor whiteColor] alpha:.7 sizeDoubler:sizeDoubler];

            SKLabelNode* mLevels = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            [self createLabel:mLevels text:[NSString stringWithFormat:@"Most Levels: %i",(int)maxLevels] fontSize:20 posY:180 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

            SKLabelNode* hscore = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            [self createLabel:hscore text:[NSString stringWithFormat:@"High Score: %i",(int)highScore] fontSize:20 posY:150 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

            SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
            [self createLabel:title text:@"300" fontSize:130 posY:45 color:[SKColor redColor] alpha:.7 sizeDoubler:sizeDoubler];

            SKLabelNode *title2 = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
            title2.fontName = [UIFont italicSystemFontOfSize:45].fontName;
            [self createLabel:title2 text:@"Brick'd" fontSize:45 posY:5 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

            SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
            [self createLabel:tapToPlay text:@"Tap to Play" fontSize:40 posY:-52 color:[SKColor whiteColor] alpha:.7 sizeDoubler:sizeDoubler];


            [self addChild: [self instruct:sizeDoubler posY:-145]]; //instructions button, from below

            isRunningInIde(gcEnabled=NO)

            //draw facebook and twitter buttons
            [self drawSocialButtonsWithfbX:-120 withfbY:10 withtwX:120 withtwY:10 withAlpha:.5];

            //timer to check for gamecenter button
            aTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(gameCenterButtonTimer) userInfo:nil repeats:YES];
            

                gameStatus = reset;

        }else if(gameStatus == game_Started && lives > 0)   { // game started...
#pragma mark - In Between Rounds Screen
                //show score screen

            totalScore += levelScore;

            [self showAppFlood:false];

            //if new best level, give a message and store it!
            if (levelScore > levelHighScore) {
                [self setLevelHighScore: levelScore];

                levelHighScore = levelScore;

                SKLabelNode *hs = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:hs text:@"NEW BEST LEVEL!" fontSize:25 posY:120 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];
            }


            SKLabelNode* hlscore = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            [self createLabel:hlscore text:[NSString stringWithFormat:@"Best Level: %i",levelHighScore] fontSize:20 posY:80 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];


            SKLabelNode *cur_score = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
            [self createLabel:cur_score text:[NSString stringWithFormat:@"Score: %i",levelScore] fontSize:50 posY:0 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

            SKLabelNode *tot_score = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            [self createLabel:tot_score text:[NSString stringWithFormat:@"Total Score: %i",totalScore] fontSize:30 posY:-60 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

            SKLabelNode *Lives = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            [self createLabel:Lives text:[NSString stringWithFormat:@"Lives: %i",lives] fontSize:30 posY:-100 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

            SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
            [self createLabel:tapToPlay text:@"Tap to Continue" fontSize:35 posY:-145 color:[SKColor whiteColor] alpha:.7 sizeDoubler:sizeDoubler];

            //for debugging - to reset the level high score
            isRunningInIde(
               // levelHighScore = 0;
                //[self setLevelHighScore: 0];
            );

            if(areAdsRemoved < 1){
                [self createBuyGameButton];
            }



        }else{
                //game over
#pragma mark - Game Over Screen
                totalScore += levelScore;

            //debugging - reset the total score
            isRunningInIde(
               // highScore=0;
                //[self setHighScore:0];
            );

                //if new high score, give a message and store it!
                if (totalScore > highScore) {
                    [self setHighScore:totalScore];

                    SKLabelNode *hs = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                    [self createLabel:hs text:@"NEW HIGH SCORE!" fontSize:30 posY:200 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];
                    if (gcEnabled){
                    //set the gamecenter score
                        [[GameCenterManager sharedManager]highScoreForLeaderboard:@"300hs"];
                    }
                }

                //if new maxLevels, store it
            if (level > maxLevels) {
                [self setMaxLevels:level];
            }

            [self showAppFlood:true];

                //draw facebook and twitter buttons
                [self drawSocialButtonsWithfbX:-40 withfbY:10 withtwX:40 withtwY:10 withAlpha:1];

                //draw social share message
                SKSpriteNode *socialMessage = [SKSpriteNode spriteNodeWithImageNamed:@"social_share_message"];
                socialMessage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 90 * sizeDoubler );
                socialMessage.name = @"socialMessage";
                [self addChild:socialMessage];

                SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
                [self createLabel:title text:@"Game over!" fontSize:45 posY:155 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];


                SKLabelNode *tot_score = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
                [self createLabel:tot_score text:@"Total Score" fontSize:40 posY:-60 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                SKLabelNode *tot_score2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
                [self createLabel:tot_score2 text:[NSString stringWithFormat:@"%i",totalScore] fontSize:80 posY:-150 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                SKLabelNode *hs = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
                [self createLabel:hs text:[NSString stringWithFormat:@"Level Reached: %i",level ] fontSize:20 posY:-200 color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler];

                if(areAdsRemoved < 1){
                    [self createBuyGameButton];
                }
            
            gameStatus = game_Over;

                if (levelScore > levelHighScore) {
                    [self setLevelHighScore: levelScore];
                }

                //reset score to 0 now, for next round
                levelScore = 0;
        
        } // end if gamestatus

    } //end super initwithsize
    return self;

} //end initwithsize

-(void) showAppFlood:(BOOL)gameEnd {

    if (areAdsRemoved < 1){

        if (!appFloodShowedLastLevel){
            //show a timed intersitial for game end
            if (gameEnd){  //show intersitial 1 out of 3 times
                if ([clsCommon getRanInt:1 maxNumber:3] == 1 && (appFloodSceneCount > 4)){
                    [AppFlood showInterstitial];
                }else{
                    [AppFlood showFullscreen];
                }
                appFloodShowedLastLevel = true;
            }else{
                //count number of scene changes to intermittently show Ad
                if (appFloodSceneCount > 1){
                    if ([clsCommon getRanInt:1 maxNumber:appFloodScenesRandomInterval] == 1){
                        [AppFlood showFullscreen];
                        appFloodShowedLastLevel = true;
                    }
                }
            }
        }else{
            appFloodShowedLastLevel = false;
        }

        appFloodSceneCount += 1;

    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)gameCenterButtonTimer {
//check for gamecenter availability, draw the button, then disable the timer
    NSLog(@"timer called");

    //if([GKLocalPlayer localPlayer].isAuthenticated){

        if ([self enableGameCenterButton]) {

            [self enableTapTimer];

            if(aTimer)
            {
                [aTimer invalidate];
                aTimer = nil;
            }
        }
    //}
}

-(void) enableTapTimer {
    NSLog(@"TapTimer called");

    tapEnabled = true;
    [tapTimer invalidate];
    tapTimer = nil;
}

-(BOOL)createBuyGameButton{
    SKSpriteNode *buyGameButton = [SKSpriteNode spriteNodeWithImageNamed:@"green_button.png"];
    buyGameButton.position = CGPointMake(CGRectGetMidX(self.frame), 30);
    buyGameButton.name = @"buygamebutton";
    buyGameButton.zPosition = 2;
    [self addChild:buyGameButton];
    
    SKLabelNode *buyGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
    [self createLabel:buyGameLabel text:@"Disable Ads - $0.99" fontSize:24 posY:-((mySize.height/2)/sizeDoubler) color:[SKColor blackColor] alpha:.7 sizeDoubler:1];
    buyGameLabel.position = buyGameButton.position;
    buyGameLabel.zPosition = 3;
    buyGameLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    buyGameLabel.name = @"buygamelabel";
    return true;
}

-(BOOL)enableGameCenterButton {
    static BOOL didThis;
    if(gameStatus == game_Over){
        return true;
    }
    if([GKLocalPlayer localPlayer].isAuthenticated){

        SKSpriteNode *gcButton = [SKSpriteNode spriteNodeWithImageNamed:@"stretch_button.png"];
        gcButton.position = CGPointMake(CGRectGetMidX(self.frame), 30);
        gcButton.name = @"gamecenter";
        gcButton.zPosition = 4;
        [self addChild:gcButton];

        SKLabelNode *gcLabel = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        [self createLabel:gcLabel text:@"Leaderboard" fontSize:30 posY:-((mySize.height/2)/sizeDoubler) color:[SKColor blackColor] alpha:.7 sizeDoubler:1];
        gcLabel.position = gcButton.position;
        gcLabel.zPosition = 5;
        gcLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        gcLabel.name = @"gamecenterlabel";


        // report previous scores to gamecenter as a backup in case they weren't
        if (!didReportPrevHighScore) {
            [self setHighScore:[self getHighScore]];
            didReportPrevHighScore = true;
        }
        if (!didReportPrevHighLevelScore) {
            [self setLevelHighScore:[self getLevelHighscore]];
            didReportPrevHighLevelScore = true;
        }
        if (!didReportMaxLevels) {
            [self setMaxLevels:[self getMaxLevels]];
            didReportMaxLevels = true;
        }


        return true;
    }else{
        if (!didThis) {
            SKLabelNode *gcLabel = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
            [self createLabel:gcLabel text:@"Log in to Gamecenter to see Leaderboard" fontSize:12 posY:-((mySize.height/2)/sizeDoubler) color:[SKColor whiteColor] alpha:.7 sizeDoubler:1];
            gcLabel.position = CGPointMake(CGRectGetMidX(self.frame), 20);
            gcLabel.zPosition = 1;
            gcLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            gcLabel.name = @"gamecenterlabel";

            didThis = true;
        }
    }
    return false;

}

-(void)drawSocialButtonsWithfbX:(int)fbX withfbY:(int)fbY withtwX:(int)twX withtwY:(int)twY withAlpha:(float)alpha{

    SKSpriteNode *fbButton = [SKSpriteNode spriteNodeWithImageNamed:@"facebook.png"];
        fbButton.position = CGPointMake(CGRectGetMidX(self.frame) + fbX * sizeDoubler, CGRectGetMidY(self.frame) + fbY * sizeDoubler );
        fbButton.alpha = alpha;
        fbButton.name = @"facebook";
        [self addChild:fbButton];

    SKSpriteNode *twButton = [SKSpriteNode spriteNodeWithImageNamed:@"twitter.png"];
        twButton.position = CGPointMake(CGRectGetMidX(self.frame)+twX*sizeDoubler, CGRectGetMidY(self.frame)+twY*sizeDoubler);
        twButton.alpha=alpha;
        twButton.name = @"twitter";
        [self addChild:twButton];
}

-(void) setMaxLevels:(int)levels {
    NSString* _levels = [NSString stringWithFormat:@"%i",level];
    [clsCommon storeUserSetting:@"maxLevels" value:_levels];
    [[GameCenterManager sharedManager] saveAndReportScore:levels leaderboard:@"300ml"  sortOrder:GameCenterSortOrderHighToLow];
}

-(void) setHighScore:(int)score {
    NSString* _score = [NSString stringWithFormat:@"%i",score];
    [clsCommon storeUserSetting:@"highscore" value:_score];
    [[GameCenterManager sharedManager] saveAndReportScore:score leaderboard:@"300hs"  sortOrder:GameCenterSortOrderHighToLow];
}

-(void) setLevelHighScore:(int)score {
    NSString* _score = [NSString stringWithFormat:@"%i",score];
    [clsCommon storeUserSetting:@"levelHighscore" value:_score];
    [[GameCenterManager sharedManager] saveAndReportScore:score leaderboard:@"300hl"  sortOrder:GameCenterSortOrderHighToLow];

    //check and report achievment level
    int goal;

    //submit percentage of each achievemnt level
        goal = 150;
        //set to % complete, and name of the achievemnt board
        [[GameCenterManager sharedManager] saveAndReportAchievement:[NSString stringWithFormat:@"300_%i",goal] percentComplete:[self getGoalPercent:goal withScore:score] shouldDisplayNotification:YES];

        goal = 200;
        //set to % complete, and name of the achievemnt board
        [[GameCenterManager sharedManager] saveAndReportAchievement:[NSString stringWithFormat:@"300_%i",goal] percentComplete:[self getGoalPercent:goal withScore:score] shouldDisplayNotification:YES];

        goal = 225;
        //set to % complete, and name of the achievemnt board
        [[GameCenterManager sharedManager] saveAndReportAchievement:[NSString stringWithFormat:@"300_%i",goal] percentComplete:[self getGoalPercent:goal withScore:score] shouldDisplayNotification:YES];

        goal = 250;
        //set to % complete, and name of the achievemnt board
        [[GameCenterManager sharedManager] saveAndReportAchievement:[NSString stringWithFormat:@"300_%i",goal] percentComplete:[self getGoalPercent:goal withScore:score] shouldDisplayNotification:YES];

        goal = 275;
        //set to % complete, and name of the achievemnt board
        [[GameCenterManager sharedManager] saveAndReportAchievement:[NSString stringWithFormat:@"300_%i",goal] percentComplete:[self getGoalPercent:goal withScore:score] shouldDisplayNotification:YES];

        goal = 300;
        //set to % complete, and name of the achievemnt board
        [[GameCenterManager sharedManager] saveAndReportAchievement:[NSString stringWithFormat:@"300_%i",goal] percentComplete:[self getGoalPercent:goal withScore:score] shouldDisplayNotification:YES];

}
-(double)getGoalPercent:(int)goal withScore:(int)score {
    int tmp =  (score/goal)*100;
    if (tmp > 100)
        tmp = 100;

    return tmp;
}

-(int) getHighScore {
    NSString* _score;
    _score = [clsCommon getUserSettingForKey:@"highscore"];
    int value = [_score intValue];
    return value;
}

-(int) getLevelHighscore {
    NSString* _score;
    _score = [clsCommon getUserSettingForKey:@"levelHighscore"];
    int value = [_score intValue];
    return value;
}

-(int) getMaxLevels {
    NSString* _levels;
    _levels = [clsCommon getUserSettingForKey:@"maxLevels"];
    int value = [_levels intValue];
    return value;
}

-(void) createLabel:(SKLabelNode*)label text:(NSString*)text fontSize:(int)fontSize posY:(int)posY color:(SKColor*)color alpha:(float)alpha sizeDoubler:(int)sizeDoubler {

    label.text = NSLocalizedString(text,nil);
    label.fontSize = fontSize * sizeDoubler;
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + posY * sizeDoubler);
    label.fontColor = color;
    label.alpha = alpha;
    label.zPosition = 500;

    [self addChild:label];

}

- (SKSpriteNode *)instruct:(int)sizeDoubler posY:(int)posY
{
    SKSpriteNode *instruct = [SKSpriteNode spriteNodeWithImageNamed:@"directions"];
    instruct.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame) + (posY * sizeDoubler) );
    instruct.name = @"instructions";//how the node is identified later
    instruct.zPosition = 10;
    instruct.alpha = .7;

    SKLabelNode* tapFor=[SKLabelNode labelNodeWithFontNamed:@"Arial"];
    tapFor.name=@"tapFor";
    [self createLabel:tapFor text:@"Tap for Detailed Instructions" fontSize:12 posY:posY+instruct.frame.size.height/(2.1*sizeDoubler) color:[SKColor whiteColor] alpha:.7 sizeDoubler:sizeDoubler];

    return instruct;
}

- (void)postToFacebookWithScore:(int)score {

    SLComposeViewController *faceBook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

    if (score > 0) {
        [faceBook setInitialText:[NSString stringWithFormat: NSLocalizedString(@"Check out this cool new game. Can you beat my best level of %i Bricks? It's free... get it at:",nil),score]];
    }else{

        [faceBook setInitialText:NSLocalizedString(@"Check out this cool new game. It's free... get it at:",nil)];

    }

        [faceBook addURL:[NSURL URLWithString:itunesURL]];

        [faceBook addImage:[UIImage imageNamed:@"300_logo"]];
        [faceBook setEditing:false];

        [[self getActiveController] presentViewController:faceBook animated:YES completion:Nil];

    [faceBook setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output = NSLocalizedString(@"Post Cancelled",nil);
                break;
            case SLComposeViewControllerResultDone:
                output = NSLocalizedString(@"Post Successful.. 4 Lives Granted!",nil);
                [clsCommon storeUserSetting:@"socialFreeLife" value:@"yes"];
                break;
            
            default:
                break;
        } //check if everything worked properly. Give out a message on the state.

        [self showPopupMessage:output withTitle:@"Facebook"];

    }];
}

- (void)postToTwitterWithScore:(int)score {

    SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
    if (score > 0) {
        [tweetSheet setInitialText:[NSString stringWithFormat: NSLocalizedString(@"Check out 300 Brick'd. Can you beat my best level of %i Bricks? It's free... get it at %@",nil),score, itunesURL]];
    }else{
        [tweetSheet setInitialText:NSLocalizedString(@"Check out 300 Brick'd. It's free... get it on the Appstore",nil)];
    }

    [[self getActiveController] presentViewController:tweetSheet animated:YES completion:nil];

    [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output = NSLocalizedString(@"Post Cancelled",nil);
                break;
            case SLComposeViewControllerResultDone:
                output = NSLocalizedString(@"Post Successful.. 4 Lives Granted!",nil);
                    [clsCommon storeUserSetting:@"socialFreeLife" value:@"yes"];
                break;
            default:
                break;
        } //check if everything worked properly. Give out a message on the state.

        [self showPopupMessage:output withTitle:@"Twitter"];

    }];
}

-(void)showPopupMessage:(NSString*)message withTitle:(NSString*)title{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",nil) otherButtonTitles:nil];

    [alert show];
}

-(UIViewController*)getActiveController{

    //get the active view controller
    UIViewController *activeController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([activeController isKindOfClass:[UINavigationController class]])
    {
        activeController = [(UINavigationController*) activeController visibleViewController];
    }
    else if (activeController.presentedViewController)
    {
        activeController = activeController.presentedViewController;
    }

    return activeController;

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];

        // if gamecenter button touched, launch it
        if ([node.name isEqualToString:@"gamecenter"] || [node.name isEqualToString:@"gamecenterlabel"]) {
            NSLog(@"GameCenter Button pressed");

            if([GKLocalPlayer localPlayer].isAuthenticated){
                //show leaderboard
                [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:[self getActiveController]];
                
            }else{
                //authenticate player -- can't do with game center manager
                //[[GameCenterManager sharedManager] checkGameCenterAvailability ];
            }

        }else if([node.name isEqualToString:@"facebook"]){
            [self postToFacebookWithScore:levelHighScore];

        }else if([node.name isEqualToString:@"twitter"]){
            [self postToTwitterWithScore:levelHighScore];
        }else if([node.name isEqualToString:@"buygamebutton"] || [node.name isEqualToString:@"buygamelabel"]) {
            //PUT BUY GAME CODE HERE
            [self userClickedBuyGame];
        }else if([node.name isEqualToString:@"instructions"] || [node.name isEqualToString:@"tapFor"] ){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"How to Play",nil)
                message: NSLocalizedString(@"how to play instructions",nil)
                delegate: nil
                cancelButtonTitle:@"Ok"
                otherButtonTitles: nil];
            
            [alert show];

        }else if(tapEnabled) {
            [aTimer invalidate];
            aTimer = nil;
            if (gameStatus == reset || gameStatus == game_Started) {
                
                domGameScene *game = [[domGameScene alloc] initWithSize:self.size];
                [self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:.75]];
                
            }else{
                domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
                [self.view presentScene:menu transition:[SKTransition doorsOpenHorizontalWithDuration:.75]];
            }
        }

}

-(void)userClickedBuyGame{
    if([SKPaymentQueue canMakePayments]){
        //NSLog(@"User can make payments");
        SKProductsRequest *productsRequest=[[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIDentifier]];
        productsRequest.delegate=self;
        [productsRequest start];
    }
    else{
        [self showPopupMessage:NSLocalizedString(@"Purchases are disabled for your account",nil) withTitle:NSLocalizedString(@"Remove Ads",nil)];
        //NSLog(@"User cannot make payments, perhaps due to parental controls");
    }
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct=nil;
    NSUInteger count=[response.products count];
    if(count>0){
        validProduct=[response.products objectAtIndex:0];
        
        NSLog(@"Products Available");
        [self purchaseGame:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
    }
}

-(void)purchaseGame:(SKProduct *)product{
    SKPayment *payment=[SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)paymentQueue:(SKPayment *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSLog(@"Received restored transactions: %i", (int)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
        
    }

}

- (void)doRemoveAds{
    ADBannerView *banner;
    [banner setAlpha:0];
    areAdsRemoved = 1;
    [[self childNodeWithName:@"buygamebutton"] removeFromParent];
    [[self childNodeWithName:@"buygamelabel"] removeFromParent];

    //save the ads removed setting
    [clsCommon storeUserSetting:@"areAdsRemoved" value:[NSString stringWithFormat:@"%i",areAdsRemoved]];
}

@end
