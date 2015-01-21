#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"
#import "UIKit/UIColor.h"
#import "Settings.h"

@interface ViewController ()

@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) IBOutlet UIView *scanRectView;
@property (nonatomic, weak) IBOutlet UILabel *decodedLabel;
@property (weak, nonatomic) IBOutlet UITableView *scanList;
@property (strong, nonatomic) NSMutableArray *scans;
@property (strong, nonatomic) NSMutableArray *scan_dates;

@end

NSDateFormatter *dateFormatter;

@implementation ViewController

#pragma mark - View Controller Methods

- (void)viewDidLoad {
  [super viewDidLoad];
    self.title = @"Tickets";
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0f;
    self.capture.camera = self.capture.back;
    self.capture.reader = [[ZXEAN13Reader alloc] init];
    [self positionCapture];
    
    self.scans = [[NSMutableArray alloc] init];
    self.scan_dates = [[NSMutableArray alloc] init];
    self.scanList.dataSource = self;
        
    UIBarButtonItem *barDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];

    [self.navigationItem setRightBarButtonItem:barDoneButton];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scanRectView.frame = CGRectMake(self.scanRectView.frame.origin.x, self.scanRectView.frame.origin.y, self.scanRectView.frame.size.width, self.scanRectView.frame.size.width * 9 / 16);
    self.scanList.frame = CGRectIntersection(self.view.bounds, CGRectOffset(self.view.bounds, 0, self.scanRectView.frame.size.height));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.decodedLabel.text = @"Press camera area to scan.";
    self.capture.delegate = self;
    [self positionCapture];
}

- (void) positionCapture {
    self.capture.layer.frame = self.scanRectView.bounds;
    [self.scanRectView.layer addSublayer:self.capture.layer];
    [self.scanRectView bringSubviewToFront:self.decodedLabel];
}
- (void) startCapture {
    self.capture.delegate = self;
    [self positionCapture];
}
- (void) stopCapture {
    self.capture.delegate = nil;
    [self positionCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopCapture];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)settings:(id)sender {
    UIViewController * settings = [[Settings alloc] init];
    if(self.navigationController.visibleViewController == self)
        [self.navigationController pushViewController:settings animated:TRUE];
}

#pragma mark - Private Methods

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
  switch (format) {
    case kBarcodeFormatAztec:
      return @"Aztec";

    case kBarcodeFormatCodabar:
      return @"CODABAR";

    case kBarcodeFormatCode39:
      return @"Code 39";

    case kBarcodeFormatCode93:
      return @"Code 93";

    case kBarcodeFormatCode128:
      return @"Code 128";

    case kBarcodeFormatDataMatrix:
      return @"Data Matrix";

    case kBarcodeFormatEan8:
      return @"EAN-8";

    case kBarcodeFormatEan13:
      return @"EAN-13";

    case kBarcodeFormatITF:
      return @"ITF";

    case kBarcodeFormatPDF417:
      return @"PDF417";

    case kBarcodeFormatQRCode:
      return @"QR Code";

    case kBarcodeFormatRSS14:
      return @"RSS 14";

    case kBarcodeFormatRSSExpanded:
      return @"RSS Expanded";

    case kBarcodeFormatUPCA:
      return @"UPCA";

    case kBarcodeFormatUPCE:
      return @"UPCE";

    case kBarcodeFormatUPCEANExtension:
      return @"UPC/EAN extension";

    default:
      return @"Unknown";
  }
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result) return;

    NSDate *date = [[NSDate alloc] init];
    if(
       self.scan_dates.count == 0 ||
       ![result.text isEqualToString:[self.scans lastObject]] ||
       [date timeIntervalSinceDate:[self.scan_dates lastObject]] > 2
    ){
        // Add number
        [self.scans addObject:result.text];
        [self.scanList reloadData];
        // Add time
        [self.scan_dates addObject:date];
        
        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

#pragma mark Table View Data Source Methods

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.scans count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Scans";
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifer = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifer];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [self.scans objectAtIndex:row];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[self.scan_dates objectAtIndex:row]];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Select checkin
    return true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.decodedLabel.text = @"Scanning";
    self.decodedLabel.textColor = [UIColor greenColor];
    [self startCapture];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self stopCapture];
    self.decodedLabel.text = @"Press camera area to scan";
    self.decodedLabel.textColor = [UIColor redColor];
}

@end
