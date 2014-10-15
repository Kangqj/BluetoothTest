//
//  ViewController.m
//  BluetoothTest
//
//  Created by 康起军 on 14-10-14.
//  Copyright (c) 2014年 康起军. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize picker, session, btnClick, btnConnect, lblPlayer1, lblPlayer2, lblTimer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    gameState = GameState_end;
}

//连接
- (IBAction)connect:(id)sender
{
    [self clearUI];
    
    picker = [[GKPeerPickerController alloc] init];
    
    picker.delegate = self;
    
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [picker show];
    
}



//发送数据
- (IBAction)onClick:(id)sender {
    
    if (gameState == GameState_end)
    {
        return;
    }
    
    int count = [lblPlayer1.text intValue];
    
    lblPlayer1.text = [NSString stringWithFormat:@"%i",++count];
    
    NSString *sendStr = [NSString
                         
                         stringWithFormat:@"{\"code\":%i,\"count\":%i}",GAMING,count];
    
    NSData* data = [sendStr dataUsingEncoding: NSUTF8StringEncoding];
    
    if (session) {
        
        [session sendDataToAllPeers:data
                        withDataMode:GKSendDataReliable  error:nil];
    }
    
}

//接受数据
- (void) receiveData:(NSData *)data  fromPeer:(NSString *)peer
           inSession:(GKSession *)session  context:(void *)context

{
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data
                  
                                                 options:NSJSONReadingMutableContainers error:nil];
    
    NSNumber *codeObj = [jsonObj objectForKey:@"code"];
    
    if ([codeObj intValue]== GAMING) {
        
        NSNumber * countObj= [jsonObj objectForKey:@"count"];
        
        lblPlayer2.text = [NSString stringWithFormat:@"%@",countObj];
        
        gameState = GameState_Online;
        
    } else if ([codeObj intValue]== GAMED) {  
        
        gameState = GameState_end;
        [self clearUI];  
        
        [timer invalidate];
        timer = nil;
    }  
}

//连接成功回调
- (void)peerPickerController:(GKPeerPickerController *)pk didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *) session
{
    NSLog(@"建立连接");
    
    self.session = session;
    
    session.delegate = self;
    
    [session setDataReceiveHandler:self withContext:nil];
    
    picker.delegate = nil;
    
    [picker dismiss];
    
    [btnConnect setEnabled:NO];
    
    [btnConnect setTitle:@"已连接" forState:UIControlStateNormal];
    
    //开始计时
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
             
                                           selector:@selector(updateTimer)  
             
                                           userInfo:nil repeats:YES];
    
}


- (void)updateTimer
{
    if (numCount <= ALLTime)
    {
        lblTimer.text = [NSString stringWithFormat:@"%ds",ALLTime - numCount];
        
        numCount ++;
        
        gameState = GameState_Online;
    }
    else{
        
        NSInteger myPer = [lblPlayer1.text intValue];
        NSInteger youPer = [lblPlayer2.text intValue];
        
        NSString *msg = @"";
        
        if (myPer > youPer)
        {
            msg = @"恭喜你，你赢了！";
        }
        else if (myPer < youPer)
        {
            msg = @"真遗憾，你输了！";
        }
        else
        {
            msg = @"哇偶，平局耶！";
        }
     
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"再来一次", nil];
        [alertView show];
        
        gameState = GameState_end;
        
        [timer invalidate];
        timer = nil;
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
             
                                           selector:@selector(updateTimer)
             
                                           userInfo:nil repeats:YES];
    
    [self clearUI];
}


//分配创建会话
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker

           sessionForConnectionType:(GKPeerPickerConnectionType)type {
    
    GKSession *session = [[GKSession alloc] initWithSessionID:@"mySession"
                          
                                                  displayName:@"连接我" sessionMode:GKSessionModePeer];
    
    return session;  
}

//会话状态变化回调
- (void)session:(GKSession *)session peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state
{
    if (state == GKPeerStateConnected)
    {
        NSLog(@"connected");
        
        [btnConnect setTitle:@"已连接" forState:UIControlStateNormal];
        [btnConnect setEnabled:NO];
        
        gameState = GameState_Online;
        
    }
    else if (state == GKPeerStateDisconnected)
    {
        [btnConnect setTitle:@"连接断开了" forState:UIControlStateNormal];
        [btnConnect setEnabled:YES];
        
        NSLog(@"disconnected");
        [self clearUI];
        
        
        [timer invalidate];
        timer = nil;
        
        gameState = GameState_end;
    }
}


-(void) clearUI
{
    lblPlayer1.text = @"";
    lblPlayer2.text = @"";
    lblTimer.text = @"30s";
    
    numCount = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
