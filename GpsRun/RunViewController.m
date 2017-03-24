
#import "RunViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation RunViewController{
    long all_run_time;
    long all_run_distance;
    BOOL typeMode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    synth = [[AVSpeechSynthesizer alloc] init];
    
    self.timerPause = FALSE;
    typeMode = FALSE;
    run_time = 0;
    synth = [[AVSpeechSynthesizer alloc] init];
    
    run_distance = 0;
    avg_speed = 0;
    run_calories = 0;
    run_locations = [NSMutableArray array];
    photo_datas = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = 10; // meters
    [self.locationManager requestWhenInUseAuthorization];
    //if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    //    [self.locationManager requestWhenInUseAuthorization];
    //}
    [self.locationManager startUpdatingLocation];
    
    self.mapViewRun.delegate = self;
    [self.mapViewRun setShowsUserLocation:YES];
    
}

- (IBAction)buttonPauseAction:(id)sender {
    if (self.timerPause) {
        self.timerPause = FALSE;
        [self.buttonPause setTitle:@"PAUSE" forState:UIControlStateNormal];
    }
    else {
        self.timerPause = TRUE;
        [self.buttonPause setTitle:@"RESUME" forState:UIControlStateNormal];
    }
    if ([Settings boolForKey:@"checkVibration"]) { AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); }
    
}

- (IBAction)buttonStopAction:(id)sender {
    lastScreenshot = [self takeScreenshot];
    if ([Settings boolForKey:@"checkVibration"]) { AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); }
    
}

- (IBAction)buttonTakePhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imageCapture = [[UIImagePickerController alloc] init];
        imageCapture.sourceType = UIImagePickerControllerSourceTypeCamera;
        imageCapture.delegate = self;
        
        imageCapture.mediaTypes = @[(NSString *)kUTTypeJPEG, (NSString *)kUTTypePNG, (NSString *)kUTTypeImage];
        imageCapture.videoQuality = UIImagePickerControllerQualityTypeMedium;
        imageCapture.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        [self presentModalViewController:imageCapture animated:YES];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.timerPause = FALSE;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    [self.locationManager stopUpdatingLocation];
    [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    synth = nil;
}

- (void)onTimer {
    if (!self.timerPause) {
        run_time++;
        
        self.labelRunTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(run_time/3600),((run_time/60)%60),(run_time%60)];
        
        if (!(run_time % speak_interval)){
            if ([Settings boolForKey:@"voiseInterval"] & [Settings boolForKey:@"checkInstructorInterval"]) {
                utterance = [AVSpeechUtterance speechUtteranceWithString:[NSString stringWithFormat:@"%ld minutes passed",speak_interval/60]];
                utterance.rate = 0.28;
                [synth speakUtterance:utterance];
            }
            if ([Settings boolForKey:@"checkSounds"] & [Settings boolForKey:@"checkInstructorDistance"]) {
                utterance = [AVSpeechUtterance speechUtteranceWithString:[NSString stringWithFormat:@"Total distance is %.2f miles",run_distance/1609.344]];
                utterance.rate = 0.28;
                [synth speakUtterance:utterance];
            }
            if ([Settings boolForKey:@"checkSounds"] & [Settings boolForKey:@"checkInstructorTime"]) {
                utterance = [AVSpeechUtterance speechUtteranceWithString:[NSString stringWithFormat:@"Total time is %02ld hours %02ld minutes",(run_time/3600),((run_time/60)%60)]];
                utterance.rate = 0.28;
                [synth speakUtterance:utterance];
            }
        }
    }
    
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    if (!self.timerPause) {
        for (CLLocation *newLocation in locations) {
            
            NSDate *eventDate = newLocation.timestamp;
            
            NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
            
            if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
                
                // update distance
                if (run_locations.count > 0) {
                    run_distance += [newLocation distanceFromLocation:run_locations.lastObject];
                    
                    CLLocationCoordinate2D coords[2];
                    coords[0] = ((CLLocation *)run_locations.lastObject).coordinate;
                    coords[1] = newLocation.coordinate;
                    
                    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                    [self.mapViewRun setRegion:region animated:YES];
                    [self.mapViewRun addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                    
                    run_calories = (((float)run_time/3600)*(run_distance/1609.344))*100;
                    
                    [self updateLabels];
                }

                [run_locations addObject:newLocation];
            }
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
        
    } else if(error.code == kCLErrorLocationUnknown) {
        // retry
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = self.labelRunTime.textColor;
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    
    return nil;
}

- (void) updateLabels{
    self.labelRunCalories.text = [NSString stringWithFormat:@"%.2f lbs",run_calories/0.45359237];
    self.labelRunDistance.text = [NSString stringWithFormat:@"%.2f MILES",run_distance/1609.344];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

    CLLocation *location = [self.locationManager location];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    long l = [[NSDate date] timeIntervalSince1970];
    
    NSString *time = [NSString stringWithFormat:@"%d",l];
    NSString *path = [NSString stringWithFormat:@"Documents/Image%@.jpg",time];
    NSString *newFilePath = [NSHomeDirectory() stringByAppendingPathComponent: path];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData != nil) {
        [imageData writeToFile:newFilePath atomically:YES];
    }

    [dic setObject:location forKey:@"location"];
    [dic setObject:path forKey:@"imagepath"];
    [dic setObject:time forKey:@"time"];
    [photo_datas addObject:dic];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = [self.locationManager location].coordinate;
    [self.mapViewRun addAnnotation:point];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationIdentifier"];
    if(annotationView)
        return annotationView;
    else
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationIdentifier"];
        annotationView.canShowCallout = YES;
        
        annotationView.image = [UIImage imageNamed:@"marker"];
        annotationView.centerOffset = CGPointMake(0, -annotationView.frame.size.height/2);
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(writeSomething:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        annotationView.rightCalloutAccessoryView = rightButton;
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;
        return annotationView;
    }
    return nil;
}

- (UIImage*) takeScreenshot
{
    UIGraphicsBeginImageContext(self.mapViewRun.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.mapViewRun.layer renderInContext:context];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

@end
