//
//  ViewController.m
//  中央设备
//
//  Created by Bletc on 2016/11/3.
//  Copyright © 2016年 bletc. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "LZDBLEManager.h"
#import "BleViewCell.h"

#define kServiceUUID @"00001803-494c-4f47-4943-544543480000" //服务的UUID
#define kCharacteristicUUID @"6A3E4B28-522D-4B3B-82A9-D5E2004534FC" //特征的UUID



@interface ViewController ()<LZDBLEManagerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSMutableArray *peripherals;//连接的外围设备

/**
 <#Description#>
 */
@property (nonatomic,strong) LZDBLEManager *lzdBLEManager;

/**
 
 */
@property (nonatomic,strong) NSArray *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    self.lzdBLEManager = [[LZDBLEManager alloc]init];
    _lzdBLEManager.delegate = self;
}

-(void)LZDBLEManagerCompletionScanWithBeacons:(NSArray *)beascons{
    
    NSLog(@"%ld= beascons%@",beascons.count,beascons);
    
    self.data = [NSArray arrayWithArray:beascons];
    [self.tableView reloadData];
}
- (IBAction)cancleClick:(id)sender {

    [self.lzdBLEManager stopScan];
    
}


- (IBAction)start:(UIBarButtonItem *)sender {
    
    self.lzdBLEManager = [[LZDBLEManager alloc]init];
    _lzdBLEManager.delegate = self;

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([BleViewCell class]) owner:self options:nil].lastObject;
    }
    
    if (self.data.count!=0) {
        NSDictionary *dic = self.data[indexPath.row];
        cell.lab1.text = [NSString stringWithFormat:@"deviceName: %@",dic[@"deviceName"]];
        cell.lab2.text = [NSString stringWithFormat:@"mac: %@",dic[@"mac"]];
        cell.lab3.text = [NSString stringWithFormat:@"battery: %@",dic[@"battery"]];
        cell.lab4.text = [NSString stringWithFormat:@"rssi: %@  ",dic[@"rssi"]];

     
    }
    return cell;
    
}

@end
