
#import "FinishViewController.h"

@interface FinishViewController (){
    long runid;
}

@end

@implementation FinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    synth = [[AVSpeechSynthesizer alloc] init];
    
    if ([Settings boolForKey:@"checkSounds"] & [Settings boolForKey:@"checkInstructorDistance"]) {
        utterance = [AVSpeechUtterance speechUtteranceWithString:[NSString stringWithFormat:@"Total distance is %.2f miles",run_distance/1609.344]];
        utterance.rate = 0.28;
        [synth speakUtterance:utterance];
    }
    
    self.labelTotal.text = [NSString stringWithFormat:@"TOTAL DISTANCE: %.2f miles",run_distance/1609.344];
    
    if (![Settings boolForKey:@"adsRemoved"]) {
        self.interstitial = [[GADInterstitial alloc] init];
        self.interstitial.adUnitID = Admob_id;
        self.interstitial.delegate = self;
        GADRequest *request = [GADRequest request];
        [self.interstitial loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)buttonShareAction:(id)sender {
    NSString *message = [NSString stringWithFormat:@"BEST RUN EVER! %.2f miles",run_distance/1609.344];
    
    NSArray *postItems = @[message];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)buttonSaveAction:(id)sender {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy (hh:mm)"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    [self saveDataItem:dateString ontime:run_time ondistance:run_distance oncalories:run_calories];
    
    [self saveDataPosition];
    [self saveTakenPhotos];
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:self];
    }
}

- (void) saveDataItem:(NSString *)date ontime:(long)time ondistance:(float)distance oncalories:(long)calories {
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &workoutDB) == SQLITE_OK)
    {
        NSString *path = @"";
        
        if(lastScreenshot != nil){
            long l = [[NSDate date] timeIntervalSince1970];
            NSString *time = [NSString stringWithFormat:@"%d",l];
            path = [NSString stringWithFormat:@"Documents/Screenshot%@.jpg",time];
            NSString *newFilePath = [NSHomeDirectory() stringByAppendingPathComponent: path];
            
            NSData *imageData = UIImageJPEGRepresentation(lastScreenshot, 1.0);
            if (imageData != nil) {
                [imageData writeToFile:newFilePath atomically:YES];
            }
        }
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO WORKOUTS (date, time, distance, calories, route) VALUES ( \"%@\", \"%ld\", \"%f\", \"%ld\", \"%@\")", date, time, distance, calories, path];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(workoutDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Item added");
        } else {
            NSLog(@"Failed to add item");
        }
        sqlite3_finalize(statement);
        runid = sqlite3_last_insert_rowid(workoutDB);
        sqlite3_close(workoutDB);
    }
}

- (void) saveDataPosition {
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    BOOL tr = TRUE;
    
    if (sqlite3_open(dbpath, &workoutDB) == SQLITE_OK)
    {
        
        for (CLLocation *location in run_locations) {
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO POSITIONS (runid, lat, log) VALUES ( \"%ld\", \"%f\",\"%f\")", runid, location.coordinate.latitude,location.coordinate.longitude];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(workoutDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Position item added");
            } else {
                NSLog(@"Failed to add position item");
                tr = FALSE;
            }
            
            sqlite3_finalize(statement);
        }
        if (tr) self.labelSaved.hidden = FALSE;
        sqlite3_close(workoutDB);
    }
}

- (void) saveTakenPhotos {
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    BOOL tr = TRUE;
    
    if (sqlite3_open(dbpath, &workoutDB) == SQLITE_OK)
    {
        
        for (NSMutableDictionary *dic in photo_datas) {
            CLLocation *loc = [dic objectForKey:@"location"];
            CLLocation *path = [dic objectForKey:@"imagepath"];
            NSString *time = [dic objectForKey:@"time"];
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PHOTOS (runid, lat, log, path, time) VALUES ( \"%ld\", \"%f\",\"%f\",\"%@\",\"%@\")", runid, loc.coordinate.latitude,loc.coordinate.longitude,path, time];
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(workoutDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Position item added");
            } else {
                NSLog(@"Failed to add position item");
                tr = FALSE;
            }
            
            sqlite3_finalize(statement);
        }
        if (tr) self.labelSaved.hidden = FALSE;
        sqlite3_close(workoutDB);
    }
}


@end
