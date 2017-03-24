
#import "HomeViewController.h"

@implementation HomeViewController {
    float total_distance;
    NSString *last_date;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UITabBarItem *item1 = [self.tabBarController.tabBar.items objectAtIndex:0];
    item1.image = [[UIImage imageNamed:@"tab1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.selectedImage = [[UIImage imageNamed:@"tab1.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:1];
    item2.image = [[UIImage imageNamed:@"tab2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.selectedImage = [[UIImage imageNamed:@"tab2.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item3 = [self.tabBarController.tabBar.items objectAtIndex:2];
    item3.image = [[UIImage imageNamed:@"tab3.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item3.selectedImage = [[UIImage imageNamed:@"tab3.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item4 = [self.tabBarController.tabBar.items objectAtIndex:3];
    item4.image = [[UIImage imageNamed:@"tab4.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item4.selectedImage = [[UIImage imageNamed:@"tab4.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item5 = [self.tabBarController.tabBar.items objectAtIndex:4];
    item5.image = [[UIImage imageNamed:@"tab5.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item5.selectedImage = [[UIImage imageNamed:@"tab5.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //UITabBarItem *item6 = [self.tabBarController.tabBar.items objectAtIndex:5];
    //item6.image = [[UIImage imageNamed:@"tab4.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //item6.selectedImage = [[UIImage imageNamed:@"tab4.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self loadDatabase];
    [self loadHomeItems];
    
    if (total_distance) self.titleTotalDistance.text = [NSString stringWithFormat:@"%.2f",total_distance/1609.344];
    if (last_date) self.titleLastRun.text = [NSString stringWithFormat:@"LAST RUN: %@", [last_date substringToIndex:10]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadDatabase {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"contacts.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &workoutDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS WORKOUTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, DATE TEXT, TIME INTEGER, DISTANCE FLOAT, CALORIES INTEGER, ROUTE STRING)";
            
            if (sqlite3_exec(workoutDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            
            const char *sql_stmt2 = "CREATE TABLE IF NOT EXISTS POSITIONS (ID INTEGER PRIMARY KEY AUTOINCREMENT, RUNID INTEGER, LAT FLOAT, LOG FLOAT)";
            
            if (sqlite3_exec(workoutDB, sql_stmt2, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table positions");
            }
            
            const char *sql_stmt3 = "CREATE TABLE IF NOT EXISTS PHOTOS (ID INTEGER PRIMARY KEY AUTOINCREMENT, RUNID INTEGER, LAT FLOAT, LOG FLOAT, PATH STRING, TIME STRING)";
            
            if (sqlite3_exec(workoutDB, sql_stmt3, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table photos");
            }
            
            sqlite3_close(workoutDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void) loadHomeItems {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &workoutDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM WORKOUTS ORDER BY ID DESC"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(workoutDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //int uniqueID = sqlite3_column_int(statement, 0);
                float distance = sqlite3_column_int(statement, 3);
                
                total_distance = total_distance+distance;
                last_date = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(workoutDB);
    }
}


- (IBAction)buttonStartAction:(id)sender {
    if ([Settings boolForKey:@"checkVibration"]) { AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); }
}



@end
