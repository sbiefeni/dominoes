//
//  wallSegPair.m
//  300
//
//  Created by Stefano on 2015-01-29.
//  Copyright (c) 2015 Abstractions. All rights reserved.
//

#import "gridSeg.h"

@implementation gridSeg

-(id)init{
    if((self=[super init])){

    }
    return self;
}

-(void)setX:(int)X withY:(int)Y{

    self.Xcoord = X;
    self.Ycoord = Y;

}
@end
