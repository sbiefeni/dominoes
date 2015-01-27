//
//  domMenuScene.h
//  dominoes
//
//  Created by Mauro Biefeni on 2014-03-14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <Social/Social.h>
#import <StoreKit/StoreKit.h>

@interface domMenuScene : SKScene <SKProductsRequestDelegate,SKPaymentTransactionObserver>

-(BOOL)enableGameCenterButton;

-(void)showHTML:(NSString*)html;

@end
