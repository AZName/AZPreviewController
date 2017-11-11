// Copyright (c) 2014 Alejandro Martinez
//

#import <QuickLook/QuickLook.h>

/**
 *  AMPPreviewController is a subclass of QLPreviewController that
 *  allows you to preview remote documents.
 *
 *  This class downloads the document and then reloads the preview.
 *
 *  This class is designed to work with only one document at a time.
 *  Also you can use a NSURL directly! Without the need of creating a QLPreviewItem conforming object.
 *  So the developer doesn't need to deal with dataSource methods, just instantiate and present ;)
 *
 */

typedef void (^AMPPreviewControllerStartDownload)(void);
typedef void (^AMPPreviewControllerFinishDownload)(NSError *error);
typedef void (^AMPPrevievControllerProgress)(float progress);

@protocol AMPPreviewItem <QLPreviewItem>
@required
- (NSURL *)remoteUrl;
@property (readwrite, nonatomic) NSURL * previewItemURL;
@end

@interface AMPPreviewController : QLPreviewController


@property (nonatomic, strong)NSDictionary *info;

/**
 *  Use a confirming <QLPreviewItem> object.
 *  It's the same as using QLPreviewController directly but
 *  thre is no need to implement QLPreviewControllerDataSource!
 *
 *  But you can use a <AMPPreviewItem> conforming object also.
 *  If the object has the remoteUrl != nil it will donwload the file.
 *
 *  If the object has the previewItemURL != nil it will load the file
 *  instead of downloading it.
 */
- (id)initWithPreviewItem:(id <QLPreviewItem>)item;

/**
 *  Use just a file path.
 *  No need to create a confirming <QLPreviewItem> object
 *  nor implementing the data source.
 *
 *  @param filePath The path for the local document
 */
- (id)initWithFilePath:(NSURL *)filePath;

/**
 *  Use a remote url.
 *  This will download and preview the remote document.
 *
 *  @param remoteUrl The url for the remote document
 */
- (id)initWithRemoteFile:(NSURL *)remoteUrl;

/**
 *  Use a remote url.
 *  This will download and preview the remote document.
 *
 *  @param remoteUrl The url for the remote document
 *  @param title The default title for the remote document
 */
- (id)initWithRemoteFile:(NSURL *)remoteUrl title:(NSString *)title;

/**
 *  Executed when the download of the file starts.
 */
@property (nonatomic, copy) AMPPreviewControllerStartDownload startDownloadBlock;

/**
 *  Executed when the download of the file has ended.
 */
@property (nonatomic, copy) AMPPreviewControllerFinishDownload finishDownloadBlock;

@property (nonatomic, copy) AMPPrevievControllerProgress downloadProgress;

- (void)setStartDownloadBlock:(AMPPreviewControllerStartDownload)startDownloadBlock;
- (void)setFinishDownloadBlock:(AMPPreviewControllerFinishDownload)finishDownloadBlock;
- (void)setDownloadProgress:(AMPPrevievControllerProgress)downloadProgress;
    //取消下载
- (void)cancelDpwnload;

    //开始下载
- (void)startDownload;


@end
