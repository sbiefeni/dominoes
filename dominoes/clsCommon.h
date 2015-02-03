//
//  domVariables.h
//  dominoes
//
//  Created by Stefano on 3/24/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "clsPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "clsGameSettings.h"

@interface clsCommon : SKScene

//+(void) playSound:(NSString*)file;
+(void) playBackgroundMusicWithVolume:(double)volume;

+(void) playSound:(NSString*)sound withVolume:(double)volume;

+(void) doBackgroundMusicFadeToQuiet;

+ (float)getRanFloat:(float)smallNumber and:(float)bigNumber;

+ (int)getRanInt:(int)min maxNumber:(int)max;

+ (int)getRanIntWithMin:(int)min withMax:(int)max butNot:(int)notNum;

+ (int) maxInArray:(int*)Array size:(int) array_size;

+ (void) storeUserSetting:(NSString*)key value:(NSObject*)value;

+ (NSString*) getUserSettingForKey:(NSString*)key;

+(void)showHTML:(NSString*)html;

+(UIViewController*)getActiveController;

+(void) makeCenterScreenLabelWithText:(NSString*)text labelName:(NSString*)labelName withFont:(NSString*)font withSize:(int)fontSize withColor:(SKColor*)color withAlpha:(float)alpha fadeOut:(BOOL)fadeOut flash:(BOOL)flash onScene:(SKScene*)scene position:(int)position;

@end
