//
//  ViewController.m
//  LoadManyPictures
//
//  Created by 新闻 on 2018/4/4.
//  Copyright © 2018年 Lvmama. All rights reserved.
//

#import "ViewController.h"
#import "ImageModel.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *pictures;
@property (nonatomic, strong) NSMutableDictionary *cachePictures; // 内存缓存
@property (nonatomic, strong) NSMutableDictionary *operations; // 操作对象
@property (nonatomic, strong) NSOperationQueue *queue; // 队列

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pictures = @[].mutableCopy;
    NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pictures.plist" ofType:nil]];
    for (NSDictionary *dict in dictArray) {
        [self.pictures addObject:[ImageModel modelWithDict:dict]];
    }

    self.cachePictures = @{}.mutableCopy;
    self.operations = @{}.mutableCopy;
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 3;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pictures.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%zd",indexPath.row];
    
    ImageModel *imageModel = self.pictures[indexPath.row];
    UIImage *image = self.cachePictures[imageModel.icon];
    if (image) { // 从内存缓存获取图片
        cell.imageView.image = image;
    } else {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *fileName = [imageModel.icon lastPathComponent];
        NSString *file = [cachePath stringByAppendingPathComponent:fileName];
        NSData *data = [NSData dataWithContentsOfFile:file];
        if (data) { // 从沙盒获取
            image = [UIImage imageWithData:data];
            cell.imageView.image = image;
            self.cachePictures[imageModel.icon] = image;
        } else { // 下载
            NSOperation *operation = self.operations[imageModel.icon];
            if (!operation) { // 不在下载队列中
                operation = [NSBlockOperation blockOperationWithBlock:^{
                    NSData *tempData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageModel.icon]];
                    if (!tempData) { // 下载失败
                        [self.operations removeObjectForKey:imageModel.icon];
                    } else {
                        UIImage *tempImage = [UIImage imageWithData:tempData];
                        self.cachePictures[imageModel.icon] = tempImage; // 存放到字典
                        [tempData writeToFile:file atomically:YES];
                        [self.operations removeObjectForKey:imageModel.icon]; // 移除操作
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                            cell.imageView.image = tempImage;
                        }];
                    }
                }];
                [self.queue addOperation:operation]; // 添加到队列
                self.operations[imageModel.icon] = operation; // 存放到字典
            }
        }
    }
    
    return cell;
}

@end
