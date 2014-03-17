//
//  domino.h
//  dominoes
//
//  Created by Stefano on 3/11/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface clsDomino : SKSpriteNode

//store the x and y which correspond to grid
@property int direction;

//is this a player domino, or computer
@property BOOL player;

@property NSMutableArray* dominos;

-(void) animateDomino;


@end
