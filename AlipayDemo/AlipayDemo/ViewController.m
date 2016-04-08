//
//  ViewController.m
//  AlipayDemo
//
//  Created by zhoushuyang on 16/4/5.
//  Copyright (c) 2015年 zhoushuyang. All rights reserved.
//

#import "ViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "MyPayHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"支付" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 100, 50);
    [button addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (NSString*)generateTradeNO
{
   NSString *soureString = @"0123456789ABCDEFGHIGKLMNOPQRSTUVWXYZ";
   NSMutableString *result = [[NSMutableString alloc]init];
    for (NSInteger i = 0; i < 15; i++) {
        NSInteger index = arc4random()%(soureString.length);
        NSString *charactor = [soureString substringWithRange:NSMakeRange(index, 1)];
        [result appendString:charactor];
    }
   return result;
}

//1:生成订单，订单信息
//2:签名
//3:启动支付宝进行支付
//4:处理支付结果
- (void)pay:(id)sender
{
    Order *order = [[Order alloc]init];
    order.partner = PartnerID;
    order.seller  = SellerID;
    order.tradeNO = [self generateTradeNO];
    order.productName = @"iphone6s";
    order.productDescription = @"iphone6s降价处理";
    order.amount = @"0.01"; //商品价格
    order.notifyURL = @"http://www.xxx.com"; //回调URL
    //service 支付服务器，固定
    order.service = @"mobile.securitypay.pay";
    //1:商品支付
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    //超时时间30分
    order.itBPay = @"30m";
    //支付宝软件再次启动我的应用程序，需要知道我的URL scheme
    NSString *appScheme = @"AlipayDemoTest";
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    //使用私钥进行签名
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderSpec];
    
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        //进行支付，启动支付宝进行支付
        //如果有支付宝app 调用 app 如果没有调用网页
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"支付%@",resultDic);
            for (NSString *key in resultDic) {
                //NSLog(@"new%@-%@",key,resultDic[key]);
            }
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
