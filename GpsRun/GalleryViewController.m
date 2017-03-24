//
//  GalleryViewController.m
//  GpsRun
//
//  Created by Matthieu on 2/2/16.
//  Copyright © 2016 developer. All rights reserved.
//

#import "GalleryViewController.h"
#import "GlobalState.h"
#import "MyPhoto.h"
#import "MyComment.h"
#import "EBPhotoPagesController.h"

@interface GalleryViewController ()

@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSimulateLatency:NO];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadPhotos];
}

- (void) loadPhotos
{
    photos = [[NSMutableArray alloc] init];
    //ID, RUNID, LAT, LOG, PATH, TIME
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &workoutDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM PHOTOS ORDER BY ID DESC"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(workoutDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                MyPhoto* photo = [[MyPhoto alloc] init];
                photo.mID = sqlite3_column_int(statement, 0);
                photo.mRunID = sqlite3_column_int(statement, 1);
                photo.mLatitude = sqlite3_column_double(statement, 2);
                photo.mLongitude = sqlite3_column_double(statement, 3);
                photo.mImagePath = [NSString stringWithFormat:@"%s",sqlite3_column_text(statement, 4)];
                photo.mMilliseconds = [[NSString stringWithFormat:@"%s",sqlite3_column_text(statement, 5)] longLongValue];
                photo.comments = [NSArray array];
                
                [photos addObject:photo];
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(workoutDB);
    }

    EBPhotoPagesController *photoPagesController = [[EBPhotoPagesController alloc] initWithDataSource:self delegate:self];
    [self presentViewController:photoPagesController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EBPhotoPagesDataSource

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index
{
    if(index < photos.count){
        return YES;
    }
    
    return NO;
}

- (void)photoPagesController:(EBPhotoPagesController *)controller imageAtIndex:(NSInteger)index completionHandler:(void (^)(UIImage *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        MyPhoto *photo = [photos objectAtIndex:index];
        
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent: photo.mImagePath];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:imageData];
        
        handler(image);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller attributedCaptionForPhotoAtIndex:(NSInteger)index completionHandler:(void (^)(NSAttributedString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        MyPhoto *photo = [photos objectAtIndex:index];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:photo.mMilliseconds / 1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        handler([[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@(%f,%f)", [dateFormatter stringFromDate:date], photo.mLatitude, photo.mLongitude]]);
    });
}

- (void)photoPagesController:(EBPhotoPagesController *)controller captionForPhotoAtIndex:(NSInteger)index completionHandler:(void (^)(NSString *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        MyPhoto *photo = [photos objectAtIndex:index];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:photo.mMilliseconds / 1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        handler([NSString stringWithFormat:@"%@(%f,%f)", [dateFormatter stringFromDate:date], photo.mLatitude, photo.mLongitude]);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller metaDataForPhotoAtIndex:(NSInteger)index completionHandler:(void (^)(NSDictionary *))handler
{
}

- (void)photoPagesController:(EBPhotoPagesController *)controller tagsForPhotoAtIndex:(NSInteger)index completionHandler:(void (^)(NSArray *))handler
{
}


- (void)photoPagesController:(EBPhotoPagesController *)controller commentsForPhotoAtIndex:(NSInteger)index completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        MyPhoto *photo = [photos objectAtIndex:index];
        
        handler(photo.comments);
    });
}


- (void)photoPagesController:(EBPhotoPagesController *)controller numberOfcommentsForPhotoAtIndex:(NSInteger)index completionHandler:(void (^)(NSInteger))handler
{
    MyPhoto *photo = [photos objectAtIndex:index];
   
    handler(photo.comments.count);
}


- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController didReportPhotoAtIndex:(NSInteger)index
{
    NSLog(@"Reported photo at index %li", (long)index);
}



- (void)photoPagesController:(EBPhotoPagesController *)controller didDeleteComment:(id<EBPhotoCommentProtocol>)deletedComment forPhotoAtIndex:(NSInteger)index
{
    MyPhoto *photo = [photos objectAtIndex:index];
    NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:photo.comments];
    [remainingComments removeObject:deletedComment];
    [photo setComments:[NSArray arrayWithArray:remainingComments]];
}


- (void)photoPagesController:(EBPhotoPagesController *)controller didDeleteTagPopover:(EBTagPopover *)tagPopover inPhotoAtIndex:(NSInteger)index
{
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController didDeletePhotoAtIndex:(NSInteger)index
{
    NSLog(@"Delete photo at index %li", (long)index);
    MyPhoto *photo = [photos objectAtIndex:index];
    [photos removeObjectAtIndex:index];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didAddNewTagAtPoint:(CGPoint)tagLocation
                    withText:(NSString *)tagText
             forPhotoAtIndex:(NSInteger)index
                     tagInfo:(NSDictionary *)tagInfo
{
    
}

- (void)photoPagesController:(EBPhotoPagesController *)controller didPostComment:(NSString *)comment forPhotoAtIndex:(NSInteger)index
{
    MyComment *newComment = [MyComment
                               commentWithProperties:@{@"commentText": comment,
                                                       @"commentDate": [NSDate date]}];
    [newComment setUserCreated:YES];
    
     MyPhoto *photo = [photos objectAtIndex:index];
    [photo addComment:newComment];
    
    [controller setComments:photo.comments forPhotoAtIndex:index];
}



#pragma mark - User Permissions

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowTaggingForPhotoAtIndex:(NSInteger)index
{
    return YES;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)controller shouldAllowDeleteForComment:(id<EBPhotoCommentProtocol>)comment forPhotoAtIndex:(NSInteger)index
{
    return YES;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowCommentingForPhotoAtIndex:(NSInteger)index
{
    return YES;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowActivitiesForPhotoAtIndex:(NSInteger)index
{
    return YES;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowMiscActionsForPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowDeleteForPhotoAtIndex:(NSInteger)index
{
    return YES;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowDeleteForTag:(EBTagPopover *)tagPopover inPhotoAtIndex:(NSInteger)index
{
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowEditingForTag:(EBTagPopover *)tagPopover inPhotoAtIndex:(NSInteger)index
{
    return NO;
}


- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController shouldAllowReportForPhotoAtIndex:(NSInteger)index
{
    return YES;
}


#pragma mark - EBPPhotoPagesDelegate


- (void)photoPagesControllerDidDismiss:(EBPhotoPagesController *)photoPagesController
{
    NSLog(@"Finished using %@", photoPagesController);
}

@end
