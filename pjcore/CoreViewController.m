//
//  CoreViewController.m
//  PJFramework
//
//  Created by 陆振文 on 14-8-2.
//  Copyright (c) 2014年 pj. All rights reserved.
//

#import "CoreViewController.h"

#import "NSObject+ApplicationSession.h"
#import "ASIFormDataRequest.h"
#import "HttpResult.h"
#import "HttpUtility.h"


@interface CoreViewController () <ASIHTTPRequestDelegate>
@property (nonatomic, STRONG) NSMutableArray *requestQueue ;

@end

@implementation CoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *)requestQueue{
    if (!_requestQueue) {
        @synchronized(self){
            if (!_requestQueue) {
                _requestQueue = [[NSMutableArray alloc] initWithCapacity:5];
            }
        }
    }
    return _requestQueue;
}

-(void)addToRequestQueue:(ASIHTTPRequest *)req{
    @synchronized(self){
        [[self requestQueue] addObject:req];
        [self httpRequestCountDidChange:_requestQueue.count];
    }
}

-(void)removeFromRequestQueue:(ASIHTTPRequest *)req{
    @synchronized(self){
        [[self requestQueue] removeObject:req];
        [self httpRequestCountDidChange:_requestQueue.count];
    }
}


- (void)dealloc
{
    Release(_requestQueue);
#ifndef ARC
    [super dealloc];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark Http Utility Methods
////////////// http部分 开始  ////////////

/**
 * 停止所有网络访问
 * PENGJU
 * 2012-10-23 上午10:33:49
 */
-(void)stopAllAsyncRequest{
    @synchronized(self){
        for (ASIHTTPRequest *req in _requestQueue) {
            req.delegate = nil;
            [req cancel];
        }
        // 删除自己的http请求列表
        [_requestQueue removeAllObjects];
    }
}


-(void)stopRequest:(ASIHTTPRequest *)request{
    [request cancel];
}


/**
 * 发起网络请求
 */
-(void)asyncRequest:(ASIHTTPRequest *)request {
    if ([self isNetworkAvailable]) {
        request.defaultResponseEncoding=NSUTF8StringEncoding;
        if ([request isKindOfClass:[ASIFormDataRequest class]]) {
            ASIFormDataRequest *req = (ASIFormDataRequest *)request;
            req.stringEncoding = NSUTF8StringEncoding;
        }
        
        // 会话维护
        if (notEmptyString([self sessionId])) {
            NSString *session=[NSString stringWithFormat:@"JSESSIONID=%@",[self sessionId]];
            [request addRequestHeader:@"Cookie" value:session];
        }
        
        request.delegate=self;
        [self addToRequestQueue:request];
        
        [request startAsynchronous];
    }else{
        [self onNetworkNotAvailable];
    }
}
/**
 * 网络不可用时调用
 * PENGJU
 * 2012-11-29 下午1:49:09
 */
-(void) onNetworkNotAvailable{
    [self showTip:@"network not available"];
}

/**
 * 判断网络请求是否成功返回，失败或发生错误时提示
 */
-(BOOL) isHttpSuccessAndNotify:(HttpResult *)result{
    BOOL isOk = NO;
    if (result && result.statusCode == kHTTPOK) {
        isOk = YES;
    }else{
        [self httpDidFailure:result.statusText?result.statusText:@"http request failure"];
        isOk = NO;
    }
    return isOk;
}
/**
 * 网络请求失败时调用
 * PENGJU
 * 2012-11-29 下午1:51:36
 * @param msg 失败原因,可能为null
 */
-(void)httpDidFailure:(NSString *)reason{
    [self showMessage:reason];
}

/**
 * 发送网络请求前调用，属于UI线程
 */
-(void)httpWillRequest:(ASIHTTPRequest *)req {
    
}

/**
 * 网络请求返回，属于UI线程
 */
-(void) httpDidResponse:(ASIHTTPRequest *)request withResult:(HttpResult *)result {
    
}

-(void) httpRequestCountDidChange:(int)count{
    if (count>0) {
        [self showProgress:YES];
    }else{
        [self closeProgress];
    }
}

-(ASIHTTPRequest *) requestWithRequestCode:(NSInteger)requestCode url:(NSString *)url expectedDataFormat:(ASIExpectedDataFormat)edf responseDataFormat:(ASIResponseDataFormat)rdf extraData:(id)extData parameterPairs:(id)keyValue,...{
    ASIFormDataRequest *http = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    http.requestCode = requestCode;
    http.expectedDataFormat = edf;
    http.responseDataFormat = rdf;
    http.extraData = extData;
    
    // 设置参数
    va_list list;
    id arg[2];
    arg[0]=arg[1]=nil;
    id tmp=nil;
    int count=0;
    va_start(list, keyValue);
    tmp=keyValue;//第一个参数
    while (tmp) {
        arg[count++] = tmp;
        if (count%2==0) {
            //参数值为空的不发
            if (arg[1]) {
                [http setPostValue:arg[1] forKey:arg[0]];
            }
        }
        count%=2;
        tmp=va_arg(list, id);
    }
    va_end(list);
    
    http.requestMethod = METHOD_POST;
    
    return http;
}

// 视图将隐藏时停止所有http请求
-(void)viewWillDisappear:(BOOL)animated{
    [self stopAllAsyncRequest];
    [super viewWillDisappear:animated];
}

////////////// http部分 结束  ////////////


#pragma mark InputSoft Utility Methods

#warning unimplementation
-(CGSize)keyboardSize{
    return CGSizeMake(0, 0);
}

#warning unimplementation
-(void) correctViewAvoidingKeyboardShelter:(UIView *)target{
    
}


#pragma mark ASIHTTPRequest delegate methods

- (void)requestStarted:(ASIHTTPRequest *)request{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self httpWillRequest:request];
    });
}
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    PJLog(@"http header:%@",responseHeaders);
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    
    //处理数据
    NSData *data=request.responseData;
    
    //debug部分
    PJLog(@"http response:%@",AutoRelease([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]));
    //debug end
    
    
    
    id responseData=nil;
    if (request.expectedDataFormat == kASIExpectedDataString) {
        responseData=AutoRelease([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }else if (request.expectedDataFormat == kASIExpectedDataBytes) {
        responseData=data;
    }else {
        if (request.responseDataFormat == kASIResponseDataJSON) {
            responseData=[HttpUtility parseJSON:data];
        }else if (request.responseDataFormat == kASIResponseDataXML) {
            responseData=[HttpUtility parseXML:data];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self httpDidFailure:@"illegal response data format"];
            });
        }
    }
    
    if (responseData) {
        HttpResult *result = [[HttpResult alloc] initWithResponseData:responseData andResponseHeaders:[request responseHeaders]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self httpDidResponse:request withResult:result];
        });
    }
    
    Release(result);
    
    //收尾工作
    [self removeFromRequestQueue:request];
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    if ([request error].code==ASIConnectionFailureErrorType) {
        [self performSelectorOnMainThread:@selector(onNetworkNotAvailable) withObject:nil waitUntilDone:NO];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self httpDidFailure:[[request error] description]];
        });
    }
    //收尾工作
    [self removeFromRequestQueue:request];
}


@end




@implementation UIViewController (Utility)

/////////////// 对话框 部分 ///////////////
#pragma mark Dialog Utility Methods
/*!
 可以在线程里面调用
 */
-(void)showMessage:(NSString *)msg{
    [self showMessage:nil message:msg buttonLabel:nil delegate:nil];
}
/*!
 可以在线程里面调用
 */
-(void)showMessage:(NSString *)title message:(NSString *) msg{
    [self showMessage:title message:msg buttonLabel:nil delegate:nil];
}
/*!
 可以在线程里面调用
 */
-(void)showMessage:(NSString *)title message:(NSString *) msg delegate:(id<UIAlertViewDelegate>) delg{
    [self showMessage:title message:msg buttonLabel:nil delegate:delg];
}
/*!
 可以在线程里面调用
 */
-(void)showMessage:(NSString *)title message:(NSString *) msg buttonLabel:(NSString *) btn{
    [self showMessage:title message:msg buttonLabel:btn delegate:nil];
}
/*!
 可以在线程里面调用
 */
-(void)showMessage:(NSString *)title message:(NSString *) msg buttonLabel:(NSString *) btn delegate:(id<UIAlertViewDelegate>) delg{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delg cancelButtonTitle:(btn?btn:@"OK") otherButtonTitles: nil];
        [alert show];
        Release(alert);
    });
}

/*!
 此方法会等待返回，只能在主线程调用
 @return YES:用户按了确定键，否则NO
 */

-(BOOL)showConfirmMessage:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>) delg{
    return [UIViewController showConfirmMessage:title message:message delegate:delg];
}
/*!
 此方法会等待返回，只能在主线程调用
 @return YES:用户按了确定键，否则NO
 */
-(BOOL)showConfirmMessage:(NSString *)title message:(NSString *)message yesButton:(NSString *)yesText cancelButton:(NSString *)cancelText delegate:(id<UIAlertViewDelegate>) delg{
    return [UIViewController showConfirmMessage:title message:message yesButton:yesText cancelButton:cancelText delegate:delg];
}

/*!
 此方法会等待返回，只能在主线程调用
 */
-(NSString *)showInputMessage:(NSString *)title initialText:(NSString *)defaultVal placeholder:(NSString *)holdertext secure:(BOOL)sec  delegate:(id<UIAlertViewDelegate>) delg{
    return [UIViewController showInputMessage:title initialText:defaultVal placeholder:holdertext secure:sec delegate:delg];
}

/*!
 此方法会等待返回，只能在主线程调用
 */
-(NSString *)showInputMessage:(NSString *)title initialText:(NSString *)defaultVal placeholder:(NSString *)holdertext  yesButton:(NSString *)yes cancelButton:(NSString *) cancel secure:(BOOL)sec  delegate:(id<UIAlertViewDelegate>) delg{
    return [UIViewController showInputMessage:title initialText:defaultVal placeholder:holdertext yesButton:yes cancelButton:cancel secure:sec delegate:delg];
}

/*!
 此方法会等待返回，只能在主线程调用
 @return YES:用户按了确定键，否则NO
 */

+(BOOL)showConfirmMessage:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>) delg{
    return [UIViewController showConfirmMessage:title message:message yesButton:nil cancelButton:nil delegate:delg];
}
/*!
 此方法会等待返回，只能在主线程调用
 @return YES:用户按了确定键，否则NO
 */
#warning umimplementation
+(BOOL)showConfirmMessage:(NSString *)title message:(NSString *)message yesButton:(NSString *)yesText cancelButton:(NSString *)cancelText delegate:(id<UIAlertViewDelegate>) delg{
    return NO;
}

/*!
 此方法会等待返回，只能在主线程调用
 */
+(NSString *)showInputMessage:(NSString *)title initialText:(NSString *)defaultVal placeholder:(NSString *)holdertext secure:(BOOL)sec  delegate:(id<UIAlertViewDelegate>) delg{
    return [self showInputMessage:title initialText:defaultVal placeholder:holdertext yesButton:nil cancelButton:nil secure:sec delegate:delg];
}

/*!
 此方法会等待返回，只能在主线程调用
 */
#warning umimplementation
+(NSString *)showInputMessage:(NSString *)title initialText:(NSString *)defaultVal placeholder:(NSString *)holdertext  yesButton:(NSString *)yes cancelButton:(NSString *) cancel secure:(BOOL)sec  delegate:(id<UIAlertViewDelegate>) delg{
    return nil;
}

/*!
 可在线程中调用
 */
-(void)showTip:(NSString *)tip{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIFont *font=[UIFont systemFontOfSize:16];
        CGFloat gap=40;
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tip sizeWithFont:font].width+gap*2, 40)];
        label.font=font;
        label.textColor=[UIColor lightTextColor];
        label.text=tip;
        label.textAlignment=UITextAlignmentCenter;
        label.layer.cornerRadius=8;
        label.center =self.view.center;
        label.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        label.alpha=0;
        
        [self.view addSubview:label];
        
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        label.alpha=1.0;
        
        [UIView commitAnimations];
        
        [self performSelector:@selector(handleTipState:) withObject:label afterDelay:2.3];
        
        Release(label);
    });
}

-(void)handleTipState:(UIView *)view{
    if (view.alpha>0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        view.alpha=0.0;
        
        [UIView commitAnimations];
        
        [self performSelector:@selector(handleTipState:) withObject:view afterDelay:0.9];
    }else{
        [view removeFromSuperview];
    }
}

/*!
 可在线程中调用
 */
-(void)showProgressMessage:(NSString *)msg{
    [self showProgressMessageWithView:nil];
}
/*!
 可在线程中调用
 */
#warning umimplementation
-(void)showProgressMessageWithView:(UIView *) view{
    
}

#warning umimplementation
-(void)closeProgressMessage{
    
}

/*!
 可在线程中调用
 */
#warning umimplementation
-(void)showProgress:(BOOL)modal{
    
}

#warning umimplementation
-(void)closeProgress{
    
}

////////////// 对话框部分结束 /////////////

@end
