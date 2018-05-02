//
//  Tool.m
//  LDLive
//
//  Created by 王志强 on 2016/10/9.
//  Copyright © 2016年 王志强. All rights reserved.
//

#import "Tool.h"
#import <CommonCrypto/CommonDigest.h>
#import <Accelerate/Accelerate.h>
@implementation Tool


+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    //    [[UIBezierPath bezierPathWithRoundedRect:rect
    //                                cornerRadius:10.0] addClip];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageWithTintColor:(UIColor *)tintColor image:(UIImage *)image {
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (NSString *)TrimmingSpace:(NSString *)string {
    
    NSString *tmp = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return tmp;
}

+ (BOOL)isStringBlank:(NSString *)string{
    if (!string || [string isKindOfClass:[NSNull class]] || ![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    NSString *tmp = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([tmp isEqualToString:@""]) {
        return YES;
    }
    return NO;
}


+ (NSString *)MD5Encode:(NSString *)string{
    const char *str = [string UTF8String];
    if (str == NULL)
    {
        str = "";
    }
    
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *encodeString = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                              r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return encodeString;
}

+ (CGSize)sizeWithFont:(UIFont *)font string:(NSString *)string constrainedToSize:(CGSize)constrainedToSize{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    NSDictionary *baseDic = @{NSFontAttributeName:font};
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    return [string boundingRectWithSize:constrainedToSize options:options attributes:baseDic context:nil].size;
#else
    return [string sizeWithFont:font constrainedToSize:constrainedToSize lineBreakMode:NSLineBreakByWordWrapping];
#endif
}

//+ (CGSize)sizeWithFont:(UIFont *)font string:(NSString *)string {
//    
//    CGSize titleSize = [string sizeWithAttributes:@{NSFontAttributeName: font}];
//    
//    titleSize.height = kSize(22);
//    titleSize.width += kSize(20);
//    
//    return titleSize;
//   
//}
+ (void)conductFillet:(id)someView radius:(float)Radius {
    CALayer *l = [someView layer]; //获取ImageView的层
    [l setMasksToBounds:YES];
    [l setCornerRadius:Radius];
}

+ (BOOL)validateEmail:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}




+ (NSArray *)dataForDic:(NSDictionary *)dic {
    
    NSArray *allKeys = [dic allKeys];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (NSString *key in allKeys) {
        
        [arr addObject:dic[key][0]];
        
    }
    
    return arr;
    
}

+ (NSString *)jsonFileParse:(NSString *)fileName {
    //初始化文件路径。
    NSString* path  = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    //将文件内容读取到字符串中，注意编码NSUTF8StringEncoding 防止乱码，
    NSString* jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return jsonString;
}

- (NSString *)getTime:(NSInteger)time minSign:(NSString *)min secSing:(NSString *)sec {
    
    if (time >= 600) {
        
        if (time % 60 >= 10) {
            
            return [NSString stringWithFormat:@"%ld%@%ld%@", (long)(time / 60), min, (long)(time % 60), sec];
            
        } else {
            
            return [NSString stringWithFormat:@"%ld%@0%ld%@", (long)(time / 60), min, (long)(time % 60), sec];
            
        }
        
        
    } else if (time < 600 && time >= 60) {
        
        if (time % 60 >= 10) {
            
            return [NSString stringWithFormat:@"0%ld%@%ld%@", (long)(time / 60), min, (long)(time % 60), sec];
            
        } else {
            
            return [NSString stringWithFormat:@"0%ld%@0%ld%@", (long)(time / 60), min, (long)(time % 60), sec];
            
        }
        
    } else if (time >= 10) {
        
        return [NSString stringWithFormat:@"00%@%ld%@", min, (long)time, sec];
        
    } else {
        
        return [NSString stringWithFormat:@"00%@0%ld%@", min, (long)time, sec];
        
    }
    
    
}

+ (CGSize)getLabelSizeWithText:(NSString *)text font:(UIFont *)font rectWithSize:(CGSize)size {
    

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize labelSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return labelSize;
    
}
+ (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    
    for (NSUInteger i=0; i<string.length; i++) {
        if(i > 0) {
            
            if(i == 3 || i ==7) {
                
                [stringWithAddedSpaces appendString:@" "];
                
                if(i < cursorPositionInSpacelessString) {
                    
                    (*cursorPosition)++;
                    
                }
            }
        }
        
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
    
}

+ (NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    
    NSUInteger originalCursorPosition =*cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    
    for (NSUInteger i = 0; i< string.length; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        
        if(isdigit(characterToAdd)) {
            
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            [digitsOnlyString appendString:stringToAdd];
            
            
        } else {
            if(i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    return digitsOnlyString;
}

+ (BOOL)isGreaterThanTheCurrentTimeWithOldTime:(NSTimeInterval)oldTime hours:(NSTimeInterval)hours {

    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    if (timeInterval > oldTime + hours * 3600) {
        
        return YES;
        
    } else {
        
        return NO;
    }

    
}

+ (void)archiverObject:(id)object byKey:(NSString *)key {
    //初始化存储对象信息的data
    NSMutableData *data = [NSMutableData data];
    //创建归档工具对象
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    key = [self subString:key];
    //开始归档
    [archiver encodeObject:object forKey:key];
    //结束归档
    [archiver finishEncoding];
    //写入本地
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    NSString *destPath = [[docPath stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", key]];
    
    [data writeToFile:destPath atomically:YES];
}

+ (id)unarchiverObjectByKey:(NSString *)key {
    key = [self subString:key];
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    NSString *destPath = [[docPath stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", key]];
    NSData *data = [NSData dataWithContentsOfFile:destPath];
    //创建反归档对象
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //接收反归档得到的对象
    id object = [unarchiver decodeObjectForKey:key];
    return object;
}

+(NSString *)subString:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    str = [str stringByReplacingOccurrencesOfString:@".api" withString:@""];
    return str;
}
+ (NSString *)calculatetime:(NSString *)Time {
    
    NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:[Time doubleValue]];
    //实例化一个NSDateFormatter对象
   NSDateFormatter *_yearDateFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *_dayDateFormat = [[NSDateFormatter alloc] init];
    [_yearDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式
    NSString *yearDateString = [_yearDateFormat stringFromDate:d];
    
    //实例化一个NSDateFormatter对象
    [_dayDateFormat setDateFormat:@"HH:mm"];//设定时间格式
    NSString *dayDateString = [_dayDateFormat stringFromDate:d];
    NSDate *now = [NSDate date];//返回当前时间
    NSTimeInterval timeInterval = [now timeIntervalSinceDate:d];
    int time = timeInterval / 60;
    
    if (time == 0) {
        
        return @"刚刚";
        
    } else if (time < 60) {
        
        return [NSString stringWithFormat:@"%d分钟之前", time];
        
    } else if (time < 60 * 24) {
        
        return [NSString stringWithFormat:@"%d小时之前", time/60];
        
    } else if (time < 60 * 24 * 2) {
        
        return [NSString stringWithFormat:@"昨天 %@", dayDateString];
        
    } else if (time < 60 * 24 * 3) {
        
        return [NSString stringWithFormat:@"前天 %@", dayDateString];
        
    } else {
        
        return yearDateString;
        
    }
    
}
+(NSString *)getDateStr:(NSString *)timestr
{
    NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:[timestr doubleValue]];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  
    [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式
    NSString *string = [dateFormat stringFromDate:d];
    return string;
}
//时间转字符串
+(NSString *)getDateString:(NSDate *)date andDateFormat:(NSString *)str
{
  
    if (date == nil) {
        return nil;
    }
    NSDateFormatter *dtFmt = [[NSDateFormatter alloc] init];
    if (str == nil) {
        str = @"YYYY-MM-dd HH:mm:ss";
    }
    [dtFmt setDateFormat:str];
    return [dtFmt stringFromDate:date];
}

//字符串转时间
+(NSDate *)getDate:(NSString *)timestr andDateFormat:(NSString *)str
{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:str];//设定时间格式
    return [dateFormat dateFromString:timestr];
}
+ (UIImage *)handleImageWithURLStr:(NSString *)imageURLStr {
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLStr]];
    NSData *newImageData = imageData;
    // 压缩图片data大小
    newImageData = UIImageJPEGRepresentation([UIImage imageWithData:newImageData scale:0.1], 0.1f);
    UIImage *image = [UIImage imageWithData:newImageData];
    
    // 压缩图片分辨率(因为data压缩到一定程度后，如果图片分辨率不缩小的话还是不行)
    CGSize newSize = CGSizeMake(200, 200);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(void)call
{
   
        NSString * str=[[NSString alloc] initWithFormat:@"telprompt://%@",@"4001660059"];
        NSComparisonResult compare = [[UIDevice currentDevice].systemVersion compare:@"10.0"];
        if (compare == NSOrderedDescending || compare == NSOrderedSame) {
            /// 大于等于10.0系统使用此openURL方法
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
    
}
+ (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyy年 MM月dd日 "];
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六",  nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [[dateformatter stringFromDate:inputDate] stringByAppendingString:[weekdays objectAtIndex:theComponents.weekday]];
    
}

+(NSMutableAttributedString *)setAttributeStr:(NSString *)str andFont:(UIFont *)font andColor:(UIColor *)color andRangeStr:(NSString *)rangeStr
{
    NSMutableAttributedString *attritu = [[NSMutableAttributedString alloc]initWithString:str];
    [attritu addAttributes:@{NSForegroundColorAttributeName: color,
                             NSFontAttributeName:
                                 font} range:[str rangeOfString:rangeStr]];
    return attritu;
}

+(NSString *)getSaveString:(NSString *)str
{
    if (str.length>0) {
        return str;
    }else
        return @"";
}
#pragma mark - 键盘下落
+ (void)downKeyBoardViolence{
    [[UIApplication sharedApplication]sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]
    ;
}
@end

