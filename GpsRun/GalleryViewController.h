//
//  GalleryViewController.h
//  GpsRun
//
//  Created by Matthieu on 2/2/16.
//  Copyright © 2016 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBPhotoPagesDataSource.h"
#import "EBPhotoPagesDelegate.h"

@interface GalleryViewController : UIViewController <EBPhotoPagesDataSource, EBPhotoPagesDelegate>
{
    NSMutableArray *photos;
}

@property (assign) BOOL simulateLatency;

@end
