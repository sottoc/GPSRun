//
//  MyPhoto.m
//  GpsRun
//
//  Created by Matthieu on 2/2/16.
//  Copyright © 2016 developer. All rights reserved.
//

#import "MyPhoto.h"

@implementation MyPhoto

- (void)addComment:(MyComment *)comment
{
    NSMutableArray *mutableComments = [NSMutableArray arrayWithArray:self.comments];
    if(!mutableComments){
        mutableComments = [NSMutableArray array];
    }
    [mutableComments addObject:comment];
    
    [self setComments:[NSArray arrayWithArray:mutableComments]];
}

@end
