#import <ZXingObjC/ZXingObjC.h>
#import <UIKit/UIKit.h>

enum
{
    STATE_ADDED    = 0,
    STATE_LOADING  = 1,
    STATE_LOADING_FAIL = 2,
    STATE_OK        = 3,
    STATE_WARN      = 4,
    STATE_ERROR     = 5,
};

@interface ViewController : UIViewController <ZXCaptureDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@end