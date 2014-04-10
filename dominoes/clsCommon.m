//
//  domVariables.m
//  dominoes
//
//  Created by Stefano on 3/24/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "clsCommon.h"


@interface clsCommon() {}
@end

@implementation clsCommon



+(void) playBackgroundMusicWithVolume:(double)volume{
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      [[NSBundle mainBundle] resourcePath],
                      @"sounds/tick_tock_jingle2.mp3"];
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    [backgroundMusic prepareToPlay];
    [backgroundMusic play];
    backgroundMusic.volume = volume;
}

+ (void) doBackgroundMusicFadeToQuiet {
    if (backgroundMusic.volume > 0.03) {
        backgroundMusic.volume = backgroundMusic.volume - 0.01;
        [self performSelector:@selector(doBackgroundMusicFadeToQuiet) withObject:nil afterDelay:0.02];
    }else{
        [backgroundMusic stop];
    }
}

//not working
//+ (void) playSound:(NSString*)file {
//    NSString* sound = [NSString stringWithFormat:@"sounds/%@", file];
//    [SKAction playSoundFileNamed:sound waitForCompletion:NO];
//    //
//}

+ (float)getRanFloat:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

+ (int)getRanInt:(int)min maxNumber:(int)max
{
    return min + arc4random() % (max - min + 1);
    
}

//get the max moves of any object in the array
+(int) maxInArray:(int*)Array size:(int) array_size
{
    int max = Array[0];
    for (int i = 1; i < array_size; i++)
    {
        if (Array[i] > max)
            max = Array[i];
    }
    return max;
}


//should store data in between game runs..
+ (void) storeUserSetting:(NSString*)key value:(NSString*)value {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:value forKey:key];
        [standardUserDefaults synchronize];
    }
}

+ (NSString*) getUserSettingForKey:(NSString*)key {

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        NSString* tmpValue = [standardUserDefaults objectForKey:key];
        return tmpValue;
    }else{
        return false;
    }
}

//set initial player1 direction - ***HACK? - NSUserDefaults lets us easily communicate variables between classes.
//****kept this snippet for function to save data to "disk" for game stats and settings****
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    if (standardUserDefaults) {
//        [standardUserDefaults setObject:[NSNumber numberWithInt:3] forKey:@"playerDirection"];
//        [standardUserDefaults synchronize];
//    }

@end
