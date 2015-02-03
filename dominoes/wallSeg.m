//
//  wallSeg.m
//  300
//
//  Created by Stefano on 2015-01-29.
//  Copyright (c) 2015 Abstractions. All rights reserved.
//

#import "wallSeg.h"
#import "domGameScene.h"
#import "clsGameSettings.h"

#define wallZpos        7

@implementation wallSeg{

    
}

-(id)init{
    if((self=[super init])){

        _Hsegment = [SKSpriteNode spriteNodeWithImageNamed:@"dom-blue-horizontal"];
        _Hsegment.color = [SKColor purpleColor];
        _Hsegment.colorBlendFactor = 1;
        _Hsegment.size = CGSizeMake(dominoSize.width * 1.1,  dominoSize.height * .5 );
       // _Hsegment.xScale = dominoScaleFactorX;

        _Vsegment = [SKSpriteNode spriteNodeWithImageNamed:@"dom-blue-vertical"];
        _Vsegment.color = [SKColor purpleColor];
        _Vsegment.colorBlendFactor = 1;
        //_Vsegment.xScale = .4;
       // _Vsegment.yScale = dominoSize.height;
        _Vsegment.size = CGSizeMake(dominoSize.width * .5, dominoSize.height * 1.30);
    }

    return self;
}


-(void)set1X:(int)g1X withg1Y:(int)g1Y withg2X:(int)g2X withg2Y:(int)g2Y withVertical:(bool)vertical{

    self.g1X = g1X;
    self.g1Y = g1Y;
    self.g2X = g2X;
    self.g2Y = g2Y;

    self.vertical = vertical;

}

-(void)drawSegmentOnScene:(domGameScene*)scene{

    if(_vertical){
        _Vsegment.position = [self calcSegmentPositionOnScene:scene];
        _Vsegment.zPosition = wallZpos;
        [scene addChild:_Vsegment];
    }else{
        _Hsegment.position = [self calcSegmentPositionOnScene:scene];
        _Hsegment.zPosition = wallZpos;
        [scene addChild:_Hsegment];
    }
    
}

-(CGPoint)calcSegmentPositionOnScene:(domGameScene*)scene{

    CGPoint p1 = [scene calcDominoPosition:_g1X withArg2:_g1Y];
    CGPoint p2 = [scene calcDominoPosition:_g2X withArg2:_g2Y];

    CGPoint wallPoint;

    if(!_vertical){
        wallPoint = CGPointMake(p1.x, (p1.y+p2.y)/2);
    }else{
        wallPoint = CGPointMake((p1.x + p2.x)/2, p1.y);
    }

    return wallPoint;

}
@end
