#import <UIKit/UIKit.h>

@interface Settings : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

    @property (nonatomic, strong) NSUserDefaults *defaults;

@end