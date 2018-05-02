
//
//  JXCustomTextView.m
//  YXProductDemo
//
//  Created by 江萧 on 2017/2/20.
//  Copyright © 2017年 蚁象ios. All rights reserved.
//

#import "JXCustomTextView.h"
@interface JXCustomTextView()
{
    NSString *_placeholder;
   
}
@end
@implementation JXCustomTextView
@synthesize placeholderLabel,textView;
-(void)initSubViewWithBackgroundColor:(UIColor *)color placeholder:(NSString *)placeholder font:(UIFont *)font textColor:(UIColor *)textColor placeholderColor:(UIColor *)placeholderColor
{
    self.backgroundColor = color;
    _placeholder = placeholder;
    
    placeholderLabel =[JXUIKit labelWithBackgroundColor:RGBACOLOR(0, 0, 0, 0) textColor:placeholderColor textAlignment:NSTextAlignmentLeft numberOfLines:1 fontSize:0 font:font text:placeholder];
    [self addSubview:placeholderLabel];
    MJWeakSelf
    [placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@20);
        make.left.equalTo(@6);
        make.top.equalTo(@9);
    }];
    textView = [[UITextView alloc] init];
    textView.backgroundColor = RGBACOLOR(0, 0, 0, 0);
    textView.textColor = textColor;
    textView.delegate = self;
    textView.text = @"";
    textView.font = font;
    [self addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-5));
        make.height.equalTo(@100);
        make.left.equalTo(@5);
        make.top.equalTo(@5);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.textViewEdit) {
        self.textViewEdit(YES);
    }
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (self.textView.text.length>0) {
        placeholderLabel.text = @"";
 
    }else{
        placeholderLabel.text = _placeholder;
        
    }
    
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    
    //self.textViewEdit(NO);
}
-(void)keyboardWillBeHidden:(NSNotification*)aNotification

{
    if (self.textViewEdit) {
        self.textViewEdit(NO);
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
