//
//  domFunctions.m
//  dominoes
//
//  Created by Stefano on 3/13/14.
//  Copyright (c) 2014 Abstractions. All rights reserved.
//

#import "domFunctions.h"
#import "domMyScene.m"

@implementation domFunctions

// a recursive method used to find all similar blocks around a base block.
// the recursion allows us to reach beyond the current block's immediate neighbors to
// neighbors of neighbors, etc
//- (NSMutableArray*) nodesToRemove:(NSMutableArray*)removedNodes aroundNode:(BlockNode*)baseNode
//{
//    // make sure our base node is being removed
//    [removedNodes addObject:baseNode];
//
//    // go through all the blocks on the screen
//    for(BlockNode *childNode in [self getAllBlocks]) {
//
//        // if the node being tested is on one of the four sides off our base node
//        // and it is the same color, it is in range and valid to be removed
//        if([self inRange:childNode of:baseNode]) {
//
//            // if we have not already checked if this block is being removed
//            if(![removedNodes containsObject:childNode]) {
//
//                // test the blocks around this one for possible removal
//                removedNodes = [self nodesToRemove:removedNodes aroundNode:childNode];
//            }
//
//        }
//    }
//
//    return removedNodes;
//}
// gets the
-(int)countGrids:(int)gridCount  originX:(int)X  originY:(int)Y  usingGrid:(BOOL[cols][rows+1])grid
{
    int countSquares;
    countSquares = 1; //count the initial square

    return countSquares;
}
@end
