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

@interface clsCommon : NSObject

+(void) playSound:(NSString*)file;
+(void) playBackgroundMusicWithVolume:(double)volume;
+(void) doBackgroundMusicFadeToQuiet;

+ (float)getRanFloat:(float)smallNumber and:(float)bigNumber;

+ (int)getRanInt:(int)min maxNumber:(int)max;

+ (int) maxInArray:(int*)Array size:(int) array_size;

+ (void) storeUserSetting:(NSString*)key value:(NSObject*)value;

+ (NSString*) getUserSettingForKey:(NSString*)key;


@end
