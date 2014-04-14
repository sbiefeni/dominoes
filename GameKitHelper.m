//
//  GameKitHelper.m
//  300
//
//  Created by Mauro Biefeni on 2014-04-06.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "GameKitHelper.h"
#import "clsGameSettings.h"
#import "clsCommon.h"

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
@implementation GameKitHelper

BOOL _enableGameCenter;

+(instancetype)sharedGameKitHelper{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{sharedGameKitHelper=[[GameKitHelper alloc]init];
    });
    return sharedGameKitHelper;
}

-(id)init{
    self=[super init];
    if(self){
        _enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayer
{
    //1
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    //2
    localPlayer.authenticateHandler  =
    ^(UIViewController *viewController, NSError *error) {
        //3
        [self setLastError:error];
        
        if(viewController != nil) {
            //4
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
            //5
            _enableGameCenter = YES;
            gcEnabled = YES;
            [clsCommon storeUserSetting:@"gcEnabled" value:@"1"];
            // Get the default leaderboard identifier.
            [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifierHS, NSError *error) {

                if (error != nil) {
                    NSLog(@"%@", [error localizedDescription]);
                }
                else{
                    _leaderboardIdentifierHS = leaderboardIdentifierHS;
                }
            }];
        } else {
            //6
            _enableGameCenter = NO;
            gcEnabled=NO;
            [clsCommon storeUserSetting:@"gcEnabled" value:@"0"];
        }
    };
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PresentAuthenticationViewController
         object:self];
    }
}

- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@",
              [[_lastError userInfo] description]);
    }
}
-(void)reportHighScore:(int)scr{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"300hs"];
    score.value = scr;

    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

@end
