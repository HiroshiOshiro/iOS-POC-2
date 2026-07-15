#import "MusicListViewController.h"
#import "MusicDetailViewController.h"
#import "ITunesAPIClient.h"
#import "ImageLoader.h"
#import "Track.h"

static NSString *const kCellIdentifier = @"MusicCell";
static NSString *const kDefaultSearchTerm = @"J-POP";

@interface MusicListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, copy) NSArray<Track *> *tracks;
@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"music.title", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
    // 初期表示として既定の検索語で読み込む。
    self.searchBar.text = kDefaultSearchTerm;
    [self searchWithTerm:kDefaultSearchTerm];
}

#pragma mark - Setup

- (void)setupViews {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.placeholder = NSLocalizedString(@"music.search_placeholder", nil);
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.view addSubview:self.searchBar];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 72;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    // Subtitle スタイルを使うため registerClass はせず、dequeue が nil を返したら生成する。
    [self.view addSubview:self.tableView];

    self.spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];

    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyLabel.text = NSLocalizedString(@"music.empty", nil);
    self.emptyLabel.textColor = [UIColor secondaryLabelColor];
    self.emptyLabel.hidden = YES;
    [self.view addSubview:self.emptyLabel];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.searchBar.topAnchor constraintEqualToAnchor:guide.topAnchor],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:8],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-8],

        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor constant:4],
        [self.tableView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],

        [self.spinner.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor],
        [self.spinner.centerYAnchor constraintEqualToAnchor:self.tableView.centerYAnchor],

        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.tableView.centerYAnchor],
    ]];
}

#pragma mark - Search

- (void)searchWithTerm:(NSString *)term {
    NSString *trimmed = [term stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmed.length == 0) {
        return;
    }
    self.emptyLabel.hidden = YES;
    [self.spinner startAnimating];

    __weak typeof(self) weakSelf = self;
    [[ITunesAPIClient sharedClient] searchTracksWithTerm:trimmed
                                              completion:^(NSArray<Track *> *tracks,
                                                           NSError *error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf.spinner stopAnimating];
        if (error) {
            strongSelf.tracks = @[];
            [strongSelf.tableView reloadData];
            [strongSelf showErrorAlert:error];
            return;
        }
        strongSelf.tracks = tracks;
        strongSelf.emptyLabel.hidden = (tracks.count > 0);
        [strongSelf.tableView reloadData];
        if (tracks.count > 0) {
            [strongSelf.tableView setContentOffset:CGPointZero animated:NO];
        }
    }];
}

- (void)showErrorAlert:(NSError *)error {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"music.error_title", nil)
                                            message:error.localizedDescription
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"common.ok", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchWithTerm:searchBar.text];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kCellIdentifier];
    }
    Track *track = self.tracks[indexPath.row];
    cell.textLabel.text = track.trackName;
    cell.detailTextLabel.text = track.artistName;
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    // プレースホルダを置き、非同期で差し替える（セル再利用に配慮）。
    cell.imageView.image = [self placeholderImage];
    NSString *artworkURL = track.artworkUrl100;
    [[ImageLoader sharedLoader] loadImageFromURLString:artworkURL
                                            completion:^(UIImage *image) {
        if (!image) {
            return;
        }
        // 取得完了時に対象セルがまだ同じ行を表示しているか確認する。
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        if (currentCell) {
            currentCell.imageView.image = image;
            [currentCell setNeedsLayout];
        }
    }];
    return cell;
}

- (UIImage *)placeholderImage {
    UIGraphicsImageRenderer *renderer =
        [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(56, 56)];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [[UIColor systemGray5Color] setFill];
        [context fillRect:CGRectMake(0, 0, 56, 56)];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Track *track = self.tracks[indexPath.row];
    MusicDetailViewController *detailVC = [[MusicDetailViewController alloc] initWithTrack:track];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
