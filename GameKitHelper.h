//
//  GameKitHelper.h
//  300
//
//  Created by Mauro Biefeni on 2014-04-06.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;

extern NSString *const PresentAuthenticationViewController;

@interface GameKitHelper : NSObject



@property (nonatomic, readonly)UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;
// This property stores the default leaderboard's identifier.
@property (nonatomic, strong) NSString *leaderboardIdentifierHS;
@property (nonatomic, strong) NSString * leaderboardIdentifierHL;


+(instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;
- (void)reportHighScore:(int)scr;
- (void)reportHighLevel:(int)scr;

@end
