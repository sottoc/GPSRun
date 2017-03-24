
#import "StoreViewController.h"

@interface StoreViewController ()

@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.buttonGetPro.layer.masksToBounds = YES;
    self.buttonGetPro.layer.cornerRadius = self.buttonGetPro.frame.size.height / 10.0;
    
    self.buttonRestore.layer.masksToBounds = YES;
    self.buttonRestore.layer.cornerRadius = self.buttonRestore.frame.size.height / 10.0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonProAction:(id)sender {
    self.inappId = InApp_id;
    [self buyItem];
}

- (IBAction)buttonRestoreAction:(id)sender {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)buyItem{
    if ([SKPaymentQueue canMakePayments])
    {
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.inappId]];
        request.delegate = self;
        [request start];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Check internet" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma _
#pragma SKProductRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    if (products.count != 0) {
        self.product = products[0];
        SKPayment *payment = [SKPayment paymentWithProduct:self.product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    
    products = response.invalidProductIdentifiers;
    for (SKProduct *product in products) {
        NSLog(@"%@", product);
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:[self SuccessPurchase];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:[self ErrorPurchase];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
                break;
            default:
                break;
        }
    }
}

-(void)SuccessPurchase {
    
    if ([self.inappId isEqualToString:InApp_id]) {
        [Settings setBool:TRUE forKey:@"adsRemoved"];
        [Settings synchronize];
    }
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)ErrorPurchase {
    
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            [Settings setBool:TRUE forKey:@"adsRemoved"];
            [Settings synchronize];
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
            break;
        }
        
    }
    
}


@end
