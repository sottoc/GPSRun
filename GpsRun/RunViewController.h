
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GlobalState.h"

@interface RunViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate, UIImagePickerControllerDelegate>{
    AVSpeechUtterance *utterance;
    AVSpeechSynthesizer *synth;
}

- (IBAction)buttonPauseAction:(id)sender;
- (IBAction)buttonStopAction:(id)sender;
- (IBAction)buttonTakePhoto:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *buttonPause;

@property (nonatomic) NSTimer *timer;
@property (nonatomic) BOOL timerPause;
@property (weak, nonatomic) IBOutlet UILabel *labelRunTime;
@property (weak, nonatomic) IBOutlet UILabel *labelRunCalories;
@property (weak, nonatomic) IBOutlet UILabel *labelRunDistance;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapViewRun;


@end
