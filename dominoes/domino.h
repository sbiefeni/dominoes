//
//  domino.h
//  dominoes
//
//  Created by Stefano on 3/11/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface domino : SKSpriteNode

//store the x and y which correspond to grid
@property int X;
@property int y;
@property int direction;


@property BOOL player;


@end
