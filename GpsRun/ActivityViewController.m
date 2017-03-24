
#import "ActivityViewController.h"

@implementation ActivityViewController{
    int total_workouts;
    long total_calories;
    long total_time;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    total_workouts = 0;
    total_calories = 0;
    
    [self loadDataItems];
    self.labelWorkouts.text = [NSString stringWithFormat:@"%d",total_workouts];
    if (total_time) self.labelTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(total_time/3600),((total_time/60)%60),(total_time%60)];
    self.labelCalories.text = [NSString stringWithFormat:@"%.2f lbs",total_calories/0.45359237];
    
    [self loadLastActivityItems];
    [self chartSetup];
    [_chart reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadDataItems {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &workoutDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM WORKOUTS"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(workoutDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //int uniqueID = sqlite3_column_int(statement, 0);
                long time = sqlite3_column_int(statement, 2);
                int calories = sqlite3_column_int(statement, 4);
                
                total_workouts++;
                total_time = total_time+time;
                total_calories = total_calories + calories;
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(workoutDB);
    }
    
}

- (void) loadLastActivityItems {
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    float dis1 = 0;
    float dis2 = 0;
    float dis3 = 0;
    float dis4 = 0;
    float dis5 = 0;
    float dis6 = 0;
    float dis7 = 0;
    float dis8 = 0;
    
    if (sqlite3_open(dbpath, &workoutDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM WORKOUTS ORDER BY ID DESC LIMIT 8"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(workoutDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //int uniqueID = sqlite3_column_int(statement, 0);
                
                if (dis1 == 0) { dis1 = sqlite3_column_int(statement, 3)/1609.344; }
                else if (dis2 == 0) { dis2 = sqlite3_column_int(statement, 3)/1609.344; }
                else if (dis3 == 0) { dis3 = sqlite3_column_int(statement, 3)/1609.344; }
                else if (dis4 == 0) { dis4 = sqlite3_column_int(statement, 3)/1609.344; }
                else if (dis5 == 0) { dis5 = sqlite3_column_int(statement, 3)/1609.344; }
                else if (dis6 == 0) { dis6 = sqlite3_column_int(statement, 3)/1609.344; }
                else if (dis7 == 0) { dis7 = sqlite3_column_int(statement, 3)/1609.344; }
                else if (dis8 == 0) { dis8 = sqlite3_column_int(statement, 3)/1609.344; }
                
            }
            _values	= @[[NSNumber numberWithFloat:dis1], [NSNumber numberWithFloat:dis2], [NSNumber numberWithFloat:dis3], [NSNumber numberWithFloat:dis4], [NSNumber numberWithFloat:dis5], [NSNumber numberWithFloat:dis6], [NSNumber numberWithFloat:dis7], [NSNumber numberWithFloat:dis8]];
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(workoutDB);
    }
    
}

- (void) chartSetup {
    
    _barColors						= @[orange_color, [UIColor redColor], [UIColor blackColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor greenColor]];
    _currentBarColor				= 0;
    CGRect chartFrame				= CGRectMake(0.0, 0.0, 300.0, 140.0);
    _chart							= [[SimpleBarChart alloc] initWithFrame:chartFrame];
    _chart.center					= CGPointMake(self.chartViewBlock.frame.size.width / 2.0, self.chartViewBlock.frame.size.height / 2.0 + 7);
    _chart.delegate					= self;
    _chart.dataSource				= self;
    //_chart.barShadowOffset			= CGSizeMake(2.0, 1.0);
    _chart.animationDuration		= 1.0;
    //_chart.barShadowColor			= [UIColor grayColor];
    //_chart.barShadowAlpha			= 0.5;
    //_chart.barShadowRadius			= 1.0;
    _chart.barWidth					= 18.0;
    _chart.xLabelType				= SimpleBarChartXLabelTypeHorizontal;
    _chart.incrementValue			= 1;
    _chart.barTextType				= SimpleBarChartBarTextTypeRoof;
    _chart.barTextColor				= [UIColor colorWithRed:(201/255.0) green:(71/255.0) blue:(75/255.0) alpha:1];
    _chart.gridColor				= [UIColor whiteColor];
    
    [self.chartViewBlock addSubview:_chart];
}

#pragma mark SimpleBarChartDataSource

- (NSUInteger)numberOfBarsInBarChart:(SimpleBarChart *)barChart
{
    return _values.count;
}

- (CGFloat)barChart:(SimpleBarChart *)barChart valueForBarAtIndex:(NSUInteger)index
{
    return [[_values objectAtIndex:index] floatValue];
}

- (NSString *)barChart:(SimpleBarChart *)barChart textForBarAtIndex:(NSUInteger)index
{
    return [[_values objectAtIndex:index] stringValue];
}

- (NSString *)barChart:(SimpleBarChart *)barChart xLabelForBarAtIndex:(NSUInteger)index
{
    return [[_values objectAtIndex:index] stringValue];
}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
    return [_barColors objectAtIndex:_currentBarColor];
}


@end
