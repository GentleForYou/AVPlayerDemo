//
//  PlayerViewController.m
//  VideoAVPlayer
//
//  Created by gaoyanlong on 15-3-11.
//  Copyright (c) 2015年 shaowenle. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface PlayerViewController ()
{
    BOOL falg;
    BOOL falg1;
    AVPlayerLayer *playerLayer;
    NSString *URLString;
    UIImageView *media_starImageView;
    NSString *filePath;
    NSURL *url;
    NSString *urlStr;
    NSArray *arr1;
    unsigned int i;
}
@property (nonatomic,strong) AVPlayer *player;//播放器对象
@property (weak, nonatomic) IBOutlet UIView *container; //播放器容器
@property (weak, nonatomic) IBOutlet UIButton *playOrPause; //播放/暂停按钮
@property (weak, nonatomic) IBOutlet UIButton *nextButton;//下一集按钮
@property (strong, nonatomic) IBOutlet UISlider *slider;//滑块调整播放进度
@property (weak, nonatomic) IBOutlet UIButton *fullButton;//全屏按钮
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@end

@implementation PlayerViewController

#pragma mark - 控制器视图方法


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"视频播放器";
    //初始化视频数组(在线播放)
    arr1 = @[@"http://123.134.67.201:80/play/BEDF14F6FF4FF604DCCB053EEE20536EB33EFC37.mp4",
             @"http://221.204.189.54:80/play/0F7758AF15BD3895E07E360C34B95AB42E631487.mp4",
             @"http://123.134.67.198:80/play/BFD75E46DE50B2D8BBD810F259B2CC892DE9F690.mp4",
             @"http://123.134.67.197:80/play/4B07614CBE84228E2645AC9F14C4BABFC5E6F0E1.mp4",
             @"http://58.244.255.12/play/82846AEB3B80981E4A674374C05B3F771144D3AF/1074654_smooth.mp4"];
    i = 0;
    
    //初始化容器
    self.container.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.width);
    falg = YES;
    falg1 = YES;
    [self.playOrPause setImage:[UIImage imageNamed:@"pui_pausebtn_b_disable@2x"] forState:UIControlStateNormal];
    //创建播放器层
    [self setupUI];
    //播放
    [self.player play];
    
    //将底部进度条等视图提前，不然会被播放内容覆盖掉
    [self.container bringSubviewToFront:_playOrPause];
    [self.container bringSubviewToFront:_nextButton];
    [self.container bringSubviewToFront:_leftLabel];
    [self.container bringSubviewToFront:_slider];
    [self.container bringSubviewToFront:_rightLabel];
    [self.container bringSubviewToFront:_fullButton];
   
}

-(void)dealloc{
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
}

#pragma mark - 私有方法
-(void)setupUI{
    //创建播放器层
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.container.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResize;//视频填充模式
    [self.container.layer addSublayer:playerLayer];
}

/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */

/**
 *  初始化播放器
 *
 *  @return 播放器对象
 */
//初始化播放器
-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem:0];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        //给播放器添加进度更新
        [self addProgressObserver];
        //给AVPlayerItem添加监控
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

/**
 *  根据视频索引取得AVPlayerItem对象
 *
 *  @param videoIndex 视频顺序索引
 *
 *  @return AVPlayerItem对象
 */
-(AVPlayerItem *)getPlayItem:(int)videoIndex{
#warning 为了节约体积,本地视频没有上传,自己找mp4格式的本地视频
        //本地播放
//    NSString *file = [[NSBundle mainBundle] pathForResource:@"火影忍者65" ofType:@"mp4"];
//    NSURL *url = [NSURL fileURLWithPath:file];
    //在线播放
        urlStr=[NSString stringWithFormat:@"http://123.134.67.201:80/play/BEDF14F6FF4FF604DCCB053EEE20536EB33EFC37.mp4"];
        url=[NSURL URLWithString:urlStr];
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
        return playerItem;
}
#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
//移除本地通知
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
}



#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    AVPlayerItem *playerItem = self.player.currentItem;
    UISlider *slider = self.slider;
    [slider addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    __weak PlayerViewController *blockSelf = self;
    //这里设置每秒执行一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前时间（秒）
        float current=CMTimeGetSeconds(time);
        //总时间（秒）
        float total=CMTimeGetSeconds([playerItem duration]);
        [blockSelf leftLabel:[blockSelf convertTime:current]];
        NSLog(@"当前播放时长%@", [blockSelf convertTime:current]);
        if (current) {
            [slider setValue:(current/total) animated:YES];
        }
    }];
}
- (void)changeValue:(UISlider *)aSlider
{
    AVPlayerItem *playerItem = self.player.currentItem;
    //从当前位置播放
    [self.player seekToTime:CMTimeMakeWithSeconds(aSlider.value * CMTimeGetSeconds([playerItem duration]), 1)];
    //机智的暂停,防止造成拖动时进度条卡顿的尴尬（因为AVPlayer这个拖动后会暂停，不会自动播放）
    [self.player pause];
    [self.playOrPause setImage:[UIImage imageNamed:@"pui_playbtn_b_disable@2x"] forState:UIControlStateNormal];
}
//计算时间，返回字符串
- (NSString *)convertTime:(CGFloat)second{
        NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if (second/3600 >= 1) {
            [formatter setDateFormat:@"01:mm:ss"];
            } else {
                [formatter setDateFormat:@"mm:ss"];
                }
        NSString *showtimeNew = [formatter stringFromDate:d];
        return showtimeNew;
}

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
//通过KVO监控播放器状态
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    __weak PlayerViewController *blockSelf = self;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            [blockSelf rightLabel:[blockSelf convertTime:CMTimeGetSeconds(playerItem.duration)]];
            NSLog(@"视频总时长%@", [blockSelf convertTime:CMTimeGetSeconds(playerItem.duration)]);
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"视频共缓冲时长%@", [blockSelf convertTime:totalBuffer]);
    }
}


- (void)leftLabel:(NSString *)leftLabelText
{
    _leftLabel.text = leftLabelText;
}

- (void)rightLabel:(NSString *)rightLabelText
{
    _rightLabel.text = rightLabelText;
}
#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (IBAction)playClick:(UIButton *)sender {
    if(self.player.rate==0){ //说明时暂停
        [sender setImage:[UIImage imageNamed:@"pui_pausebtn_b_disable@2x"] forState:UIControlStateNormal];
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
        [sender setImage:[UIImage imageNamed:@"pui_playbtn_b_disable@2x"] forState:UIControlStateNormal];
    }
}
//关闭自动旋转
- (BOOL)shouldAutorotate{
    return NO;
}
//全屏或退出Button
- (IBAction)fullOrExit:(UIButton *)sender {
    if (falg) {
        [sender setImage:[UIImage imageNamed:@"pui_zoomoutbtn@2x"] forState:UIControlStateNormal];
        falg = !falg;
        
        self.container.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
        playerLayer.frame = self.container.bounds;
        [self.view bringSubviewToFront:self.container];
//        playerLayer.videoGravity = AVLayerVideoGravityResize;//视频填充模式
        //旋转屏幕，但是只旋转当前的View
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.bounds = CGRectMake(0, 64, frame.size.height, frame.size.width);
        //隐藏导航栏
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    } else {
        [sender setImage:[UIImage imageNamed:@"pui_zoominbtn@2x"] forState:UIControlStateNormal];
        falg = !falg;
        self.container.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.height);
        playerLayer.frame = self.container.bounds;
        [self.view bringSubviewToFront:self.container];
        //旋转屏幕，但是只旋转当前的View
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        self.view.transform = CGAffineTransformMakeRotation(M_PI*2);
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.bounds = CGRectMake(0, 0, frame.size.height, frame.size.width);
        //显示导航栏
        [[self navigationController] setNavigationBarHidden:NO animated:YES];

    }
}
//下一个视频Button
- (IBAction)nextButton:(UIButton *)sender {
    i++;
    [self removeNotification];
    if (i == arr1.count) {
        i = 0;
    }
    urlStr=[NSString stringWithFormat:arr1[i]];
    url=[NSURL URLWithString:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self addNotification];

}
//点击隐藏或者出现播放进度控制栏
- (IBAction)tapPlayer:(id)sender {
    if (falg1) {
        falg1 = !falg1;
        _playOrPause.hidden = YES;
        _nextButton.hidden = YES;
        _slider.hidden = YES;
        _fullButton.hidden = YES;
        _leftLabel.hidden = YES;
        _rightLabel.hidden = YES;
        
    } else {
        falg1 = !falg1;
        _playOrPause.hidden = NO;
        _nextButton.hidden = NO;
        _slider.hidden = NO;
        _fullButton.hidden = NO;
        _leftLabel.hidden = NO;
        _rightLabel.hidden = NO;
    }
    
}




@end
