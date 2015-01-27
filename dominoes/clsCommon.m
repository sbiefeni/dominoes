//
//  domVariables.m
//  dominoes
//
//  Created by Stefano on 3/24/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "clsCommon.h"
#import "MTPopupWindow.h"


@interface clsCommon() {}
@end

@implementation clsCommon

+(void)showHTML:(NSString*)html{
    __weak UIViewController* tmp = [self getActiveController];
    MTPopupWindow *popup = [MTPopupWindow new];
    popup.usesSafari = YES;
    popup.fileName = html;

    [popup setDelegate: tmp];
    [popup show];
}

+(UIViewController*)getActiveController{

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

+(void) playSound:(NSString*)sound withVolume:(double)volume{
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      [[NSBundle mainBundle] resourcePath],
                      sound];
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    soundFile = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    //[soundFile prepareToPlay];
    [soundFile play];
    soundFile.volume = volume;
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

+ (int)getRanInt:(int)min maxNumber:(int)max butNot:(int)notNum
{
    int num;
    do
    {
        num = min + arc4random() % (max - min + 1);
    }
    while (num == notNum);

    return num;
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

+(void) makeCenterScreenLabelWithText:(NSString*)text labelName:(NSString*)labelName withFont:(NSString*)font withSize:(int)fontSize withColor:(SKColor*)color withAlpha:(float)alpha fadeOut:(BOOL)fadeOut flash:(BOOL)flash onScene:(SKScene*)scene position:(int)position{

    [[scene childNodeWithName:labelName] removeFromParent];

    if (!font) {
        font = @"Arial Bold";
    }
    if(!labelName){
        labelName = @"centerLabel";
    }
    if(fontSize == 0){
        fontSize = 25;
    }
    //fontSize = [common autoScaleForDevice:fontSize forPhysics:NO foriPad:NO];
    if(!color){
        color = [SKColor redColor];
    }
    if(!alpha){
        alpha = 1;
    }
    int posX = CGRectGetMidX(scene.frame);
    int posY = CGRectGetMidY(scene.frame);
    switch (position) {
        case 0:
            posY += fontSize *1.5;
            break;
        case 2:
            posY -= fontSize *1.5;
            break;
        default:
            break;
    }

    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:font];
    label.name = labelName;
    [self makeLabel:label text:text fontSize:fontSize posX:posX posY:posY color:color alpha:alpha onScene:scene];

    SKAction* a = [SKAction runBlock:^{}];
    SKAction* b = [SKAction runBlock:^{}];

    if (flash) {
        a = [SKAction repeatAction:
             [SKAction sequence:@[
                                  [SKAction scaleTo:.001 duration:0],
                                  [SKAction waitForDuration:.15],
                                  [SKAction scaleTo:1 duration:0],
                                  [SKAction waitForDuration:.15]
                                  ]]
                             count:10];
    }
    if (fadeOut) {
        b = [SKAction sequence:@[
                                 [SKAction fadeOutWithDuration:1],
                                 [SKAction runBlock:^{
            [[scene childNodeWithName:labelName] removeFromParent];
        }]
                                 ]];
    }
    if(flash || fadeOut){
        SKAction* c = [SKAction sequence:@[a,b]];
        [label runAction:c ];
    }
}

+(void) makeLabel:(SKLabelNode*)label text:(NSString*)text fontSize:(int)fontSize posX:(int)posX posY:(int)posY color:(SKColor*)color alpha:(float)alpha onScene:(SKScene*)scene{

    label.text = NSLocalizedString(text,nil);
    label.fontSize = fontSize;
    label.position = CGPointMake(posX, posY);
    label.fontColor = color;
    label.alpha = alpha;
    label.zPosition = 100;

    [scene addChild:label];
}


//set initial player1 direction - ***HACK? - NSUserDefaults lets us easily communicate variables between classes.
//****kept this snippet for function to save data to "disk" for game stats and settings****
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    if (standardUserDefaults) {
//        [standardUserDefaults setObject:[NSNumber numberWithInt:3] forKey:@"playerDirection"];
//        [standardUserDefaults synchronize];
//    }

@end
