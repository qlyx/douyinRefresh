//
//  JXCustomTextView.h
//  YXProductDemo
//
//  Created by 江萧 on 2017/2/20.
//  Copyright © 2017年 蚁象ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXCustomTextView : UIView<UITextViewDelegate>
@property(nonatomic, strong)UILabel *placeholderLabel;//
@property(nonatomic, strong)UITextView *textView;//评价
@property(nonatomic, copy)void(^textViewEdit)(bool isEdit);
-(void)initSubViewWithBackgroundColor:(UIColor *)color placeholder:(NSString *)placeholder  font:(UIFont *)font textColor:(UIColor *)textColor placeholderColor:(UIColor *)placeholderColor;
@end
