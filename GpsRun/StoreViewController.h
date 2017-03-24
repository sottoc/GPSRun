
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "GlobalState.h"

@interface StoreViewController : UIViewController<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (weak, nonatomic) IBOutlet UIButton *buttonGetPro;
@property (weak, nonatomic) IBOutlet UIButton *buttonRestore;
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *inappId;
- (IBAction)buttonProAction:(id)sender;
- (IBAction)buttonRestoreAction:(id)sender;

@end

