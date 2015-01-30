//
//  wallSeg.h
//  300
//
//  Created by Stefano on 2015-01-29.
//  Copyright (c) 2015 Abstractions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface wallSeg : NSObject

@property int g1X;
@property int g1Y;
@property int g2X;
@property int g2Y;
@property SKSpriteNode* Vsegment;
@property SKSpriteNode* Hsegment;

@property BOOL vertical;


-(void)set1X:(int)g1X withg1Y:(int)g1Y withg2X:(int)g2X withg2Y:(int)g2Y withVertical:(bool)vertical;

-(void)drawSegmentOnScene:(SKScene*)scene;

@end
