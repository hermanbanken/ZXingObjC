#import "Settings.h"
#import "UIKit/UIColor.h"

@interface Settings ()
    @property UITableView *tableView;
@end

UITextField * actionUrl;
UITextField * detailsUrl;

@implementation Settings

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Action URL";
    else
        return @"Details URL";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0)
    return [NSString stringWithFormat: @"Use a regular URL here, or a application URL. Any occurrences of [scan] will be replaced by the contents of the barcode or QR code. Any occurrences of [device] will be replaced with your device id (%@).", [self.defaults valueForKey:@"uuid"]];
    else
        return @"URL to open upon clicking scan. For showing more details. Expects html output.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:CellIdentifier];
    }
    
    switch(indexPath.section){
        case 0:
            actionUrl = [[UITextField alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 15, 0)];
            actionUrl.placeholder = @"http://abc.com/action?bc=[scan]";
            if(self.defaults){
                actionUrl.text = [self.defaults valueForKey:@"action_url"] ?: @"";
            }
            actionUrl.keyboardType = UIKeyboardTypeURL;
            actionUrl.returnKeyType = UIReturnKeyDone;
            [actionUrl setClearButtonMode:UITextFieldViewModeWhileEditing];
            actionUrl.delegate = self;
            [cell addSubview:actionUrl];
            break;
        case 1:
            detailsUrl = [[UITextField alloc] initWithFrame:CGRectInset(cell.contentView.bounds, 15, 0)];
            detailsUrl.placeholder = @"http://abc.com/details?bc=[scan]";
            if(self.defaults){
                detailsUrl.text = [self.defaults valueForKey:@"details_url"] ?: @"";
            }
            detailsUrl.keyboardType = UIKeyboardTypeURL;
            detailsUrl.returnKeyType = UIReturnKeyDone;
            [detailsUrl setClearButtonMode:UITextFieldViewModeWhileEditing];
            detailsUrl.delegate = self;
            [cell addSubview:detailsUrl];
            break;
    }

    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == actionUrl || textField == detailsUrl){
        if (textField.text.length == 0 || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:textField.text]])
        {
            return [textField resignFirstResponder];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"URL error"
                                  message:[NSString stringWithFormat: @"No custom URL defined for %@", textField.text]
                                  delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
            [alert show];
            return YES;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(!self.defaults){
        self.defaults = [NSUserDefaults standardUserDefaults];
    }
    if(textField == actionUrl || textField == detailsUrl){
        if (textField.text.length == 0 || [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:textField.text]])
        {
            if(textField == actionUrl)
                [self.defaults setObject:textField.text forKey:@"action_url"];
            if(textField == detailsUrl)
                [self.defaults setObject:textField.text forKey:@"details_url"];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionUrl.text]];
        }
    }
    [self.defaults synchronize];
}

#pragma mark KeyBoardHandling
/* https://gist.github.com/TimMedcalf/9505416 @ CopyRight <- TimMedcalf */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*
     your code here
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    /*
     your code here
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:animated];
}

UIEdgeInsets edgeInsets;
UIEdgeInsets scrollInsets;
- (void)keyboardWillShow:(NSNotification *)notification {
    //get the end position keyboard frame
    NSDictionary *keyInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    //convert it to the same view coords as the tableView it might be occluding
    keyboardFrame = [self.tableView convertRect:keyboardFrame fromView:nil];
    //calculate if the rects intersect
    CGRect intersect = CGRectIntersection(keyboardFrame, self.tableView.bounds);
    if (!CGRectIsNull(intersect)) {
        //yes they do - adjust the insets on tableview to handle it
        //first get the duration of the keyboard appearance animation
        NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
        //change the table insets to match - animated to the same duration of the keyboard appearance
        [UIView animateWithDuration:duration animations:^{
            edgeInsets = self.tableView.contentInset;
            self.tableView.contentInset = UIEdgeInsetsMake(edgeInsets.top, edgeInsets.left, intersect.size.height, 0);
            scrollInsets = self.tableView.scrollIndicatorInsets;
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, intersect.size.height, 0);
        }];
    }
}

- (void) keyboardWillHide:  (NSNotification *) notification{
    NSDictionary *keyInfo = [notification userInfo];
    NSTimeInterval duration = [[keyInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    //clear the table insets - animated to the same duration of the keyboard disappearance
    [UIView animateWithDuration:duration animations:^{
        self.tableView.contentInset = edgeInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
    }];
}

@end