//
//  MultiPartUploadController.m
//  UploadDemo
//
//  Created by vhall on 2019/10/29.
//  Copyright © 2019 vhall. All rights reserved.
//

#import "MultiPartUploadController.h"
#import "JXTAlertView.h"

@interface MultiPartUploadController ()

@property (nonatomic, strong) UIProgressView *progressView;
/** 当前上传文件路径 */
@property (nonatomic, copy) NSString *filePath;
/** 点击重试 */
@property (nonatomic, strong) UIButton *tryButton;

@end

@implementation MultiPartUploadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 100)];
    [addBtn setTitle:@"点击添加视频上传" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.backgroundColor = [UIColor brownColor];
    [addBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:addBtn];

    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.progressTintColor = [UIColor redColor];
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    self.progressView.progressViewStyle = UIProgressViewStyleBar;
    self.progressView.frame = CGRectMake(0, 264, CGRectGetWidth(self.view.frame), 0.5);
    self.progressView.progress = 0;
    [self.view addSubview:self.progressView];
    
    UIButton *tryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, CGRectGetWidth(self.view.frame) , 40)];
    [tryButton setTitle:@"上传失败？点我重试" forState:UIControlStateNormal];
    tryButton.hidden = YES;
    [tryButton addTarget:self action:@selector(tryAgainClik) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tryButton];
    tryButton.backgroundColor = [UIColor redColor];
    self.tryButton = tryButton;
    
}

//点击重试
- (void)tryAgainClik {
    self.tryButton.hidden = YES;
    [self addUploadFileWithPath:self.filePath];
}

- (void)addBtnClick:(UIButton *)sender
{
    //************相册/拍照***************
    [super uploadBtnClick:sender];
    
    //************上传本地文件***************
    //[self mutiUploadWithFile:[[NSBundle mainBundle] pathForResource:@"" ofType:@""]];
}


//选择上传
- (void)addUploadFileWithPath:(NSString *)filePath
{
    [super addUploadFileWithPath:filePath];
    self.filePath = filePath;
//    NSError *error;
//    uint64_t fileSize = [VHUploaderModel getSizeWithFilePath:filePath error:&error];
//    if (error) {
//        [JXTAlertView showToastViewWithTitle:@"文件读取失败" message:error.domain duration:2 dismissCompletion:^(NSInteger buttonIndex) {
//
//        }];
//        return;
//    }
//    if (fileSize < 0.1 * 1024 * 1024 * 1024) {
//        [JXTAlertView showToastViewWithTitle:@"文件较小，建议使用简单上传" message:error.domain duration:2 dismissCompletion:^(NSInteger buttonIndex) {
//
//        }];
//        return;
//    }
    
    [self mutiUploadWithFile:filePath];
}



//上传
- (void)mutiUploadWithFile:(NSString *)filePath
{
    //分片上传
    __weak typeof(self)weakSelf = self;
    [weakSelf.uploder multipartUpload:filePath vodInfo:nil progress:^(VHUploadFileInfo * _Nonnull fileInfo, int64_t uploadedSize, int64_t totalSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"milti progress : %f",1.0 * uploadedSize / totalSize);
            [weakSelf.progressView setProgress:1.0 * uploadedSize / totalSize animated:NO];
            weakSelf.logtextview.text = [NSString stringWithFormat:@"上传进度：%f",weakSelf.progressView.progress];
        });
    } success:^(VHUploadFileInfo * _Nonnull fileInfo) {
        weakSelf.logtextview.text = [NSString stringWithFormat:@"上传成功，点播id：%@",fileInfo.recordId];
        [JXTAlertView showToastViewWithTitle:nil message:@"上传成功" duration:2 dismissCompletion:^(NSInteger buttonIndex) {
            
        }];
        weakSelf.tryButton.hidden = YES;
    } failure:^(VHUploadFileInfo * _Nullable fileInfo, NSError * _Nonnull error) {
        NSLog(@"分片上传error:%@",error);
        weakSelf.logtextview.text = [NSString stringWithFormat:@"上传失败，error：%@",error];
        weakSelf.logtextview.text = [NSString stringWithFormat:@"%@",error];
        weakSelf.tryButton.hidden = NO;
        [JXTAlertView showToastViewWithTitle:@"上传失败" message:error.domain duration:2 dismissCompletion:^(NSInteger buttonIndex) {
            
        }];
        
    }];
}


@end
