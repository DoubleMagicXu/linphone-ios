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

//registration
static void registration_state_changed(struct _LinphoneCore *lc, LinphoneProxyConfig *cfg, LinphoneRegistrationState cstate, const char *message){
    printf("New registration state %s for user id [%s] at proxy [%s]\n"
           ,linphone_registration_state_to_string(cstate)
           ,linphone_proxy_config_get_identity(cfg)
           ,linphone_proxy_config_get_addr(cfg));
}
@interface ViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)registration:(id)sender;
- (IBAction)cancel:(id)sender;

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
//registration
    LinphoneCore *lc;
    LinphoneCoreVTable vtable={0};
    LinphoneProxyConfig* proxy_cfg;
    LinphoneAddress *from;
    LinphoneAuthInfo *info;
    char* identity=NULL;
    char* password=NULL;
    const char* server_addr;
    identity=self.account.text.UTF8String;
    password=self.password.text.UTF8String;
//#ifdef DEBUG
//    linphone_core_enable_logs(NULL); /*enable liblinphone logs.*/
//#endif
    signal(SIGINT,stop);
    vtable.registration_state_changed=registration_state_changed;
    lc=linphone_core_new(&vtable,NULL,NULL,NULL);
    proxy_cfg = linphone_proxy_config_new();
    /*parse identity*/
    from = linphone_address_new(identity);
    if (from==NULL){
        printf("%s not a valid sip uri, must be like sip:toto@sip.linphone.org \n",identity);
        goto end;
    }
    if (password!=NULL){
        info=linphone_auth_info_new(linphone_address_get_username(from),NULL,password,NULL,NULL,NULL); /*create authentication structure from identity*/
        linphone_core_add_auth_info(lc,info); /*add authentication info to LinphoneCore*/
    }
    // configure proxy entries
    linphone_proxy_config_set_identity(proxy_cfg,identity); /*set identity with user name and domain*/
    server_addr = linphone_address_get_domain(from); /*extract domain address from identity*/
    linphone_proxy_config_set_server_addr(proxy_cfg,server_addr); /* we assume domain = proxy server address*/
    linphone_proxy_config_enable_register(proxy_cfg,TRUE); /*activate registration for this proxy config*/
    linphone_address_unref(from); /*release resource*/
    linphone_core_add_proxy_config(lc,proxy_cfg); /*add proxy config to linphone core*/
    linphone_core_set_default_proxy(lc,proxy_cfg); /*set to default proxy*/

    /* main loop for receiving notifications and doing background linphonecore work: */
    while(running){
        linphone_core_iterate(lc); /* first iterate initiates registration */
        ms_usleep(50000);
        NSLog(@"我在first running");
    }
    proxy_cfg = linphone_core_get_default_proxy_config(lc); /* get default proxy config*/
    linphone_proxy_config_edit(proxy_cfg); /*start editing proxy configuration*/
    linphone_proxy_config_enable_register(proxy_cfg,FALSE); /*de-activate registration for this proxy config*/
    linphone_proxy_config_done(proxy_cfg); /*initiate REGISTER with expire = 0*/
    while(linphone_proxy_config_get_state(proxy_cfg) !=  LinphoneRegistrationCleared){
        linphone_core_iterate(lc); /*to make sure we receive call backs before shutting down*/
        ms_usleep(50000);
        NSLog(@"我在secound running");
    }
end:
     printf("Shutting down...\n");
    linphone_core_destroy(lc);
    printf("Exited\n");
}
- (IBAction)cancel:(id)sender {
    
}
@end
