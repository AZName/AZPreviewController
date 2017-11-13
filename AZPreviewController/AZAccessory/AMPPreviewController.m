// Copyright (c) 2014 Alejandro Martinez
//

//#import "AFNetworking/AFNetworking.h"

#import "AMPPreviewController.h"

#pragma mark - AMPPreviewItem

@interface AMPPreviewObject : NSObject <AMPPreviewItem>
@property (nonatomic, strong) NSURL *remoteUrl;
@property (nonatomic, strong, readwrite) NSURL *previewItemURL;
@property (nonatomic, strong, readwrite) NSString *previewItemTitle;

@end

@implementation AMPPreviewObject
@synthesize remoteUrl, previewItemURL, previewItemTitle;

@end

#pragma mark - AMPPreviewController

@interface AMPPreviewController () <QLPreviewControllerDataSource,NSURLSessionDownloadDelegate>

@property (nonatomic, strong) id <QLPreviewItem> previewItem;

@property (nonatomic, strong)NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong)UIView *backGroudView;//背景图

@property (nonatomic, strong)UIImageView *accessoryImagV;//附件类型

@property (nonatomic, strong)UIProgressView *accessoryProgress;//进度

@property (nonatomic, strong)UIButton *startBtn;//开始下载

@property (nonatomic, strong)UILabel *accessoryTitle;//附件标题

@property (nonatomic, strong)UILabel *accessorySize;//附件大小

@end

@implementation AMPPreviewController

- (id)initWithPreviewItem:(id<QLPreviewItem>)item {
    self = [self init];
    if (self) {
        _previewItem = item;
    }
    return self;
}

- (id)initWithFilePath:(NSURL *)filePath {
    self = [self init];
    if (self) {
        AMPPreviewObject *item = [AMPPreviewObject new];
        item.previewItemTitle = @"附件";
        item.previewItemURL = filePath;
        _previewItem = item;
    }
    return self;
}




- (id)initWithRemoteFile:(NSURL *)remoteUrl {
    return [self initWithRemoteFile:remoteUrl title:@"附件"];
}

- (id)initWithRemoteFile:(NSURL *)remoteUrl title:(NSString *)title {
    self = [self init];
    if (self) {
        AMPPreviewObject *item = [AMPPreviewObject new];
        item.previewItemTitle = title;
        item.remoteUrl = remoteUrl;
        _previewItem = item;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[UIView new]];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.backGroudView =  self.view.subviews.firstObject;
    self.backGroudView.backgroundColor = [UIColor grayColor];
    for (UIView *view  in self.backGroudView.subviews) {
            [view removeFromSuperview];
    }
    self.backGroudView.hidden = NO;
    [self.backGroudView addSubview:self.accessoryImagV];
    [self.backGroudView addSubview:self.accessoryTitle];
    [self.backGroudView addSubview:self.accessorySize];
    [self.backGroudView addSubview:self.accessoryProgress];
    [self.backGroudView addSubview:self.startBtn];
    
    //判断网络自动是否自动下载
//    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
//    [reachability startMonitoring];
//    [reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        switch (status) {
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//            {
//            [self onStartClick:self.startBtn];
//            }
//                break;
//
//            default:
//                break;
//        }
//    }];
    
    if ([self.previewItem respondsToSelector:@selector(remoteUrl)]
        && [(id <AMPPreviewItem>)self.previewItem remoteUrl]) {
        
        id <AMPPreviewItem> item = (id <AMPPreviewItem>)self.previewItem;
        NSURL *suggestedLocalURL = [self destinationPathForURL:[item remoteUrl]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[suggestedLocalURL path]]) {
            item.previewItemURL = suggestedLocalURL;
            self.dataSource = self;
            [self reloadData];
        } else {

        }
        
    } else {
        self.dataSource = self;
        [self reloadData];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.downloadTask cancel];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.accessoryImagV.center = CGPointMake(self.view.center.x, self.view.center.y - 80);
    self.accessoryImagV.bounds = CGRectMake(0, 0, 113, 113);
    self.accessoryTitle.frame = CGRectMake(0, self.accessoryImagV.frame.origin.y + self.accessoryImagV.frame.size.height +10, self.view.frame.size.width, 20);
    self.accessorySize.frame = CGRectMake(0, self.accessoryTitle.frame.origin.y +self.accessoryTitle.frame.size.height + 5, self.view.frame.size.width, 20);
    self.accessoryProgress.frame = CGRectMake(20, self.accessorySize.frame.origin.y + self.accessorySize.frame.size.height +10, self.view.frame.size.width - 85, 20);
    self.startBtn.center = CGPointMake(self.accessorySize.center.x, self.accessorySize.center.y +30);
    self.startBtn.bounds = CGRectMake(0, 0, 80, 25);
}

- (NSURL *)destinationPathForURL:(NSURL *)url {
    NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    NSString *name = [url lastPathComponent];
    NSURL *path = [documentsDirectoryPath URLByAppendingPathComponent:name];
    return path;
}

#pragma mark -

- (void)downloadFile {
    if (self.startDownloadBlock) {
        self.startDownloadBlock();
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURL *URL = [(id <AMPPreviewItem>)self.previewItem remoteUrl];
    if (URL) {
        self.downloadTask = [session downloadTaskWithURL:URL];
        [self.downloadTask resume];
    }
}


#pragma mark --------- NSURLSessionDownloadDelegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"%lf",1.0 * totalBytesWritten / totalBytesExpectedToWrite);
    CGFloat progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    if (self.downloadProgress) {
        self.downloadProgress(progress);
    }
    self.accessoryProgress.hidden = NO;
    self.accessoryProgress.progress = progress;
    self.accessorySize.text = [NSString stringWithFormat:@"下载中 %.2f%%",progress * 100];
}

// 写入数据到本地的时候会调用的方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[self destinationPathForURL:downloadTask.currentRequest.URL] error:nil];
}
// 请求完成，错误调用的代理方法
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if (!error) {
        if ([self.previewItem isKindOfClass:[AMPPreviewObject class]]) {
            [(AMPPreviewObject *)self.previewItem setPreviewItemTitle:[task.response suggestedFilename]];
        }
        
        [(id <AMPPreviewItem>)self.previewItem setPreviewItemURL:[self destinationPathForURL: task.currentRequest.URL]];
        self.dataSource = self;
        [self reloadData];
    }
    
    if (self.finishDownloadBlock) {
        self.finishDownloadBlock(error);
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.previewItem;
}

    //开始下载
- (void)startDownload {
    if (self.downloadTask) {
        [self.downloadTask resume];
    }else{
            //下载文件
        [self downloadFile];
    }

}
    //取消下载
- (void)cancelDpwnload {
    if (self.downloadTask) {
        [self.downloadTask  cancel];
    }else{
        return;
    }

}


- (void)onStartClick:(UIButton *)sender {
    
    if (!self.downloadTask) {
        [self startDownload];
        [sender setTitle:@"×" forState:UIControlStateNormal];
        sender.frame = CGRectMake(self.accessoryProgress.frame.origin.x + self.accessoryProgress.frame.size.width +10, self.accessoryProgress.frame.origin.y - 12, 24, 24);
        sender.backgroundColor = [UIColor clearColor];

    }else{
        
        [self cancelDpwnload];
        self.downloadTask = nil;
        [sender setImage:nil forState:UIControlStateNormal];
        [sender setTitle:@"开始下载" forState:UIControlStateNormal];
        self.startBtn.center = CGPointMake(self.accessorySize.center.x, self.accessorySize.center.y +30);
        self.startBtn.bounds = CGRectMake(0, 0, 80, 25);
        self.accessoryProgress.hidden = YES;
        self.accessorySize.text = self.info[@"fileSize"];
    }
    
}

- (void)setInfo:(NSDictionary *)info {
    _info = info;
    self.accessoryTitle.text = info[@"fileName"];
    self.accessorySize.text = info[@"fileSize"];
    NSString *title = info[@"fileName"];
     if ([title containsString:@"doc"]){
        self.accessoryImagV.image = [UIImage imageNamed:@"file03"];
    }else if ([title containsString:@"xls"]){
        self.accessoryImagV.image = [UIImage imageNamed:@"file01"];
    }else if ([title containsString:@"ppt"]){
        self.accessoryImagV.image = [UIImage imageNamed:@"file02"];
    }else if ([title containsString:@"pdf"]){
        self.accessoryImagV.image = [UIImage imageNamed:@"file04"];
    }else {
        self.accessoryImagV.image = [UIImage imageNamed:@"file05"];
    }
    
}

- (UIImageView *)accessoryImagV {
    if (!_accessoryImagV) {
        _accessoryImagV = [[UIImageView alloc]init];
    }
    return _accessoryImagV;
}

- (UILabel *)accessoryTitle {
    if (!_accessoryTitle) {
        _accessoryTitle = [[UILabel alloc]init];
        _accessoryTitle.font = [UIFont systemFontOfSize:16];
        _accessoryTitle.textColor = [UIColor greenColor];
        _accessoryTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _accessoryTitle;
}

- (UILabel *)accessorySize {
    if (!_accessorySize) {
        _accessorySize = [[UILabel alloc]init];
        _accessorySize.font = [UIFont systemFontOfSize:13];
        _accessorySize.textColor = [UIColor redColor];
        _accessorySize.textAlignment = NSTextAlignmentCenter;
    }
    return _accessorySize;
}

- (UIProgressView *)accessoryProgress {
    if (!_accessoryProgress) {
        _accessoryProgress = [[UIProgressView alloc]init];
        _accessoryProgress.trackTintColor = [UIColor grayColor];
        _accessoryProgress.progressTintColor = [UIColor redColor];
        _accessoryProgress.hidden = YES;
    }
    return _accessoryProgress;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn.backgroundColor = [UIColor grayColor];
        [_startBtn setTitle:@"开始下载" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(onStartClick:) forControlEvents:UIControlEventTouchUpInside];
        _startBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _startBtn;
}

@end
