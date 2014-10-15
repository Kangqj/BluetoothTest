//
//  ViewController.h
//  BluetoothTest
//
//  Created by 康起军 on 14-10-14.
//  Copyright (c) 2014年 康起军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#define  GAMING 0          //游戏进行中
#define  GAMED  1          //游戏结束

typedef enum
{
    GameState_Online = 0,
    GameState_end = 1,
}GameState;

#define  ALLTime 30

@interface ViewController : UIViewController <GKSessionDelegate, GKPeerPickerControllerDelegate>
{
    NSTimer *timer;
    
    NSInteger numCount;
    
    GameState gameState;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayer2;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayer1;

@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UIButton *btnClick;

@property (nonatomic, strong) GKPeerPickerController *picker;
@property (nonatomic, strong) GKSession *session;

- (IBAction)onClick:(id)sender;

- (IBAction)connect:(id)sender;

//清除UI画面上的数据
-(void) clearUI;

//更新计时器
-(void) updateTimer;

@end
