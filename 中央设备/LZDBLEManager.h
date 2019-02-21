//
//  LZDBLEManager.h
//  中央设备
//
//  Created by ZhangTu on 2018/11/21.
//  Copyright © 2018年 bletc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol LZDBLEManagerDelegate <NSObject>

#pragma mark 蓝牙设备

/**
 返回设备的mac,
 battery = 216;
 mac = A0E6F82D0956;
 rssi = "-75";
deviceName
 @param beascons <#beascons description#>
 */
- (void)LZDBLEManagerCompletionScanWithBeacons:(NSArray *)beascons ;


@end

@interface LZDBLEManager : NSObject
/**
 <#Description#>
 */
@property (nonatomic,weak) id<LZDBLEManagerDelegate>  delegate;


-(void)stopScan;
@end

NS_ASSUME_NONNULL_END
