//
//  LZDBLEManager.m
//  中央设备
//
//  Created by ZhangTu on 2018/11/21.
//  Copyright © 2018年 bletc. All rights reserved.
//

#import "LZDBLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <SeekcyBeaconSDK/SeekcyBeaconSDK.h>

@interface LZDBLEManager ()<CBCentralManagerDelegate,SKYBeaconManagerScanDelegate>
@property (strong,nonatomic) CBCentralManager *centralManager;//中心设备管理器
/**
 扫描结果
 */
@property (nonatomic,strong) NSMutableArray *scanResultA;
@property (strong,nonatomic) NSMutableArray *peripherals;//连接的外围设备
/**
 <#Description#>
 */
@property (nonatomic,strong) dispatch_source_t timer;

/**
 <#Description#>
 */
@property (nonatomic,strong) NSMutableArray *skyBeacon_A;
@end


@implementation LZDBLEManager


-(instancetype)init{
    
    self = [super init];
    if (self) {
        
       __weak typeof(self) weakSelf = self;
        
        
            __block NSInteger lzdtime = 200; //倒计时时间
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
             self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_timer,DISPATCH_TIME_NOW,5*NSEC_PER_SEC, 0); //每秒执行
            
            dispatch_source_set_event_handler(_timer, ^{
                
                if (lzdtime<=0) {
                    dispatch_source_cancel(weakSelf.timer);
                    
                    
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                     
                       
                            if (weakSelf.delegate &&[weakSelf.delegate respondsToSelector:@selector(LZDBLEManagerCompletionScanWithBeacons:)]) {
                                
                                for (int i = 0; i <weakSelf.scanResultA.count; i++) {
                                    NSDictionary *dicOld =  self.scanResultA[i];
                                    for (int j=i+1; j<weakSelf.scanResultA.count; j++) {
                                        NSDictionary *dicNew =  self.scanResultA[j];

                                        if ([dicOld[@"mac"] isEqualToString:dicNew[@"mac"]]) {
                                            [self.scanResultA removeObject:dicNew];
                                            j-=1;
                                        }
                                    }
                                    
                                }
                                
                                
                                
                                [weakSelf.delegate LZDBLEManagerCompletionScanWithBeacons:weakSelf.scanResultA];
                            }
                            
                            [weakSelf.scanResultA removeAllObjects];
                            [weakSelf.peripherals removeAllObjects];

                            [weakSelf.centralManager stopScan];
                        
                        
                        
                      if(weakSelf.centralManager.state == CBCentralManagerStatePoweredOn) {
                            
                            // 开启的话开始扫描蓝牙设备
                            [weakSelf.centralManager scanForPeripheralsWithServices:nil options:nil];
                          
                          [SKYBeaconManager sharedDefaults].scanBeaconTimeInterval = 1.2;
                          [[SKYBeaconManager sharedDefaults] startScanForSKYBeaconWithDelegate:self uuids:nil distinctionMutipleID:NO isReturnValueEncapsulation:NO];
                           
                        }
                        
                        
                        
                    });
                    
                    
                }
                
                
            });
            dispatch_resume(_timer);
        
        
      
            
            
        
        
    }
    return self;
    
}






//中心服务器状态更新后

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOn:
          

//         CBUUID *lzduuid =  ;
            
            [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"00001803-494c-4f47-4943-544543480000"]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
            [SKYBeaconManager sharedDefaults].scanBeaconTimeInterval = 2;
            [[SKYBeaconManager sharedDefaults] startScanForSKYBeaconWithDelegate:self uuids:nil distinctionMutipleID:NO isReturnValueEncapsulation:NO];
            break;
            
        default:
            [central stopScan];
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
            break;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    

       
        if (peripheral) {
            if(![self.peripherals containsObject:peripheral] && [peripheral.name containsString:@"iBeacon"]){
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:[RSSI stringValue] forKey:@"rssi"];
                
                NSData *data = advertisementData[@"kCBAdvDataManufacturerData"];
                NSString *dataString = data.description;
                dataString = [dataString stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                if (dataString.length<28) {
                    return;
                }
                dataString = [dataString substringWithRange:NSMakeRange(1, dataString.length-2)];
                
                //        4c020215fda50693a4e24fb1afcfa0e6f82d095600010002d8
                //获取mac 地址
                NSString *mac = [dataString substringWithRange:NSMakeRange(28, 12)];
                mac = [mac uppercaseString];
                [dic setValue:mac forKey:@"mac"];
                //获取电量
                NSString *battery = [NSString stringWithFormat:@"%@",[dataString substringFromIndex:dataString.length-2]];
                
                //16进制转10进制
                NSScanner *scanner = [NSScanner scannerWithString:battery];
                unsigned long long longlongValue;
                [scanner scanHexLongLong:&longlongValue];
                NSNumber * hexNumber = [NSNumber numberWithLongLong:longlongValue];
                battery = [hexNumber stringValue];
                [dic setValue:battery forKey:@"battery"];
                
                
                [dic setValue:peripheral.name forKey:@"deviceName"];

                
                
                [self.scanResultA addObject:dic];

                
                
                [self.peripherals addObject:peripheral];
                
                
            }
            
         
            
        }

       
       
//        NSLog(@"发现外围设备... %@",self.scanResultA);
        

    
}

#pragma mark 寻息蓝牙设备
- (void)skyBeaconManagerCompletionScanWithBeacons:(NSArray *)beascons error:(NSError *)error{
    
    if(error){
        if(error.code == SKYBeaconSDKErrorBlueToothPoweredOff){
            
            
        }
        return;
        
    }
    
    /*
     battery = 100;
     deviceName = "Seekcy iBeacon";
     distance = "5.48";
     firmwareVersionMajor = 1;
     firmwareVersionMinor = 0;
     hardwareVersion = 7;
     intervalMillisecond = 50;
     isLocked = 0;
     isMutipleID = 0;
     isSeekcyBeacon = 1;
     lightVoltage = "";
     macAddress = "19:18:FC:05:52:F4";
     major = 10002;
     measuredPower = "-59";
     minor = 5208;
     peripheral = "<CBPeripheral: 0x282bac3c0, identifier = 2F203EE5-5113-5F10-5282-28D50628B130, name = Seekcy iBeacon, state = disconnected>";
     proximityUUID = "";
     rssi = "-76";
     temperature = 0;
     timestampMillisecond = 1542793697;
     txPower = 0;
     uuidReplaceName = "UnKnow UUID";
     **/
    
    
        self.skyBeacon_A = [NSMutableArray arrayWithArray:beascons];

   
    
        for (NSDictionary*skyDic in _skyBeacon_A) {
            NSString *mac = skyDic[@"macAddress"];
            mac =[mac stringByReplacingOccurrencesOfString:@":" withString:@""];
            mac = [mac stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            NSMutableDictionary *muta = [NSMutableDictionary dictionary];
            [muta setValue:mac forKey:@"mac"];
            [muta setValue:skyDic[@"battery"] forKey:@"battery"];
            [muta setValue:skyDic[@"rssi"] forKey:@"rssi"];
            [muta setValue:skyDic[@"deviceName"] forKey:@"deviceName"];
            
            [self.scanResultA addObject:muta];
            
        }
        
        
    
  
    
    
   

    
    
    
    
    
}


-(void)stopScan{
    [self.scanResultA removeAllObjects];
    [self.peripherals removeAllObjects];
    [[SKYBeaconManager sharedDefaults] stopScanSKYBeacon];

    [self.centralManager stopScan];
    dispatch_cancel(self.timer);
    
    
}

- (CBCentralManager *)centralManager
{
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                queue:nil];
    }
    
    return _centralManager;
}

-(NSMutableArray *)scanResultA{
    if (!_scanResultA) {
        _scanResultA = [NSMutableArray array];
    }
    return _scanResultA;
}
#pragma mark - 属性
-(NSMutableArray *)peripherals{
    if(!_peripherals){
        _peripherals=[NSMutableArray array];
    }
    return _peripherals;
}


@end
