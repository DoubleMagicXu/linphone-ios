//
//  ViewController.m
//  linphone-ios
//
//  Created by sqxu on 08/03/2018.
//  Copyright © 2018 DoublerMagicXu. All rights reserved.
//

#import "ViewController.h"
#import <linphone/core.h>
#import <signal.h>
//委托协议
static bool_t running=TRUE;
static void stop(int signum){
    running=FALSE;
}
static void call_state_changed(LinphoneCore *lc, LinphoneCall *call, LinphoneCallState cstate, const char *msg){
    switch(cstate){
        case LinphoneCallOutgoingRinging:
            printf("It is now ringing remotely !\n");
            break;
        case LinphoneCallOutgoingEarlyMedia:
            printf("Receiving some early media\n");
            break;
        case LinphoneCallConnected:
            printf("We are connected !\n");
            break;
        case LinphoneCallStreamsRunning:
            printf("Media streams established !\n");
            break;
        case LinphoneCallEnd:
            printf("Call is terminated.\n");
            break;
        case LinphoneCallError:
            printf("Call failure !");
            break;
        default:
            printf("Unhandled notification %i\n",cstate);
    }
}
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
    NSLog(@"return,返回");
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //注册键盘出现通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)name:UIKeyboardDidShowNotification object:nil];
    //注册键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)name: UIKeyboardDidHideNotification object:nil];
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //注销键盘出现通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardDidShowNotification object:nil];
    //注销键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardDidHideNotification object:nil];
}
-(void) keyboardDidShow:(NSNotification *)notification{
    NSLog(@"键盘已打开");
}
-(void) keyboardDidHide:(NSNotification *)notification{
    NSLog(@"键盘已关闭");
}
- (IBAction)registration:(id)sender {
    LinphoneCoreVTable vtable={0};
    LinphoneCore *lc;
    LinphoneCall *call=NULL;
    const char *dest=NULL;
    dest=self.account.text.UTF8String;//destination
    //signal(SIGINT,stop);
    vtable.call_state_changed=call_state_changed;
    lc=linphone_core_new(&vtable,NULL,NULL,NULL);
    if (dest){
        /*
         Place an outgoing call
         */
        call=linphone_core_invite(lc,dest);
        if (call==NULL){
            printf("Could not place call to %s\n",dest);
            goto end;
        }else printf("Call to %s is in progress...",dest);
        linphone_call_ref(call);
    }
    while(running){
        linphone_core_iterate(lc);
        ms_usleep(50000);
    }
    if (call && linphone_call_get_state(call)!=LinphoneCallEnd){
        /* terminate the call */
        printf("Terminating the call...\n");
        linphone_core_terminate_call(lc,call);
        /*at this stage we don't need the call object */
        linphone_call_unref(call);
    }
end:
    printf("Shutting down...\n");
    linphone_core_destroy(lc);
    printf("Exited\n");

    
}


@end
