//
//  ViewController.m
//  linphone-ios
//
//  Created by sqxu on 08/03/2018.
//  Copyright © 2018 DoublerMagicXu. All rights reserved.
//

#import "ViewController.h"
//委托协议
@interface ViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)registration:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//委托协议方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    NSLog(@"返回");
    return YES;
}
- (IBAction)registration:(id)sender {
}
@end
