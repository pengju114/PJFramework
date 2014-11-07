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

#import "ModalAlertDelegate.h"
#import <CoreGraphics/CoreGraphics.h>

#import "UIView+Extension.h"
#import "DeviceUtility.h"


#import "core.h"



@interface CoreViewController () <ASIHTTPRequestDelegate>
// http
@property (nonatomic, STRONG) NSMutableArray *requestQueue ;
@property (nonatomic, assign) BOOL           viewDidShow;


@property (nonatomic, STRONG) UIView         *correctViewRef;
@property (nonatomic, assign) BOOL           keyboardDidShow;
@property (nonatomic, assign) BOOL           viewDidCorrect;
@property (nonatomic, assign) CGSize         lastKeyboardSize;
@property (nonatomic, assign) NSTimeInterval keyboardAnimDuration;
@property (nonatomic, assign) UIViewAnimationCurve keyboardAnimCurve;

@end

#define kCorrectViewAnimationName  @"CorrectViewAnimation"

@interface AssistanceView : UIView
@property (nonatomic, assign) int assistanceTag;
@end



@implementation CoreViewController

@synthesize correctViewRef;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _viewDidShow = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _lastKeyboardSize = CGSizeZero;
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
        [self httpRequestCountDidChange:(int)_requestQueue.count];
    }
}

-(void)removeFromRequestQueue:(ASIHTTPRequest *)req{
    @synchronized(self){
        [[self requestQueue] removeObject:req];
        [self httpRequestCountDidChange:(int)_requestQueue.count];
    }
}


- (void)dealloc
{
    Release(_requestQueue);
    Release(correctViewRef);
#ifndef ARC
    [super dealloc];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _keyboardDidShow = NO;
    _keyboardAnimDuration = 0.3;
    _keyboardAnimCurve    = UIViewAnimationCurveEaseInOut;
    _viewDidCorrect = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    if (!_viewDidShow) {
        _viewDidShow = YES;
        [self viewDidAppearAtFirstTime:animated];
    }
    
    [super viewDidAppear:animated];
}

-(void)viewDidAppearAtFirstTime:(BOOL)animated{
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self registerKeyBoardNotification];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeModalAlertDelegateNotification:) name:kModalAlertDelegateShouldReleaseNotification object:nil];
    
    [super viewWillAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [self unregisterKeyBoardNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kModalAlertDelegateShouldReleaseNotification object:nil];
    
    [super viewDidDisappear:animated];
}


-(void)registerKeyBoardNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    if (IOSVersion>=5.0) {
    // 发此通知肯定会发keyboardWillShow
//        [center addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    }
}

-(void)unregisterKeyBoardNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    if (IOSVersion>=5.0) {
//        [center removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
//    }
}

-(void)keyboardWillShow:(NSNotification *)ntf{
    
    _keyboardDidShow = YES;
    
    NSDictionary *info = [ntf userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;//获取键盘的size值
    PJLog(@"keyboardWillShow with size %@",NSStringFromCGSize(keyboardSize));
    
    _lastKeyboardSize = keyboardSize;
    //获取键盘出现的动画时间
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    UIViewAnimationCurve animationCurve = [[[ntf userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    _keyboardAnimCurve   = animationCurve;
    _keyboardAnimDuration= animationDuration;
    
    [self correctView];
}
-(void)KeyboardWillHide:(NSNotification *)ntf{
    
    _keyboardDidShow = NO;
    
    NSDictionary *info = [ntf userInfo];
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    UIViewAnimationCurve animationCurve = [[[ntf userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    _keyboardAnimCurve   = animationCurve;
    _keyboardAnimDuration= animationDuration;
    
    PJLog(@"KeyboardWillHide ");
    
    [self restoreView];
}
//
//-(void)keyboardWillChangeFrame:(NSNotification *)ntf{
//    NSDictionary *info = [ntf userInfo];
//    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGSize keyboardSize = [value CGRectValue].size;//获取键盘的size值
//    PJLog(@"keyboardWillChangeFrame with size %@",NSStringFromCGSize(keyboardSize));
//    
//    _lastKeyboardSize = keyboardSize;
//    
//    [self correctView];
//}

-(void)correctView{
    if (correctViewRef && _keyboardDidShow) {
        
        CGRect rect = [correctViewRef frameInView:[UIApplication sharedApplication].keyWindow];
        
        CGFloat screenHeight = [DeviceUtility screenHeight];
        
        PJLog(@"screenheight = %.1f rect in view %@",screenHeight,NSStringFromCGRect(rect));
        
        const CGFloat gap=0;// 加上gap在有多个输入框在滚动视图里面时，从上一输入框切换到下一输入框（此输入框网上滚才可见），有时会有露底的情况
        
        BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
        CGFloat keyboardHeight = isLandscape?_lastKeyboardSize.width : _lastKeyboardSize.height;
        
        CGFloat visibleHeight  =  screenHeight - keyboardHeight - gap;
        
        
        CGFloat y = rect.origin.y + rect.size.height;
        
        if (y > visibleHeight) {
            // 被挡
            _viewDidCorrect = YES;
            
            [self moveViewWithTop:visibleHeight - y + [self extendedTop] + self.view.frame
             .origin.y];// 在原来的基础上上移
        }
    }
}

-(void)restoreView{
    if (correctViewRef && _viewDidCorrect) {
        _viewDidCorrect = NO;
        self.correctViewRef = nil;
        [self moveViewWithTop:[self extendedTop]];
    }
}

-(void)moveViewWithTop:(CGFloat)top{
    [UIView beginAnimations:kCorrectViewAnimationName context:nil];
    [UIView setAnimationCurve:_keyboardAnimCurve];
    [UIView setAnimationDuration:_keyboardAnimDuration];
    
    CGRect r=self.view.frame;
    
    CGRect n=CGRectMake(r.origin.x, top, r.size.width, r.size.height);
    
    PJLog(@"move view to %@",NSStringFromCGRect(n));
    
    self.view.frame=n;
    
    [UIView commitAnimations];
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
            
            [self removeFromRequestQueue:req];
        }
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
        request.useSessionPersistence = YES;
        
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
    
#if debug
    NSMutableString *debugString = [[NSMutableString alloc] init];
#endif
    
    
    while (tmp) {
        arg[count++] = tmp;
        if (count%2==0) {
            //参数值为空的不发
            if (arg[1]) {
                [http addPostValue:arg[1] forKey:arg[0]];
#if debug
                [debugString appendFormat:@"%@=%@&",arg[0],arg[1]];
#endif
            }
        }
        count%=2;
        tmp=va_arg(list, id);
    }
    va_end(list);
    
#if debug
    if ([debugString length]>0) {
        [debugString deleteCharactersInRange:NSMakeRange(debugString.length-1, 1)];
    }
    
    PJLog(@"\nmake request: %@\nparameters:%@",url,debugString);
    Release(debugString);
#endif
    
    http.requestMethod = METHOD_POST;
    
    return http;
}

// 视图将隐藏时停止所有http请求
-(void)viewWillDisappear:(BOOL)animated{
    [self stopAllAsyncRequest];
    [super viewWillDisappear:animated];
}


-(void)removeModalAlertDelegateNotification:(NSNotification *)ntf{
    
    [[UIViewController modalAlertDelegateQueue] removeObject:[[ntf userInfo] objectForKey:kModalAlertDelegate]];
}

////////////// http部分 结束  ////////////


#pragma mark InputSoft Utility Methods

-(CGSize)keyboardSize{
    return _lastKeyboardSize;
}

-(void) correctViewAvoidingKeyboardShelter:(UIView *)target{
    self.correctViewRef = target;
    [self correctView];
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
    
    PJLog(@"cookie %@",request.responseCookies);
    
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
            [self httpDidFailure:[[request error] localizedDescription]];
        });
    }
    PJLog(@"http fail %@",[[request error] localizedDescription]);
    //收尾工作
    [self removeFromRequestQueue:request];
}


@end









static NSMutableArray *modalAlertDelegateQueue = nil;
static NSString * delegateLock = @"delegate.lock";


// 默认对话框动画时长
#define kAnimationDuration  0.3
#define kProgressAnimationName  @"ProgressAnimation"

#define kTagProgressMsgRoot        13051
#define kTagProgressMsgLabelRoot   13052
#define kTagProgressMsgLabel       13053
#define kTagProgressMsgMask        13054


#define kTagProgressCtr            13055
#define kTagProgressIndicator      13056

@implementation UIViewController (Utility)



+(NSMutableArray *)modalAlertDelegateQueue{
    if (!modalAlertDelegateQueue) {
        @synchronized(delegateLock){
            if (!modalAlertDelegateQueue) {
                modalAlertDelegateQueue = [[NSMutableArray alloc] initWithCapacity:5];
            }
        }
    }
    return modalAlertDelegateQueue;
}

+(void)enqueueModalAlertDelegate:(ModalAlertDelegate *)delg{
    
    [[self modalAlertDelegateQueue] addObject:delg];
}


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
+(BOOL)showConfirmMessage:(NSString *)title message:(NSString *)message yesButton:(NSString *)yesText cancelButton:(NSString *)cancelText delegate:(id<UIAlertViewDelegate>) delg{
    
    ModalAlertDelegate *delegate = [[ModalAlertDelegate alloc] initWithRunloop:CFRunLoopGetCurrent()];
    delegate.outsideDelegate = delg;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:isEmptyString(cancelText)?@"Cancel":cancelText otherButtonTitles:isEmptyString(yesText)?@"OK":yesText, nil];
    
    [alert show];
    
    CFRunLoopRun();
    
    BOOL ret = delegate.index == alert.firstOtherButtonIndex;
    
    [self enqueueModalAlertDelegate:delegate];
    
    Release(delegate);
    Release(alert);
    
    return ret;
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
+(NSString *)showInputMessage:(NSString *)title initialText:(NSString *)defaultVal placeholder:(NSString *)holdertext  yesButton:(NSString *)yes cancelButton:(NSString *) cancel secure:(BOOL)sec  delegate:(id<UIAlertViewDelegate>) delg{
    
    BOOL gtIOS5 = IOSVersion>=5.0f;
    
    ModalAlertDelegate *delegate = [[ModalAlertDelegate alloc] initWithRunloop:CFRunLoopGetCurrent()];
    delegate.outsideDelegate = delg;
    delegate.correctPosition = !gtIOS5;
    
    UIAlertView *inputAlert=[[UIAlertView alloc] initWithTitle:title message:gtIOS5?nil:@"\n\n" delegate:delegate cancelButtonTitle:(cancel?cancel:@"Cancel") otherButtonTitles:(yes?yes:@"OK"), nil];
    
    if (gtIOS5){
        inputAlert.alertViewStyle =sec? UIAlertViewStyleSecureTextInput:UIAlertViewStylePlainTextInput;
    }
    
    [inputAlert show];
    
    UITextField *inputField = nil;
    // iOS5 以下
    if (!gtIOS5) {
        
        CGRect dialogRect=[inputAlert bounds];
        
        CGFloat gap=10;
        CGFloat width=dialogRect.size.width-gap*2;
        CGFloat height=32;
        
        inputField=AutoRelease([[UITextField alloc] initWithFrame:CGRectMake(gap, dialogRect.size.height*0.5-height*0.5, width, height)]);
        inputField.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        inputField.returnKeyType=UIReturnKeyDone;
        inputField.keyboardType=UIKeyboardTypeDefault;
        inputField.keyboardAppearance=UIKeyboardAppearanceAlert;
        inputField.borderStyle=UITextBorderStyleRoundedRect;
        inputField.clearButtonMode=UITextFieldViewModeWhileEditing;
        inputField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        inputField.secureTextEntry = sec;
        
        [inputAlert addSubview:inputField];
        
        [inputField addTarget:self action:@selector(didEndInput:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }else{
        inputField = [inputAlert textFieldAtIndex:0];
    }
    
    inputField.placeholder=holdertext;
    inputField.text=defaultVal;
    
    
    [inputField becomeFirstResponder];
    
    
    CFRunLoopRun();
    
    NSString *ret = nil;
    
    if (delegate.index == inputAlert.firstOtherButtonIndex) {
        ret = [NSString stringWithFormat:@"%@",inputField.text];
        ret = trim(ret);
    }
    
    
    [self enqueueModalAlertDelegate:delegate];
    
    Release(delegate);
    Release(inputAlert);
    
    return ret;
}

-(void)didEndInput:(id) sender{
    [sender resignFirstResponder];
}


/*!
 可在线程中调用
 */
-(void)showTip:(NSString *)tip{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIFont *font=[UIFont systemFontOfSize:16];
        CGFloat gap=20;
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, [tip sizeWithFont:font].width+gap*2, 40)];
        label.font=font;
        label.textColor=[UIColor lightTextColor];
        label.lineBreakMode = UILineBreakModeMiddleTruncation;
        label.textAlignment=UITextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumFontSize = 8;
        label.text=tip;
        label.layer.cornerRadius=6;
        label.layer.masksToBounds = YES;
        label.center =self.view.center;
        label.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        label.alpha=0;
        
        label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        
        [self.view addSubview:label];
        
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kAnimationDuration];
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
        [UIView setAnimationDuration:kAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        view.alpha=0.0;
        
        [UIView commitAnimations];
        
        [self performSelector:@selector(handleTipState:) withObject:view afterDelay:kAnimationDuration*3];
    }else{
        [view removeFromSuperview];
    }
}

/*!
 可在线程中调用
 */
-(void)showProgressMessage:(NSString *)msg{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 先在视图中找
        UIView *progressCtr = [self.view viewWithTag:kTagProgressMsgLabelRoot];
        if (progressCtr) {
            PJLog(@"show previous message view");
            
            UILabel *label = (UILabel *)[progressCtr viewWithTag:kTagProgressMsgLabel];
            if (label) {
                label.text = msg;
            }
            
            [self showProgressMessageWithView:progressCtr];
        }else{
            PJLog(@"show new message view");
            
            CGFloat gap = 5;
            
            CGRect  rect = CGRectMake(0, 0, 0, 0);// 不初始化在iOS7.1.1以下iOS7.0.0以上会崩溃
            
            UIFont  *font = [UIFont systemFontOfSize:14];
            UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activity.hidesWhenStopped = YES;
            
            CGSize stringSize = [msg sizeWithFont:font];
            
            CGFloat w = fminf(140, gap*2+stringSize.width);
            UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, stringSize.height+4)];
            [text setFont:font];
            [text setTextColor:[UIColor whiteColor]];
            [text setBackgroundColor:[UIColor clearColor]];
            text.textAlignment = UITextAlignmentCenter;
            text.adjustsFontSizeToFitWidth = YES;
            text.minimumFontSize = 8;
            text.lineBreakMode = NSLineBreakByTruncatingMiddle;
            
            text.text = msg;
            
            rect.size.width = fmaxf(text.frame.size.width , activity.frame.size.width);
            
            CGFloat wg = gap;
            
            rect.size.height = text.frame.size.height + activity.frame.size.height + wg;
            
            
            activity.frame = CGRectMake((rect.size.width - activity.frame.size.width) * 0.5f, 0, activity.frame.size.width, activity.frame.size.height);
            
            text.frame = CGRectMake((rect.size.width - text.frame.size.width) * 0.5f, activity.frame.origin.y+wg+activity.frame.size.height, text.frame.size.width, text.frame.size.height);
            
            
            
            UIView *ctr = [[UIView alloc] initWithFrame:rect];
            [ctr setBackgroundColor:[UIColor clearColor]];
            
            text.tag = kTagProgressMsgLabel;
            ctr.tag  = kTagProgressMsgLabelRoot;
            
            [ctr addSubview:text];
            [ctr addSubview:activity];
            [activity startAnimating];
            
            [self showProgressMessageWithView:ctr];
            
            Release(activity);
            Release(text);
            Release(ctr);
        }
    });
}
/*!
 可在线程中调用
 */
-(void)showProgressMessageWithView:(UIView *) view{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *existMask = [self.view viewWithTag:kTagProgressMsgMask];
        AssistanceView *existCtr  = nil;
        if (existMask) {
            existCtr = (AssistanceView *)[existMask viewWithTag:kTagProgressMsgRoot];
            
            if (![existMask containsView:view]) {// 之前没有添加到这里
                [existCtr removeAllChildren];
                view.center = rectCenter(existCtr.frame);
                [existCtr addSubview:view];
            }
            existCtr.assistanceTag += 1;
            
            PJLog(@"progress exist");
        }else{
            PJLog(@"progress create");
            CGRect rect = CGRectMake(0,0,160,90);
            
            AssistanceView *ctr = [[AssistanceView alloc] initWithFrame:rect];
            ctr.layer.cornerRadius = 8;
            [ctr setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
            
            view.center = rectCenter(rect);
            [ctr addSubview:view];
            
            ctr.alpha = 0.0f;
            
            ctr.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
            
            UIView *mask = [[UIView alloc] initWithFrame:self.view.bounds];
            mask.backgroundColor = [UIColor clearColor];
            mask.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            mask.userInteractionEnabled = YES;// 挡住所有点击
            
            ctr.center = rectCenter(mask.frame);
            mask.center = rectCenter(self.view.frame);
            
            ctr.tag = kTagProgressMsgRoot;
            mask.tag = kTagProgressMsgMask;
            
            ctr.assistanceTag = 1;// 显示一次
            
            [mask addSubview:ctr];
            [self.view addSubview:mask];
            
            existMask = AutoRelease(mask);
            existCtr  = AutoRelease(ctr);
        }
        
        [self.view bringSubviewToFront:existMask];// 确保靠前
        
        if (existCtr.assistanceTag > 0) {
            existMask.hidden = NO;
        }
        
        [UIView beginAnimations:kProgressAnimationName context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:kAnimationDuration];
        existCtr.alpha = 1.0f;
        [UIView commitAnimations];
    });
}

-(void)closeProgressMessage{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        UIView *mask = [self.view viewWithTag:kTagProgressMsgMask];
        if (mask) {
            AssistanceView *ctr = (AssistanceView *)[mask viewWithTag:kTagProgressMsgRoot];
            ctr.assistanceTag--;
            PJLog(@"prepare close progress,showing count %d",ctr.assistanceTag);
            if (ctr.assistanceTag < 1) {
                
                [UIView beginAnimations:kProgressAnimationName context:nil];
                [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                [UIView setAnimationDuration:kAnimationDuration];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(closeProgressAnimationFinish)];
                ctr.alpha = 0.0f;
                [UIView commitAnimations];
            }
        }
    });
}

-(void)closeProgressAnimationFinish{
    UIView *mask = [self.view viewWithTag:kTagProgressMsgMask];
    if (mask) {
        AssistanceView *ctr = (AssistanceView *)[mask viewWithTag:kTagProgressMsgRoot];
        PJLog(@"set progress hidden count = %d",ctr.assistanceTag);
        if (ctr.assistanceTag < 1) {
            mask.hidden = YES;
        }
    }
}

/*!
 可在线程中调用
 */
-(void)showProgress:(BOOL)modal{
    dispatch_async(dispatch_get_main_queue(), ^{
        AssistanceView *ctr = (AssistanceView *)[self.view viewWithTag:kTagProgressCtr];
        if (!ctr) {
            UIActivityIndicatorView *act = AutoRelease([[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]);
            act.hidesWhenStopped = YES;
            act.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
            ctr = AutoRelease([[AssistanceView alloc] initWithFrame:modal?self.view.bounds : act.frame]);
            ctr.backgroundColor = [UIColor clearColor];
            ctr.assistanceTag = 1;
            
            act.tag = kTagProgressIndicator;
            ctr.tag = kTagProgressCtr;
            
            act.center = rectCenter(ctr.frame);
            
            [act startAnimating];
            [ctr addSubview:act];
            
            ctr.center = rectCenter(self.view.bounds);
            ctr.alpha = 0.0;
            
            [self.view addSubview:ctr];
        }else{
            ctr.assistanceTag += 1;
            
            UIView *act = [ctr viewWithTag:kTagProgressIndicator];
            ctr.frame = modal?self.view.bounds:act.bounds;
            ctr.center = rectCenter(self.view.bounds);
        }
        
        
        UIViewAutoresizing asizing = modal?(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth):(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin);
        ctr.autoresizingMask = asizing;
        
        if (ctr.assistanceTag > 0) {
            ctr.hidden = NO;
        }
        
        PJLog(@"progress show count = %d",ctr.assistanceTag);
        
        [UIView beginAnimations:kProgressAnimationName context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:kAnimationDuration];
        ctr.alpha = 1.0f;
        [UIView commitAnimations];
        
    });
}

-(void)closeProgress{
    dispatch_async(dispatch_get_main_queue(), ^{
        AssistanceView *ctr = (AssistanceView *)[self.view viewWithTag:kTagProgressCtr];
        if (ctr) {
            ctr.assistanceTag--;
            
            PJLog(@"progress close count = %d",ctr.assistanceTag);
            
            if (ctr.assistanceTag < 1) {
                
                [UIView beginAnimations:kProgressAnimationName context:nil];
                [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                [UIView setAnimationDuration:kAnimationDuration];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(closeProgressFinish)];
                ctr.alpha = 0.0f;
                [UIView commitAnimations];
            }
        }
    });
}

-(void)closeProgressFinish{
    AssistanceView *ctr = (AssistanceView *)[self.view viewWithTag:kTagProgressCtr];
    if (ctr) {
        if (ctr.assistanceTag < 1) {
            ctr.hidden = YES;
        }
    }
}

////////////// 对话框部分结束 /////////////

-(CGFloat)extendedTop{
    CGFloat top = 0;
    
    if (IOSVersion>=7.0) {
        UIRectEdge edge = self.edgesForExtendedLayout;
        if ((edge & UIRectEdgeTop) == UIRectEdgeNone) {
            BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
            CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
            top += isLandscape? statusBarSize.width:statusBarSize.height;
#if debug
            PJLog(@"~~~statusBarFrame %@",NSStringFromCGRect([[UIApplication sharedApplication] statusBarFrame]));
#endif
            if (self.navigationController) {
#if debug
                PJLog(@"~~~navigationBarFrame %@",NSStringFromCGRect(self.navigationController.navigationBar.frame));
#endif
                top += self.navigationController.navigationBar.frame.size.height;
            }
        }
    }
    
    return top;
}

@end



@implementation AssistanceView

@synthesize assistanceTag;

@end
