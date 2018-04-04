//
//  ImageModel.h
//  LoadManyPictures
//
//  Created by 新闻 on 2018/4/4.
//  Copyright © 2018年 Lvmama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageModel : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *download;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end
