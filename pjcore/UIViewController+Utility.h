//
//  UIViewController+Utility.h
//  PJFramework
//
//  Created by 陆振文 on 14-7-30.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "HttpResult.h"

@interface UIViewController (Utility)



/////////////// 对话框 部分 ///////////////
#pragma mark Dialog Utility Methods
/*!
 所以对话框调用方法可以在线程里面调用
 */

-(void)showMessage:(NSString *)msg;

-(void)showMessage:(NSString *)title message:(NSString *) msg;
-(void)showMessage:(NSString *)title message:(NSString *) msg delegate:(id<UIAlertViewDelegate>) delg;
-(void)showMessage:(NSString *)title message:(NSString *) msg buttonLabel:(NSString *) btn;
-(void)showMessage:(NSString *)title message:(NSString *) msg buttonLabel:(NSString *) btn delegate:(id<UIAlertViewDelegate>) delg;

/*!
 此方法会等待返回
 @return YES:用户按了确定键，否则NO
 */

-(BOOL)showConfirmMessage:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>) delg;

-(BOOL)showConfirmMessage:(NSString *)title message:(NSString *)message yesButton:(NSString *)yesText cancelButton:(NSString *)cancelText delegate:(id<UIAlertViewDelegate>) delg;

/*!
 此方法会等待返回
 */
-(NSString *)showInputMessage:(NSString *)title initialText:(NSString *)defaultVal placeholder:(NSString *)holdertext secure:(BOOL)sec  delegate:(id<UIAlertViewDelegate>) delg;

-(NSString *)showInputMessage:(NSString *)title initialText:(NSString *)defaultVal placeholder:(NSString *)holdertext  yesButton:(NSString *)yes cancelButton:(NSString *) cancel secure:(BOOL)sec  delegate:(id<UIAlertViewDelegate>) delg;

-(void)showTip:(NSString *)tip;

-(void)showProgressMessage:(NSString *)msg;
-(void)showProgressMessageWithView:(UIView *) view;

-(void)showProgress:(BOOL)modal;

////////////// 对话框部分结束 /////////////


#pragma mark Http Utility Methods
////////////// http部分 开始  ////////////

/**
 * 停止所有网络访问
 * PENGJU
 * 2012-10-23 上午10:33:49
 */
-(void)stopAllAsyncRequest;


/**
 * 发起网络请求
 */
-(void)asyncRequest:(ASIHTTPRequest *)request ;
/**
 * 网络不可用时调用
 * PENGJU
 * 2012-11-29 下午1:49:09
 */
-(void) onNetworkNotAvailable;

/**
 * 判断网络请求是否成功返回，失败或发生错误时提示
 */
-(BOOL) isHttpSuccessAndNotify:(HttpResult *)result;
/**
 * 网络请求失败时调用
 * PENGJU
 * 2012-11-29 下午1:51:36
 * @param msg 失败原因,可能为null
 */
-(void)httpDidFailure:(NSString *)reason;

/**
 * 发送网络请求前调用，属于UI线程
 */
-(void)httpWillRequest:(ASIHTTPRequest *)req ;

/**
 * 网络请求返回，属于UI线程
 */
-(void) httpDisResponse:(ASIHTTPRequest *)request withResult:(HttpResult *)result ;
/**
 * 取消网络请求时调用，属于UI线程
 */

-(ASIHTTPRequest *) requestWithRequestCode:(NSInteger)requestCode url:(NSString *)url expectedDataFormat:(ASIExpectedDataFormat)edf responseDataFormat:(ASIResponseDataFormat)rdf extraData:(id)extData parameterPairs:(id)keyValue,...;

////////////// http部分 结束  ////////////


#pragma mark InputSoft Utility Methods

-(CGSize)keyboardSize;
-(void) correctViewAvoidingKeyboardShelter:(UIView *)target;


@end
