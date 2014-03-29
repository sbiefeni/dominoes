//
//  domMenuScene.m
//  dominoes
//
//  Created by Mauro Biefeni on 2014-03-14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//
#define isRunningInIde(x) if ([[[UIDevice currentDevice].model lowercaseString] rangeOfString:@"simulator"].location != NSNotFound){x;}


#import "domMenuScene.h"
#import "domGameScene.h"
#import "clsCommon.h"
#import "domViewController.h"

#import "SKEmitterNode+fromFile.h"

//#import <AudioToolbox/AudioServices.h>

@implementation domMenuScene
-(instancetype)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size]) {


        //start the background music track playing
        [domViewController setAdView:NO ShowOnTop:NO];
        [clsCommon playBackgroundMusicWithVolume:.2];


        SKEmitterNode *background = [SKEmitterNode dom_emitterNamed:@"Background_Stars"];
        background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
        [background advanceSimulationTime:10];

        self.backgroundColor = [SKColor blackColor];
        
        [self addChild:background];

        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];

        int sizeDoubler = 1;
        if (size.width > 320){ //make fonts and spacing bigger on larger screen
            sizeDoubler = 2;
        }

        title.text = @"brick'd";
        title.fontSize = (sizeDoubler * 60);
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame)+ 30*sizeDoubler);
        title.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:1.0];
        [self addChild:title];


        [self addChild: [self instruct:sizeDoubler]]; //instructions button, from below


        SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        tapToPlay.text = @"Tap to play";
        tapToPlay.fontSize = (sizeDoubler * 40);
        tapToPlay.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) - (30 * sizeDoubler) );
        tapToPlay.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.7];
        [self addChild:tapToPlay];
        
        //NSString *currentModeName = [[NSUserDefaults standardUserDefaults] stringForKey:ORBGameModeDefault];
        //_currentMode = NSClassFromString(currentModeName);
        //if(!_currentMode)
            //_currentMode = [self availableGameScenes][0];
        
        //_modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //_modeButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:40];
        //[_modeButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
        //_modeButton.frame = CGRectMake(0, (self.size.height - tapToPlay.position.y) + 20, self.size.width, 60);
        //[self updateModeButton];
        //[_modeButton addTarget:self action:@selector(selectMode) forControlEvents:UIControlEventTouchUpInside];




            [self runAction:[SKAction sequence:@[
                [SKAction waitForDuration:2],
                [SKAction runBlock:^{
                    isRunningInIde(
                            domGameScene *game = [[domGameScene alloc] initWithSize:self.size];
                            [self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:1.5]];
                    )
                }],
            ]]];


    }
    return self;
}

- (SKSpriteNode *)instruct:(int)sizeDoubler
{
    SKSpriteNode *instruct = [SKSpriteNode spriteNodeWithImageNamed:@"directions"];
    instruct.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame) - (150 * sizeDoubler) );
    instruct.name = @"instructions";//how the node is identified later
    instruct.zPosition = 10;
    instruct.alpha = .7;
    return instruct;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    @autoreleasepool {

    domGameScene *game = [[domGameScene alloc] initWithSize:self.size];

    [self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:1.5]];
    //game.gameSpeed = 5;

    }
}

@end
