
#import <UIKit/UIKit.h>
#import "GlobalState.h"
#import "EBPhotoPagesDataSource.h"
#import "EBPhotoPagesDelegate.h"

@interface HistoryViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, EBPhotoPagesDataSource, EBPhotoPagesDelegate>
{
    NSMutableArray *photos;
}

@property (assign) BOOL simulateLatency;

@end
