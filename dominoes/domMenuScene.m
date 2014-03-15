//
//  domMenuScene.m
//  dominoes
//
//  Created by Mauro Biefeni on 2014-03-14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domMenuScene.h"
#import "domGameScene.h"
#import "SKEmitterNode+fromFile.h"

@implementation domMenuScene
-(instancetype)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size]) {
        SKEmitterNode *background = [SKEmitterNode dom_emitterNamed:@"Background"];
        background.particlePositionRange = CGVectorMake(self.size.width*2, self.size.height*2);
        [background advanceSimulationTime:10];
        
        [self addChild:background];
        
        SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        
        title.text = @"Flappy\nBricks";
        title.fontSize = 48;
        title.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame));
        title.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:1.0];
        
        [self addChild:title];
        
        SKLabelNode *tapToPlay = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Black"];
        
        tapToPlay.text = @"Tap to play";
        tapToPlay.fontSize = 40;
        tapToPlay.position = CGPointMake(CGRectGetMidX(self.frame),
                                         CGRectGetMidY(self.frame) - 80);
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
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    domGameScene *game = [[domGameScene alloc] initWithSize:self.size];
    [self.view presentScene:game transition:[SKTransition doorsOpenHorizontalWithDuration:1.5]];
}

@end
