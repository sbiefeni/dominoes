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

+(instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;

@end
