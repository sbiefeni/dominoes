//
//  domMenuScene.m
//  dominoes
//
//  Created by Mauro Biefeni on 2014-03-14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//
#define isRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}

#define itunesURL   @"http://goo.gl/EZPeMw"

#define runAfter(X,After)    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, After * NSEC_PER_SEC), dispatch_get_main_queue(), ^{X});

#define try(x)  @try{x} @catch(NSException *exception) {} @finally{}

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


        //self.scaleMode = SKSceneScaleMode.ResizeFill;
        //self.scaleMode = SKSceneScaleModeAspectFill;


        //timer to disable tap for a few seconds, to wait for game center
        tapTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(enableTapTimer) userInfo:nil repeats:YES];

//        [self createBuyGameButton:false];
//        if (!areAdsRemoved) {
//            [self createRestoreButton];
//        }

//        SKEmitterNode *background = [SKEmitterNode dom_emitterNamed:@"Background_Stars"];
//        background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
//        [background advanceSimulationTime:10];
//
//        background.alpha = .5;
//
        self.backgroundColor = [SKColor whiteColor];
        
        //[self addChild:background];


        sizeDoubler = 1;
        if (size.width > 320){ //make fonts and spacing bigger on larger screen
            sizeDoubler = 2;
        }

        //make frame
        SKSpriteNode *frame = [SKSpriteNode spriteNodeWithImageNamed:@"frame.png"];
        frame.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 25*sizeDoubler );
        frame.name = @"frame";
        frame.xScale = .65*sizeDoubler;
        frame.yScale = .65*sizeDoubler;
        [self addChild:frame];

        //make logo
        SKSpriteNode *logo = [SKSpriteNode spriteNodeWithImageNamed:@"logo.png"];
        logo.position = CGPointMake(0, 110   );
        logo.name = @"logo";
        logo.xScale = (.28 / frame.xScale) *sizeDoubler;
        logo.yScale = (.28 / frame.xScale) *sizeDoubler;

        [frame addChild:logo];

        int highScore = [self getHighScore];
        levelHighScore = [self getLevelHighscore];
        maxLevels = [self getMaxLevels];

        if (!areAdsRemoved) {
            [self createBuyGameButton:true];
        }

#pragma mark - Opening Screen
        if (gameStatus != game_Started ) {  //game hasn't started.. show initial screen


            SKLabelNode* hlscore = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
            [self createLabel:hlscore text:[NSString stringWithFormat:@"Best Level: %i",levelHighScore] fontSize:25 posY:-30 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];

            SKLabelNode* mLevels = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
            [self createLabel:mLevels text:[NSString stringWithFormat:@"Most Levels: %i",(int)maxLevels] fontSize:15 posY:-55 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];

            SKLabelNode* hscore = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
            [self createLabel:hscore text:[NSString stringWithFormat:@"High Score: %i",(int)highScore] fontSize:15 posY:-75 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];


            //make Play Button
            SKSpriteNode *Play = [SKSpriteNode spriteNodeWithImageNamed:@"play.png"];
            Play.position = CGPointMake(0,  - 210 );
            Play.name = @"play";
            Play.xScale = 1*sizeDoubler  / [self childNodeWithName:@"frame"].xScale;
            Play.yScale = 1*sizeDoubler  / [self childNodeWithName:@"frame"].xScale;
            [[self childNodeWithName:@"frame"] addChild:Play];
            //make Help Button

            //draw facebook and twitter buttons
            //[self drawSocialButtonsWithfbX:-100 withfbY:100 withtwX:100 withtwY:100 withAlpha:.5];

            int sY = -160;
            [self drawSocialButtonsWithfbX:150 withfbY: sY
                                   withtwX:150 withtwY: sY-90
                                    withHX:-150 withHY: sY-60
                              HwithAlpha:.5 withScale: .85];

            gameStatus = reset;

            //timer to check for gamecenter button
           if([GKLocalPlayer localPlayer].isAuthenticated){
               [self gameCenterButtonTimer];
           }else{
               aTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(gameCenterButtonTimer) userInfo:nil repeats:YES];
           }



        }else if(gameStatus == game_Started && lives > 0)   { // game started...
#pragma mark - In Between Rounds Screen
                //show score screen

            totalScore += levelScore;

            [self showAppFlood:false];

            //if new best level, give a message and store it!
            NSString* hsLabel;
            SKColor* color;
            bool flash = false;
            if (levelScore > levelHighScore) {
                [self setLevelHighScore: levelScore];
                levelHighScore = levelScore;
                hsLabel = [NSString stringWithFormat:@"NEW BEST LEVEL!: %i",levelHighScore];
                color = [SKColor redColor];
                [clsCommon playSound:@"bonus.wav" withVolume:.8];
                flash = true;
            }else{
                hsLabel = [NSString stringWithFormat:@"Best Level: %i",levelHighScore];
                color = [SKColor blackColor];
            }
            SKLabelNode* hlscore = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
            [self createLabel:hlscore text:hsLabel fontSize:20 posY:-75 color:color alpha:.7 sizeDoubler:sizeDoubler onObject:frame];

            if (flash) {
                SKAction* a = [SKAction repeatAction:
                               [SKAction sequence:@[
                                                    [SKAction scaleTo:.001 duration:0],
                                                    [SKAction waitForDuration:.15],
                                                    [SKAction scaleTo:1 duration:0],
                                                    [SKAction waitForDuration:.15]
                                                    ]]
                                               count:10];
                [hlscore runAction:a];
            }

            SKLabelNode *cur_score = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
            [self createLabel:cur_score text:[NSString stringWithFormat:@"Score: %i",levelScore] fontSize:35 posY:-120 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];

            SKLabelNode *tot_score = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
            [self createLabel:tot_score text:[NSString stringWithFormat:@"Total Score: %i",totalScore] fontSize:25 posY:-160 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];

            SKLabelNode *Lives = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
            [self createLabel:Lives text:[NSString stringWithFormat:@"Lives: %i",lives] fontSize:25 posY:-190 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];


            //for debugging - to reset the level high score
            isRunningInIde(
               // levelHighScore = 0;
                //[self setLevelHighScore: 0];
            );

            if(areAdsRemoved < 1){
                [self createBuyGameButton:true];
            }



        }else{
                //game over
#pragma mark - Game Over Screen
                totalScore += levelScore;

            SKLabelNode *hs = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
            hs.name = @"hs";

            SKNode* frame = [self childNodeWithName:@"frame"];

            //debugging - reset the total score
            isRunningInIde(
               // highScore=0;
                //[self setHighScore:0];
            );

                //if new high score, give a message and store it!
                if (totalScore > highScore) {
                    [self setHighScore:totalScore];


                    [self createLabel:hs text:@"NEW HIGH SCORE!" fontSize:30 posY:-185 color:[SKColor redColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];
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

            logo.alpha = .15;

                //draw facebook and twitter buttons
                //[self drawSocialButtonsWithfbX:-40 withfbY:10 withtwX:40 withtwY:10 withAlpha:1];
            [self drawSocialButtonsWithfbX:-110 withfbY:20 withtwX:110 withtwY:20 withHX:-500 withHY:40 HwithAlpha:1 withScale:.85];



                //draw social share message
                SKSpriteNode *socialMessage = [SKSpriteNode spriteNodeWithImageNamed:@"social_share_message"];
                socialMessage.position = CGPointMake(0, 160 );
                socialMessage.xScale = sizeDoubler / frame.xScale ;
                socialMessage.yScale = sizeDoubler / frame.yScale;

                //socialMessage.alpha = .7;

                socialMessage.colorBlendFactor = 1;
                socialMessage.color = [SKColor blackColor];
                socialMessage.name = @"socialMessage";
                [frame addChild:socialMessage];

                SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
                [self createLabel:title text:@"Game over!" fontSize:35 posY:-50 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];


                SKLabelNode *tot_score = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
                [self createLabel:tot_score text:@"Total Score" fontSize:30 posY:-90 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];

                SKLabelNode *tot_score2 = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
                [self createLabel:tot_score2 text:[NSString stringWithFormat:@"%i",totalScore] fontSize:60 posY:-150 color:[SKColor blackColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];

                //SKLabelNode *hs = [SKLabelNode labelNodeWithFontNamed:@"Komika Axis"];
                if (![frame childNodeWithName:@"hs"]){
                    [self createLabel:hs text:[NSString stringWithFormat:@"Level Reached: %i",level ] fontSize:20 posY:-185 color:[SKColor redColor] alpha:.7 sizeDoubler:sizeDoubler onObject:frame];
                }
                if(areAdsRemoved < 1){
                    [self createBuyGameButton:true];
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


    [self enableTapTimer];

    if (![self enableGameCenterButton]) {

//        if (!areAdsRemoved) {
//            [self createBuyGameButton:true];
//        }
    }


    if(aTimer)
    {
        [aTimer invalidate];
        aTimer = nil;
    }

}

-(void) enableTapTimer {
    NSLog(@"TapTimer called");

    tapEnabled = true;
    [tapTimer invalidate];
    tapTimer = nil;
}

#pragma mark - buy game button
-(BOOL)createBuyGameButton:(BOOL)doRestore{

    int yPos = [self childNodeWithName:@"frame"].position.y - [self childNodeWithName:@"frame"].frame.size.height/2 - 16*sizeDoubler;

    [self makeButtonNamed:@"buygame" withImage:@"rect_l.png" withText1:@"Disable Ads - $0.99" Text2:nil xPOS:-60 yPOS:yPos fontName:@"Avenir-Black" fontSize:14 withScale:.25];

    if (doRestore) {
        [self createRestoreButton];
    }

    return true;
}

-(void) createRestoreButton{

    int yPos = [self childNodeWithName:@"frame"].position.y - [self childNodeWithName:@"frame"].frame.size.height/2 - 16*sizeDoubler;

    [self makeButtonNamed:@"restore" withImage:@"rect_s.png" withText1:@"Restore" Text2:@"Purchases"  xPOS:100 yPOS:yPos fontName:@"Avenir-Black" fontSize:11 withScale:.25];

}

-(void) makeButtonNamed:(NSString*)name withImage:(NSString*)image withText1:(NSString*)text Text2:(NSString*)text2 xPOS:(int)Xpos yPOS:(int)Ypos fontName:(NSString*)fontName fontSize:(double) fontSize withScale:(double)scale{

    SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:image];
    CGPoint location;

    Xpos = CGRectGetMidX(self.frame) + Xpos * sizeDoubler;
    //Ypos = Ypos * sizeDoubler;
    fontSize = fontSize * (1/scale);

    location = CGPointMake(Xpos, Ypos);

    [button setPosition:location];
    [button setXScale:scale * sizeDoubler];
    [button setYScale:scale * sizeDoubler];

    [button setName: name];


    [self addChild:button];

    // add labels --------------------------------------------------------

    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:fontName];
    label.name = name;

    SKLabelNode* label2 = [SKLabelNode labelNodeWithFontNamed:fontName];
    label2.name  = name;

    //location = CGPointMake(button.frame.size.width/2, button.frame.size.height/2);

    double yPos1;
    double yPos2;

    if (text2 != nil) {
        yPos1 = 5 ;
        yPos2 = - fontSize + 5;
        [self makeLabelOnNode:button withLabel:label2 text:text2 fontSize:fontSize posX:0 posY:yPos2 color:[SKColor whiteColor] alpha:1 dontAdd:NO];
    }else{
        yPos1 = - fontSize/3;
    }
    [self makeLabelOnNode:button withLabel:label text:text fontSize:fontSize posX:0 posY:yPos1 color:[SKColor whiteColor] alpha:1 dontAdd:NO];

}

-(void) makeLabelOnNode:(SKSpriteNode*)button withLabel:(SKLabelNode*)label text:(NSString*)text fontSize:(int)fontSize posX:(int)posX posY:(int)posY color:(SKColor*)color alpha:(float)alpha dontAdd:(BOOL)dontAdd{

    label.text = NSLocalizedString(text,nil);
    label.fontSize = fontSize;
    label.position = CGPointMake(posX, posY);
    label.fontColor = color;
    label.alpha = alpha;
    if (!dontAdd) {
        [button addChild:label];
    }
}

#pragma mark - Game center button
-(BOOL)enableGameCenterButton {
    static BOOL didThis;
    //isRunningInIde(return false);
    if(gameStatus == game_Over){
        return true;
    }

    if([GKLocalPlayer localPlayer].isAuthenticated){

        int yPos = [self childNodeWithName:@"frame"].position.y - [self childNodeWithName:@"frame"].frame.size.height/2 - 16*sizeDoubler;
        if(!areAdsRemoved){
            yPos = yPos - 32*sizeDoubler;
        }

            [self makeButtonNamed:@"gamecenter" withImage:@"rect_l.png" withText1:@"Leaderboard" Text2:nil xPOS:-60 yPOS:yPos fontName:@"Avenir-Black" fontSize:15 withScale:.25];

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
            [self createLabel:gcLabel text:@"Log in to Gamecenter to see Leaderboard" fontSize:12 posY:-((mySize.height/2)/sizeDoubler) color:[SKColor blackColor] alpha:.7 sizeDoubler:1 onObject:self];
            gcLabel.position = CGPointMake(CGRectGetMidX(self.frame), 20);
            gcLabel.zPosition = 1;
            gcLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            gcLabel.name = @"gamecenterlabel";

            didThis = true;
        }
    }
    return false;

}

-(void)drawSocialButtonsWithfbX:(int)fbX withfbY:(int)fbY withtwX:(int)twX withtwY:(int)twY withHX:(int)HX withHY:(int)HY HwithAlpha:(float)alpha withScale:(double)scale{

    scale = scale *sizeDoubler;

    SKSpriteNode *hButton = [SKSpriteNode spriteNodeWithImageNamed:@"help.png"];
        hButton.position = CGPointMake( HX ,   HY  );
        hButton.alpha = alpha;
        hButton.name = @"help";
        hButton.xScale = scale*1.15  / [self childNodeWithName:@"frame"].xScale;
        hButton.yScale = scale*1.15  / [self childNodeWithName:@"frame"].xScale;
        [[self childNodeWithName:@"frame"] addChild:hButton];

    SKSpriteNode *fbButton = [SKSpriteNode spriteNodeWithImageNamed:@"facebook.png"];
        fbButton.position = CGPointMake( fbX ,  fbY  );
        fbButton.alpha = alpha;
        fbButton.name = @"facebook";
        fbButton.xScale = scale / [self childNodeWithName:@"frame"].xScale;
        fbButton.yScale = scale / [self childNodeWithName:@"frame"].yScale;
        [[self childNodeWithName:@"frame"] addChild:fbButton];

    SKSpriteNode *twButton = [SKSpriteNode spriteNodeWithImageNamed:@"twitter.png"];
        twButton.position = CGPointMake(twX,  twY);
        twButton.alpha=alpha;
        twButton.name = @"twitter";
        twButton.xScale = scale / [self childNodeWithName:@"frame"].xScale;
        twButton.yScale = scale / [self childNodeWithName:@"frame"].yScale;
        [[self childNodeWithName:@"frame"] addChild:twButton];
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

-(void) createLabel:(SKLabelNode*)label text:(NSString*)text fontSize:(int)fontSize posY:(int)posY color:(SKColor*)color alpha:(float)alpha sizeDoubler:(int)sizeDoubler onObject:(SKNode*)object{

    label.text = NSLocalizedString(text,nil);
    label.fontSize = (fontSize / object.xScale) * sizeDoubler ;
    label.position = CGPointMake(0,  (posY / object.xScale) * sizeDoubler);
    label.fontColor = color;
    label.alpha = alpha;
    label.zPosition = 500;

    [object addChild:label];

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
    [self createLabel:tapFor text:@"Tap here for Instructions" fontSize:10 posY:posY+instruct.frame.size.height/(2.62*sizeDoubler) color:[SKColor whiteColor] alpha:1 sizeDoubler:sizeDoubler onObject:self];

    return instruct;
}

- (void)postToFacebookWithScore:(int)score {

    SLComposeViewController *faceBook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

    if (score > 0) {
        [faceBook setInitialText:[NSString stringWithFormat: NSLocalizedString(@"Check out the new 300 Brickd for iOS. Can you beat my best level of %i Bricks? #300brickd It's free... get it at:",nil),score]];
    }else{

        [faceBook setInitialText:NSLocalizedString(@"Check out this cool new game. It's free... get it at:",nil)];

    }

        [faceBook addURL:[NSURL URLWithString:itunesURL]];

        [faceBook addImage:[UIImage imageNamed:@"300_social_logo"]];
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
        [tweetSheet setInitialText:[NSString stringWithFormat: NSLocalizedString(@"Check out the new 300 Brickd for iOS. Can you beat my best level of %i Bricks? #300brickd It's free... get it at: %@",nil),score, itunesURL]];
    }else{
        [tweetSheet setInitialText:NSLocalizedString(@"Check out 300 Brickd for iOS. It's free... get it on the Appstore",nil)];
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

#pragma mark - touches ended
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKSpriteNode *node = (SKSpriteNode*)[self nodeAtPoint:location];

        // if gamecenter button touched, launch it
        if ([node.name isEqualToString:@"gamecenter"]) {
            NSLog(@"GameCenter Button pressed");
            [self bounceButton:(SKSpriteNode*)[self childNodeWithName:@"gamecenter"] forever:false sound:true ];
            if([GKLocalPlayer localPlayer].isAuthenticated){
                //show leaderboard
                [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:[self getActiveController]];
                
            }else{
                //authenticate player -- can't do with game center manager
                //[[GameCenterManager sharedManager] checkGameCenterAvailability ];
            }

        }else if([node.name isEqualToString:@"facebook"]){
            [self bounceButton:node forever:true sound:true ];
            runAfter([self postToFacebookWithScore:levelHighScore];,.5)

        }else if([node.name isEqualToString:@"twitter"]){
            [self bounceButton:node forever:true sound:true] ;
            [self postToTwitterWithScore:levelHighScore];
        }else if([node.name isEqualToString:@"buygame"]) {
            //PUT BUY GAME CODE HERE
            [self bounceButton:(SKSpriteNode*)[self childNodeWithName:@"buygame"] forever:true sound:true ];
            [self userClickedBuyGame];
        }else if([node.name isEqualToString:@"restore"]) {
            //PUT RESTORE GAME CODE HERE
            [self bounceButton:(SKSpriteNode*)[self childNodeWithName:@"restore"] forever:true sound:true ];
            [self checkPurchasedItems];
        }else if([node.name isEqualToString:@"help"]) {
            //show help here TODO
            [self bounceButton:node forever:true sound:true ];
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
                if(gameStatus == reset){
                    [self bounceButton:(SKSpriteNode*)[[self childNodeWithName:@"frame"] childNodeWithName:@"play"] forever:false sound:true ];
                }else{
                    [self bounceButtonSmall:(SKSpriteNode*)[self childNodeWithName:@"frame"] forever:false sound:true ];
                }
                runAfter(
                domGameScene *game = [[domGameScene alloc] initWithSize:self.size];
                [self.view presentScene:game transition:[SKTransition doorwayWithDuration:1]];
                         ,.3)
                
            }else{
                [self bounceButtonSmall:(SKSpriteNode*)[self childNodeWithName:@"frame"] forever:false sound:true ];
                runAfter(
                domMenuScene *menu = [[domMenuScene alloc] initWithSize:self.size];
                [self.view presentScene:menu transition:[SKTransition doorwayWithDuration:1]];
                         ,.3)
            }
        }

}

-(void)userClickedBuyGame{
    if([SKPaymentQueue canMakePayments]){
        [self changeButtonColor:(SKSpriteNode*)[self childNodeWithName:@"buygamebutton"]];
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

-(void)changeButtonColor:(SKSpriteNode*)button{

    SKAction* a = [SKAction sequence:@[
        [SKAction runBlock:^{button.color = [SKColor redColor]; button.colorBlendFactor = .7;  }],
        [SKAction waitForDuration:3],
        [SKAction runBlock:^{button.colorBlendFactor = 0; }]
    ]];

    [self runAction:a];
}
-(void)bounceButton:(SKSpriteNode*)button forever:(BOOL)forever sound:(BOOL)snd{

    [self bounceButton2:button amount:.65 forever:forever sound:snd];

}
-(void)bounceButtonSmall:(SKSpriteNode*)button forever:(BOOL)forever sound:(BOOL)snd{

    [self bounceButton2:button amount:.85 forever:forever sound:snd];
    
}

-(void)bounceButton2:(SKSpriteNode*)button amount:(double)amount forever:(BOOL)forever sound:(BOOL)snd{

    double xScale = button.xScale;
    double yScale = button.yScale;
    double yT = .04;  //time
    double xT = .04;
    double yS = yScale * amount;  //scale
    double xS = xScale * amount;

    if (snd) {
        SKAction* sound = [SKAction playSoundFileNamed:@"bounce.mp3" waitForCompletion:NO];
        [button runAction:sound];
    }

    SKAction* a=[SKAction sequence:@[
                                     [SKAction scaleYTo:yS duration:yT],
                                     [SKAction scaleXTo:xS duration:xT],
                                     [SKAction scaleYTo:yScale duration:yT],
                                     [SKAction scaleXTo:xScale duration:xT]
                                     ]];
    SKAction* b=[SKAction sequence:@[
                                     [SKAction scaleYTo:yS*1.3 duration:yT],
                                     [SKAction scaleXTo:xS*1.3 duration:xT],
                                     [SKAction scaleYTo:yScale duration:yT],
                                     [SKAction scaleXTo:xScale duration:xT]
                                     ]];
    
    
    if(forever){
        SKAction* run = [SKAction repeatAction:a count:10];
        [button runAction:run];
    }else{
        [button runAction:[SKAction sequence:@[a,b]]];
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
            case SKPaymentTransactionStateDeferred:
                break;
        }
    }
}

// Call This Function...
- (void) checkPurchasedItems
{
    [self changeButtonColor:(SKSpriteNode*)[self childNodeWithName:@"restoreButton"]];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

////...Then this delegate Function Will be fired
-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSLog(@"Received restored transactions: %i", (int)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Disable Ads"
                    message: @"Purchase was restored"
                    delegate: nil
                    cancelButtonTitle:@"Ok"
                    otherButtonTitles: nil];

            [alert show];

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
    [[self childNodeWithName:@"restoreButton"] removeFromParent];
    [[self childNodeWithName:@"restoreLabel"] removeFromParent];

    //save the ads removed setting
    [clsCommon storeUserSetting:@"areAdsRemoved" value:[NSString stringWithFormat:@"%i",areAdsRemoved]];
}

@end
