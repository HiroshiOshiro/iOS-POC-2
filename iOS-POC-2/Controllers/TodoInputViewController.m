#import "TodoInputViewController.h"
#import "TodoStore.h"
#import "TodoItem.h"
#import "UIViewController+CustomNavBar.h"

static NSString *const kCellIdentifier = @"TodoCell";

@interface TodoInputViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<TodoItem *> *items;
@end

@implementation TodoInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
}

- (void)resetInput {
    self.textField.text = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadItems];
}

#pragma mark - Setup

- (void)setupViews {
    // テキストボックス
    self.textField = [[UITextField alloc] init];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.placeholder = NSLocalizedString(@"todo.input.placeholder", nil);
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    [self.view addSubview:self.textField];

    // 保存ボタン
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [saveButton setTitle:NSLocalizedString(@"todo.input.save", nil) forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [saveButton addTarget:self
                   action:@selector(didTapSave)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];

    // 保存済み一覧テーブル
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.view addSubview:self.tableView];

    // 独自ナビゲーションバー（ルート画面なので戻るボタンなし）
    CustomNavigationBar *navBar =
        [self installCustomNavigationBarWithTitle:NSLocalizedString(@"todo.input.title", nil)
                                  showsBackButton:NO];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.textField.topAnchor constraintEqualToAnchor:navBar.bottomAnchor constant:16],
        [self.textField.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:16],
        [self.textField.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-16],

        [saveButton.topAnchor constraintEqualToAnchor:self.textField.bottomAnchor constant:12],
        [saveButton.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-16],

        [self.tableView.topAnchor constraintEqualToAnchor:saveButton.bottomAnchor constant:12],
        [self.tableView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
    ]];
}

#pragma mark - Actions

- (void)didTapSave {
    NSString *text = [self.textField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        [self showAlertWithMessage:NSLocalizedString(@"todo.input.empty_alert", nil)];
        return;
    }
    [self.textField resignFirstResponder];

    // 遷移は Coordinator が管理する。ここでは「確定した」ことだけを通知する。
    [self.flowDelegate todoInputViewController:self didSubmitText:text];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:nil
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"common.ok", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Data

- (void)reloadItems {
    self.items = [[TodoStore sharedStore] allItems];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                            forIndexPath:indexPath];
    TodoItem *item = self.items[indexPath.row];
    cell.textLabel.text = item.text;
    cell.textLabel.numberOfLines = 0;
    return cell;
}

#pragma mark - UITableViewDelegate

// 横スワイプで削除できるようにする。
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *delete =
        [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                title:NSLocalizedString(@"todo.input.delete", nil)
                                              handler:^(UIContextualAction *action,
                                                        UIView *sourceView,
                                                        void (^completionHandler)(BOOL)) {
            [[TodoStore sharedStore] removeItemAtIndex:indexPath.row];
            [weakSelf reloadItems];
            completionHandler(YES);
        }];
    return [UISwipeActionsConfiguration configurationWithActions:@[ delete ]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
