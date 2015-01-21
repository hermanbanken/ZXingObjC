#import "Settings.h"
#import "UIKit/UIColor.h"

@interface Settings ()
    @property UITableView *tableView;
@end

UITextField * actionUrl;

@implementation Settings

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.section == 0)
    switch(indexPath.row){
        case 0:
            cell.textLabel.text = @"Action URL";

            actionUrl = [[UITextField alloc] initWithFrame:cell.detailTextLabel.frame];
            actionUrl.placeholder = @"http://example.org/?barcode=[scan]";
            actionUrl.keyboardType = UIKeyboardTypeURL;
            actionUrl.text = @"";
            [actionUrl setClearButtonMode:UITextFieldViewModeWhileEditing];
            [cell addSubview:actionUrl];
            break;
        case 1:
            break;
    }

    return cell;
}

@end