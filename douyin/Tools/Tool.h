//
//  Tool.h
//  LDLive
//
//  Created by 王志强 on 2016/10/9.
//  Copyright © 2016年 王志强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tool : NSObject




//修改图片颜色
+ (UIImage *)imageWithTintColor:(UIColor *)tintColor image:(UIImage *)image;

//去除收尾空格
+ (NSString *)TrimmingSpace:(NSString *)string;

//获取图片颜色
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;

//判断字符串是否为空
+ (BOOL)isStringBlank:(NSString *)string;

//字符串加MD5
+ (NSString *)MD5Encode:(NSString *)string;

//获取字符串高度
+ (CGSize )sizeWithFont:(UIFont *)font string:(NSString *)string constrainedToSize:(CGSize)constrainedToSize;

//获取字符串宽度
+ (CGSize )sizeWithFont:(UIFont *)font string:(NSString *)string;

//处理View圆角
+ (void)conductFillet:(id)someView radius:(float)Radius;

//邮箱格式判断
+ (BOOL)validateEmail:(NSString *)email;
//获取json数据动态Key内容
+ (NSArray *)dataForDic:(NSDictionary *)dic;

//时间换算
- (NSString *)getTime:(NSInteger)time minSign:(NSString *)min secSing:(NSString *)sec;

//计算label高度
+ (CGSize)getLabelSizeWithText:(NSString *)text font:(UIFont *)font rectWithSize:(CGSize)size;


//数字插入空格 电话号 限制长度
+ (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition;

//移除非数字字符 首字符为1和0 限制电话号
+ (NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition;

+ (BOOL)isGreaterThanTheCurrentTimeWithOldTime:(NSTimeInterval)oldTime hours:(NSTimeInterval)hours;
//存放归档对象
+ (void)archiverObject:(id)object byKey:(NSString *)key;
//取出归档对象
+ (id)unarchiverObjectByKey:(NSString *)key;
//计算时间
+ (NSString *)calculatetime:(NSString *)Time;
//压缩图片
+ (UIImage *)handleImageWithURLStr:(NSString *)imageURLStr;
//根据时间戳获取时间
+(NSString *)getDateStr:(NSString *)timestr;
+(NSDate *)getDate:(NSString *)timestr andDateFormat:(NSString *)str;
+ (void)downKeyBoardViolence;
//根据日期获取星期几
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate;
+(void)call;
//设置属性字符串
+(NSMutableAttributedString *)setAttributeStr:(NSString *)str andFont:(UIFont *)font andColor:(UIColor *)color andRangeStr:(NSString *)rangeStr;


@end


