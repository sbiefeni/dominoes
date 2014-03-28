//
//  player.h
//  dominoes
//
//  Created by Stefano on 3/11/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "domGameScene.h"

@interface clsPlayer : NSObject

@property swipeDirection lastSwipe;
@property swipeDirection curDirection;

@property int curX;
@property int curY;

@property BOOL didExplosion;


@end
