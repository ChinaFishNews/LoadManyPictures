//
//  ImageModel.m
//  LoadManyPictures
//
//  Created by 新闻 on 2018/4/4.
//  Copyright © 2018年 Lvmama. All rights reserved.
//

#import "ImageModel.h"

@implementation ImageModel

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    ImageModel *model = [[self alloc] init];
    [model setValuesForKeysWithDictionary:dict];
    return model;
}

@end
