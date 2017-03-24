//
//  MyPhoto.h
//  GpsRun
//
//  Created by Matthieu on 2/2/16.
//  Copyright © 2016 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MyComment.h"

@interface MyPhoto : NSObject 

@property (readwrite) int mID;
@property (readwrite) int mRunID;
@property (readwrite) float mLatitude;
@property (readwrite) float mLongitude;
@property (readwrite) NSString* mImagePath;
@property (readwrite) long mMilliseconds;
@property (readwrite) NSArray *comments;

- (void)addComment:(MyComment *)comment;

@end
