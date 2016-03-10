


#import "AppDelegate.h"
#import "AppDelegate+Logging.h"
#import "IndexViewController.h"
#import "TaskViewController.h"
#import "NewsViewController.h"
#import "PersonalViewController.h"
#import "PrefixHeader.pch"
#import "Reachability.h"
#import "IncomeViewController.h"
#import "ContributeRankViewController.h"
#import "DeviceSimple.h"
#import "NSString+SBJSON.h"
#import "RMMapper.h"
#import "FMDatabase.h"
#import "MineViewController.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "NSString+encrypto.h"
#import "NSString+SBJSON.h"
#import "JSONKit.h"
#import <sys/utsname.h>
#import "MyDataBaseSimple.h"
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#import "SBJsonWriter.h"
#import "UMessage.h"
#import "MessagePushTool.h"
#import "CustomAlertView.h"
#import "SkipViewControllerTool.h"
#import "UniversaLlinkRequest.h"
#import "MessageManagerTool.h"
#import "GuidanceViewController.h"

//#import <AliyunOSSiOS/OSSService.h>
//#import "aliyun-oss-ios-sdk-master/aliyunossios/OSSService.h"

@interface AppDelegate ()
{
    CustomTabBar *_customTab;
    DeviceSimple *_mySimple;
}
@property (nonatomic, strong) UniversaLlinkRequest *linkRequest;
@property (nonatomic, strong) CLLocationManager *locManager;
@end
BMKMapManager *_mapManager;
@implementation AppDelegate
@synthesize conn;
@synthesize userInfo;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initData];
  //  [self beginLocation];
    [UMSocialQQHandler setQQWithAppId:@"1104599082" appKey:@"NmKWHQDmBHM3LMlf" url:@"http://www.sszapp.com/share.html"];
    [UMSocialWechatHandler setWXAppId:@"wx39daf1a09970924d" appSecret:@"d4624c36b6795d1d99dcf0547af5443d" url:@"http://www.sszapp.com/share.html"];
    [UMessage startWithAppkey:AppKey launchOptions:launchOptions];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(SYSTEMVERSION>=8.0)
    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
#else
    
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
    //for log
    [UMessage setLogEnabled:YES];
    [UMessage setBadgeClear:NO];
    //[UMessage setAutoAlert:YES];
    [UMessage setChannel:@"App Store"];
    
    
    
    //打印错误日志
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    _updateDic=[[NSMutableDictionary alloc]init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    IndexViewController *indexCtl=[[IndexViewController alloc]init];
    UINavigationController *indexNavCtl = [[UINavigationController alloc]initWithRootViewController:indexCtl];
    TaskViewController *taskCtl=[[TaskViewController alloc]init];
    UINavigationController *taskNavCtl=[[UINavigationController alloc]initWithRootViewController:taskCtl];
    ContributeRankViewController *contributeRankCtl=[[ContributeRankViewController alloc]init];
    UINavigationController *contributRankNavCtl=[[UINavigationController alloc]initWithRootViewController:contributeRankCtl];
    NewsViewController *newsCtl=[[NewsViewController alloc]init];
    UINavigationController *newNavCtl=[[UINavigationController alloc]initWithRootViewController:newsCtl];
    MineViewController *mineCtl=[[MineViewController alloc]init];
    UINavigationController *mineNavCtl=[[UINavigationController alloc]initWithRootViewController:mineCtl];
    _customTabBar=[[CustomTabBar alloc]init];
    _customTabBar.viewControllers=@[indexNavCtl,taskNavCtl,contributRankNavCtl,newNavCtl,mineNavCtl];
    _customTabBar.selectedIndex = 0;
    
    [UMSocialData setAppKey:AppKey];
    
    GuidanceViewController *guidanceCtl =[[GuidanceViewController alloc]init];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        NSLog(@"第一次启动");
        //  [self initGuide];
        self.window.rootViewController = guidanceCtl;
    }
    else
    {
        NSLog(@"不是第一次启动");
        self.window.rootViewController =_customTabBar;
    }
    
    
    
    AppDelegate *myDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(ScreenHeight >480)
    {
        myDelegate.autoSizeScaleX = ScreenWidth /320;
        myDelegate.autoSizeScaleY = ScreenHeight /568;
    }
    else
    {
        myDelegate.autoSizeScaleX = 1.0;
        myDelegate.autoSizeScaleY = 1.0;
    }
    
    [self initLocation];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch1"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch1"];
    }
    else
    {
        // [self startLocation];
    }
    [self.window makeKeyAndVisible];
    [self takeUserInfoRequest];
    [self startUnReadNewsRequest];
    
    [self setupLogging];
    
    
    // 是否显示过首页弹出活动
    if ([Utility objectInUserDefaultsWithKey:SLICE_ALWAYS_SHOW] || [[Utility objectInUserDefaultsWithKey:SLICE_SHOW_NUM] integerValue] > 0) {
        
        [Utility userDefaultsSaveObject:@"yes" key:SLICE_SHOW_FLAG];
    }
    else {
        if ([Utility isFirstLanch:@"app初次启动显示活动"]) { // 初次启动
            
            [Utility userDefaultsSaveObject:@"yes" key:SLICE_SHOW_FLAG];
        } else
        {
            
            [Utility userDefaultsSaveObject:@"no" key:SLICE_SHOW_FLAG];
            
        }
    }
    
    //处理消息推送
    /** app进程被杀死后，启动app获取推送消息 */
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        NSDictionary *myDic =[[[userInfo  objectForKey:@"aps"]objectForKey:@"content-available"]JSONValue];
        _customTab =(CustomTabBar *) self.window.rootViewController;
        //隐藏底部视图
        _customTab.imgView.hidden = YES;
        UINavigationController *controller = [_customTabBar.viewControllers objectAtIndex:_customTab.currentSelectedIndex];
        [SkipViewControllerTool handleSkipDictionary:myDic viewController:[controller.viewControllers objectAtIndex:0]];
        //[MessageManagerTool updateServieMessage:1];//消息减1
    }
    
    // 定位
    [self locationManagerEnabled];
    [self startUpgradeRequest];
    return YES;
}

void uncaughtExceptionHandler(NSException*exception){
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}
-(void)initData
{
    _mySimple =[DeviceSimple sharedDeviceData];
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    _mySimple.hostId = [userDefaults objectForKey:@"hostId"];
    _mySimple.serUrl  =[userDefaults objectForKey:@"serUrl"];
    _mySimple.httpHeader  =[userDefaults objectForKey:@"httpHeader"];
    if([userDefaults objectForKey:@"hostId"] == nil)
    {
        _mySimple.hostId = @"8443";
    }
    if([userDefaults objectForKey:@"serUrl"] == nil)
    {
        _mySimple.serUrl = @"prod";
    }
    if([userDefaults objectForKey:@"httpHeader"] == nil)
    {
        _mySimple.httpHeader = @"https";
    }
}
-(void)beginLocation
{
    _locService = [[BMKLocationService alloc]init];
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _locService.delegate = self;
    [_locService startUserLocationService];
}
-(void)startLocation
{
    
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways )
    {
    }
    else if ([CLLocationManager locationServicesEnabled] &&
             [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse )
    {
    }
    else
    {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"打开定位开关" message:@"无法正常定位,请到设置>隐私>定位服务中开启定位服务,并请允许【随手赚】使用定位服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 100;
        [alert show];
    }
}

- (UIViewController *)activityViewController
{
    UIViewController* activityViewController = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows)
        {
            if(tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0)
    {
        UIView *frontView = [viewsArray objectAtIndex:0];
        
        id nextResponder = [frontView nextResponder];
        
        if([nextResponder isKindOfClass:[UIViewController class]])
        {
            activityViewController = nextResponder;
        }
        else
        {
            activityViewController = window.rootViewController;
        }
    }
    
    return activityViewController;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if(alertView.tag == 100)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                
            }
                break;
            case 1:
            {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
                
            }
                break;
        }
    }
    
    else if(alertView.tag == 300)
    {
        [UMessage sendClickReportForRemoteNotification:userInfo];
        
        NSDictionary *myDic =[[[userInfo  objectForKey:@"aps"]objectForKey:@"content-available"]JSONValue];
        switch (buttonIndex) {
            case 0:
            {
                return;
            }
                break;
            case 1:
            {
                //服务消息数量减1
                //[MessageManagerTool updateServieMessage:1];
                _customTab =(CustomTabBar *) self.window.rootViewController;
                //隐藏底部视图
                _customTab.imgView.hidden = YES;
                NSLog(@"index is %@", @(_customTab.currentSelectedIndex));
                UINavigationController *controller = [_customTabBar.viewControllers objectAtIndex:_customTab.currentSelectedIndex];
                [SkipViewControllerTool handleSkipDictionary:myDic viewController:[controller.viewControllers objectAtIndex:0]];
                
            }
        }
    }
    else
    {
        
        switch (buttonIndex) {
            case 0:
            {
                
            }
                break;
            case 1:
            {
                NSString *str = [NSString stringWithFormat:@"%@",[[_updateDic objectForKey:@"result"]objectForKey:@"versionUrl"]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                
            }
                break;
            default:
                break;
                
        }
    }
}
-(void)startUpgradeRequest
{
    DeviceSimple *simple=[DeviceSimple sharedDeviceData];
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSMutableString *verSionStr =[NSMutableString stringWithFormat:@"%@",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
    [parm setObject:verSionStr forKey:@"appVersion"];
    verSionStr = (NSMutableString *)[verSionStr stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    NSString *str=[NSString stringWithFormat:@"%@base/checkNewVersion/1/%@",[NSString stringWithFormat:@"%@://%@.sszapp.com:%@/VegaWeb/app/",simple.httpHeader,simple.serUrl,simple.hostId],verSionStr];
    str = [str stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
    MyDataBaseSimple *dataBase =[MyDataBaseSimple sharedDataBase];
    NSString *sszId =[dataBase selectSSZidFromDataBase:dataBase];
    NSLog(@"sszId is %@",sszId);
    if(![sszId isEqualToString:@""])
    {
        [parm setObject:sszId forKey:@"sszID"];
    }
    [parm setObject:[self getMobileBrand] forKey:@"mobileBrand"];
    [parm setObject:[self getMobileType] forKey:@"mobileType"];
    [parm setObject:[self getSystemVersion] forKey:@"systemVersion"];
    [parm setObject:[self getMobileIdentification] forKey:@"mobileIdentification"];
    if(simple.longitude.length != 0)
    {
        [parm setObject:simple.longitude forKey:@"lng"];
    }
    if(simple.longitude.length != 0)
    {
        [parm setObject:simple.latitude forKey:@"lat"];
    }
    [parm setObject:@"App store" forKey:@"channelName"];
    if ([NSJSONSerialization isValidJSONObject:parm])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parm options:NSJSONWritingPrettyPrinted error: &error];
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        NSURL *url = [NSURL URLWithString:str];
        _upgradeRequest = [ASIHTTPRequest requestWithURL:url];
        [_upgradeRequest addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [_upgradeRequest addRequestHeader:@"Accept" value:@"application/json"];
        [_upgradeRequest setRequestMethod:@"POST"];
        [_upgradeRequest setPostBody:tempJsonData];
        _upgradeRequest.useCookiePersistence = YES;
        _upgradeRequest.useSessionPersistence = YES;
        [_upgradeRequest startSynchronous];
        NSError *error1 = [_upgradeRequest error];
        if (!error1)
        {
            NSData *jsonData =[_upgradeRequest responseData];
            NSString *jsonStr=[[NSString alloc]initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            NSDictionary *dic=[jsonStr JSONValue];
            NSLog(@"新的用户版本更新接口 dic is %@",dic);
        }
    }
    
    
    
}
-(void)addGuider
{
    
}
-(void)initLocation
{
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"MsnGzKnsmOcKAoHI02e8xTsh" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [BMKMapView willBackGround];
    
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DeviceSimple *simple=[DeviceSimple sharedDeviceData];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:simple.mobilePhone forKey:@"lastMobile"];
    [userDefaults setObject:simple.userPwd forKey:@"lastPwd"];
    [userDefaults synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"进入前台");
    
    //_customTabBar.imgView.hidden = NO;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshMainView" object:nil];
    
    
    
    [self takeUserInfoRequest];
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch1"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch1"];
        NSLog(@"第一次启动");
    }
    else
    {
        //2月16号修改
        // [self startLocation];
        NSLog(@"不是第一次启动");
    }
    
    // 定位
    [self locationManagerEnabled];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _customTabBar.view.frame = KEY_WINDOW.frame;
    NSLog(@"applicationDidBecomeActive");
    [BMKMapView didForeGround];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"deviceToken is %@",deviceToken);
    [UMessage registerDeviceToken:deviceToken];
}

//didReceiveRemoteNotification中设置
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    self.userInfo = userInfo;
    
    //在前台显示消息推送的对话框
    if (application.applicationState == UIApplicationStateActive) {
        NSString *title =[[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息"
                                                         message:title
                                                        delegate:self
                                               cancelButtonTitle:@"忽略"
                                               otherButtonTitles:@"查看", nil];
        alert.tag = 300;
        [alert show];
    } else {
        //后台点击直接进入对应的界面
        if (userInfo != nil) {
            NSDictionary *myDic =[[[userInfo  objectForKey:@"aps"]objectForKey:@"content-available"]JSONValue];
            _customTab =(CustomTabBar *) self.window.rootViewController;
            //隐藏底部视图
            _customTab.imgView.hidden = YES;
            NSLog(@"index is %@", @(_customTab.currentSelectedIndex));
            UINavigationController *controller = [_customTabBar.viewControllers objectAtIndex:_customTab.currentSelectedIndex];
            [SkipViewControllerTool handleSkipDictionary:myDic viewController:[controller.viewControllers objectAtIndex:0]];
        }
        
    }
    
    //消息数量加1
    [MessageManagerTool updaePushMessageNumber];
    
}


-(void)startUnReadNewsRequest
{
    NSString *str=[NSString stringWithFormat:@"%@/message/unread",[NSString stringWithFormat:@"%@://%@.sszapp.com:%@/VegaWeb/app/",_mySimple.httpHeader,_mySimple.serUrl,_mySimple.hostId]];
    str = [str stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
    _unreadNewsRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:str]];
    [_unreadNewsRequest addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    _unreadNewsRequest.delegate = self;
    [_unreadNewsRequest startAsynchronous];
    
}
-(void)loginAutomatic
{
    
    DeviceSimple *simple =[DeviceSimple sharedDeviceData];
    NSMutableDictionary *bigParm =[[NSMutableDictionary alloc]init];
    [bigParm setObject:[self getMobileBrand] forKey:@"mobileBrand"];
    [bigParm setObject:[self getMobileType] forKey:@"mobileType"];
    [bigParm setObject:[self getSystemVersion] forKey:@"systemVersion"];
    [bigParm setObject:[self getMobileIdentification] forKey:@"mobileIdentification"];
    [bigParm setObject:[self getAppVersion] forKey:@"appVersion"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *mobileStr = [defaults objectForKey:@"mobile"];
    NSString *pwdStr = [defaults objectForKey:@"pwd"];
    if(mobileStr!=nil && pwdStr !=nil)
    {
        NSString *str=[NSString stringWithFormat:@"%@user/login",[NSString stringWithFormat:@"%@://%@.sszapp.com:%@/VegaWeb/app/",_mySimple.httpHeader,_mySimple.serUrl,_mySimple.hostId]];
        str = [str stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
        NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
        [parm setObject:mobileStr forKey:@"userName"];
        [parm setObject:[pwdStr sha1_base64]  forKey:@"password"];
        [parm setObject:bigParm forKey:@"userClientInfo"];
        if ([NSJSONSerialization isValidJSONObject:parm])
        {
            NSString *myJsonString = nil;
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parm options:NSJSONWritingPrettyPrinted error: &error];
            myJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
            NSURL *url = [NSURL URLWithString:str];
            _loginRequest = [ASIHTTPRequest requestWithURL:url];
            [_loginRequest addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
            [_loginRequest addRequestHeader:@"Accept" value:@"application/json"];
            [_loginRequest setRequestMethod:@"POST"];
            [_loginRequest setPostBody:tempJsonData];
            _loginRequest.useCookiePersistence = YES;
            [_loginRequest startSynchronous];
            NSError *error1 = [_loginRequest error];
            if (!error1)
            {
                NSData *jsonData =[_loginRequest responseData];
                NSString *jsonStr=[[NSString alloc]initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
                NSDictionary *dic=[jsonStr JSONValue];
                if((NSNull *)[dic objectForKey:@"result"]==[NSNull null])
                {
                    return;
                }
                UIApplication *app=[UIApplication  sharedApplication];
                AppDelegate *delegate=(AppDelegate *)[app delegate];
                _customTab =(CustomTabBar *) delegate.window.rootViewController;
                if([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"] objectForKey:@"newMsgNum"]]isEqualToString:@"0"])
                {
                    _customTab.unreadNumView.hidden = YES;
                }
                else
                {
                    _customTab.unreadNumView.hidden = NO;
                    _customTab.unreadLbl.text=[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"]objectForKey:@"newMsgNum"]];
                }
                
                LoginUser *user =[RMMapper objectWithClass:[LoginUser class] fromDictionary: [dic objectForKey:@"result"]];
                
                simple.loginUer = user;
                if([[NSString stringWithFormat:@"%@",[dic objectForKey:@"success"]]isEqualToString:@"1"])
                {
                    // [self.navigationController popViewControllerAnimated:YES];
                }
                
            }
        }
    }
}
-(void)takeUserInfoRequest
{
    DeviceSimple *simple =[DeviceSimple sharedDeviceData];
    NSString *str=[NSString stringWithFormat:@"%@user/userInfoBysszId",[NSString stringWithFormat:@"%@://%@.sszapp.com:%@/VegaWeb/app/",_mySimple.httpHeader,_mySimple.serUrl,_mySimple.hostId]];
    str = [str stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)];
    NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
    if ([NSJSONSerialization isValidJSONObject:parm])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parm options:NSJSONWritingPrettyPrinted error: &error];
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        NSURL *url = [NSURL URLWithString:str];
        MyDataBaseSimple *dataBase =[MyDataBaseSimple sharedDataBase];
        NSString *sszId =[dataBase selectSSZidFromDataBase:dataBase];
        _takeUserInfoRequest = [ASIHTTPRequest requestWithURL:url];
        [_takeUserInfoRequest addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [_takeUserInfoRequest addRequestHeader:@"Accept" value:@"application/json"];
        [_takeUserInfoRequest setRequestMethod:@"POST"];
        [_takeUserInfoRequest setPostBody:tempJsonData];
        _takeUserInfoRequest.useCookiePersistence = YES;
        _takeUserInfoRequest.useSessionPersistence = YES;
        
        NSMutableDictionary *properties =[[NSMutableDictionary alloc]init];
        [properties setValue:sszId forKey:NSHTTPCookieValue];
        [properties setValue:@"SSZID" forKey:NSHTTPCookieName];
        [properties setValue:COOKIEURL forKey:NSHTTPCookieDomain];
        [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
        [properties setValue:@"/" forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        
        
        [_takeUserInfoRequest startSynchronous];
        NSError *error1 = [_takeUserInfoRequest error];
        if (!error1)
        {
            NSData *jsonData =[_takeUserInfoRequest responseData];
            NSString *jsonStr=[[NSString alloc]initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            NSDictionary *dic=[jsonStr JSONValue];
            //  NSLog(@"得到的信息是  dic is %@",dic);
            if([[NSString stringWithFormat:@"%@",[dic objectForKey:@"code"]]isEqualToString:@"10000"])
            {
                return;
            }
            
            if([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"] objectForKey:@"newMsgNum"]]isEqualToString:@"0"])
            {
                _customTabBar.unreadNumView.hidden = YES;
            }
            else
            {   _customTabBar.unreadNumView.hidden = NO;
                _customTabBar.unreadLbl.text=[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"]objectForKey:@"newMsgNum"]];
            }
            
            MyDataBaseSimple *dataBase =[MyDataBaseSimple sharedDataBase];
            
            NSMutableDictionary  *mySmallDic = [dic objectForKey:@"result"];
            NSMutableDictionary *objDic = [[NSMutableDictionary alloc]init];
            for(int i =0;i<mySmallDic.allKeys.count;i++)
            {
                NSString *str =[NSString stringWithFormat:@"%@", [mySmallDic objectForKey:[mySmallDic.allKeys objectAtIndex:i]]];
                //  NSLog(@"%@  is  str is %@",[mySmallDic.allKeys objectAtIndex:i],str);
                [objDic setObject:str forKey:[mySmallDic.allKeys objectAtIndex:i]];
            }
            //先删除旧的信息
            [dataBase deleteUserSimple:[dataBase selectUserFromDataBase]];
            
            LoginUser *user = [[LoginUser alloc]init];
            user  =[RMMapper objectWithClass:[LoginUser class] fromDictionary: objDic];
            simple.loginUer = user;
            [dataBase insertUserSimple:user];
        }
        
    }
}
- (void)applicationWillTerminate:(UIApplication *)application
{
}
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError)
    {
        NSLog(@"联网成功");
    }
    else
    {
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}
- (void)onGetPermissionState:(int)iError
{
    if (0 == iError)
    {
        NSLog(@"授权成功");
    }
    else
    {
        NSLog(@"onGetPermissionState %d",iError);
    }
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url.description hasPrefix:@"sszapp"]) {
        
        NSString *code = [[url query] substringFromIndex:[[url query] rangeOfString:@"id="].location + 3];
        NSString *param = [NSString stringWithFormat:@"{paramConf(id:%@)}",code];
        NSString *str = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                              (CFStringRef)param,
                                                                                              nil,
                                                                                              (CFStringRef)@"!*'();:@&=+$,?%#[]",
                                                                                              kCFStringEncodingUTF8));
        
        NSString *strURL =[NSString stringWithFormat:@"%@://%@.sszapp.com:%@/VegaWeb/app/graphql/wVegaGraphQL/%@",@"https",@"prod",@"8443",str];
        UniversaLlinkRequest *linkRequest = [[UniversaLlinkRequest alloc] init];
        self.linkRequest = linkRequest;
        [self.linkRequest requestWithURL:strURL
                              httpMethod:nil
                                  params:nil
                                 timeout:30
                    useCookiePersistence:YES
                   useSessionPersistence:YES
                                   https:YES];
        
        return YES;
    } else {
        return  [UMSocialSnsService handleOpenURL:url];
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    NSLog(@"continueUserActiity enter");
    NSLog(@"userActivity.activityType         : %@", userActivity.activityType);
    NSLog(@"\tURL         : %@", userActivity.webpageURL);
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSString *code = [[userActivity.webpageURL query] substringFromIndex:[[userActivity.webpageURL query] rangeOfString:@"id="].location + 3];
        NSLog(@"code : %@", code);
        NSString *param = [NSString stringWithFormat:@"{paramConf(id:%@)}",code];
        NSString *str = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                              (CFStringRef)param,
                                                                                              nil,
                                                                                              (CFStringRef)@"!*'();:@&=+$,?%#[]",
                                                                                              kCFStringEncodingUTF8));
        
        NSString *strURL =[NSString stringWithFormat:@"%@://%@.sszapp.com:%@/VegaWeb/app/graphql/wVegaGraphQL/%@",@"https",@"prod",@"8443",str];
        UniversaLlinkRequest *linkRequest = [[UniversaLlinkRequest alloc] init];
        self.linkRequest = linkRequest;
        [self.linkRequest requestWithURL:strURL
                              httpMethod:nil
                                  params:nil
                                 timeout:30
                    useCookiePersistence:YES
                   useSessionPersistence:YES
                                   https:YES];
    }
    return YES;
}

//firstLaunch action
-(void)firstLaunch
{
    UIAlertView *firstAlert = [[UIAlertView alloc] initWithTitle:@"向导" message:@"第一次连接" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看帮助", nil];
    [firstAlert show];
}
-(void)dealloc
{
    _loginRequest = nil;
    _unreadNewsRequest = nil;
}
#pragma mark - AsiHttpRequestDelegate
- (void) requestFinished:(ASIHTTPRequest *)request
{
    
    NSData *jsonData =[request responseData];
    NSString *jsonStr=[[NSString alloc]initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSDictionary *dic=[jsonStr JSONValue];
    if((NSNull *) [dic objectForKey:@"result"] == [NSNull null]  || [[NSString stringWithFormat:@"%@",[dic objectForKey:@"result"]] isEqualToString:@"<null>"])
    {
        return;
    }
    if(request==_unreadNewsRequest)
    {
    }
    if(request == _upgradeRequest)
    {
        //  NSLog(@"检查版本的结果是 %@",dic);
        _updateDic=[[NSMutableDictionary alloc]initWithDictionary:dic];
        if([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"]objectForKey:@"newVersion"]]isEqualToString:@"1"])
        {
            if([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"]objectForKey:@"forceUpgrade"]]isEqualToString:@"1"])
            {
                NSMutableString *str= [NSMutableString stringWithFormat:@"      "];
                NSArray *arr =[[dic objectForKey:@"result"]objectForKey:@"versionDesc"];
                for(int i=0;i<arr.count;i++)
                {
                    [str appendString:[NSString stringWithFormat:@"%@\n      ",[arr objectAtIndex:i]]];
                }
                
                
                NSString *titleStr=[NSString stringWithFormat:@"最新版本V%@",[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"]objectForKey:@"versionName"]]];
                CustomAlertView *alertView=[[CustomAlertView alloc]initWithTitle:titleStr message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"下载", nil];
                alertView.tag = 201;
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
                {
                    CGSize size =[str boundingRectWithSize:CGSizeMake(220, 400) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
                    
                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20,240, size.height)];
                    textLabel.font = APPFONT(14);
                    textLabel.textColor = [UIColor blackColor];
                    textLabel.backgroundColor = [UIColor clearColor];
                    textLabel.lineBreakMode =NSLineBreakByWordWrapping;
                    textLabel.numberOfLines =0;
                    textLabel.textAlignment =NSTextAlignmentLeft;
                    textLabel.text = str;
                    [alertView setValue:textLabel forKey:@"accessoryView"];
                    alertView.message =@"";
                    
                }
                else{
                    NSInteger count = 0;
                    for( UIView * view in alertView.subviews )
                    {
                        if( [view isKindOfClass:[UILabel class]] )
                        {
                            count ++;
                            if ( count == 2 ) { //仅对message左对齐
                                UILabel* label = (UILabel*) view;
                                label.textAlignment =NSTextAlignmentLeft;
                            }
                        }
                    }
                }
                
                [alertView show];
                return;
            }
            else if([[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"]objectForKey:@"forceUpgrade"]]isEqualToString:@"0"])
            {
                NSMutableString *str= [NSMutableString stringWithFormat:@"      "];
                NSArray *arr =[[dic objectForKey:@"result"]objectForKey:@"versionDesc"];
                for(int i=0;i<arr.count;i++)
                {
                    [str appendString:[NSString stringWithFormat:@"%@\n      ",[arr objectAtIndex:i]]];
                }
                NSString *titleStr=[NSString stringWithFormat:@"最新版本V%@",[NSString stringWithFormat:@"%@",[[dic objectForKey:@"result"]objectForKey:@"versionName"]]];
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:titleStr message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
                alertView.tag = 200;
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
                {
                    CGSize size =[str boundingRectWithSize:CGSizeMake(220, 400) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
                    
                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20,240, size.height)];
                    textLabel.font = APPFONT(14);
                    textLabel.textColor = [UIColor blackColor];
                    textLabel.backgroundColor = [UIColor clearColor];
                    textLabel.lineBreakMode =NSLineBreakByWordWrapping;
                    textLabel.numberOfLines =0;
                    textLabel.textAlignment =NSTextAlignmentLeft;
                    textLabel.text = str;
                    [alertView setValue:textLabel forKey:@"accessoryView"];
                    alertView.message =@"";
                    
                }
                else{
                    NSInteger count = 0;
                    for( UIView * view in alertView.subviews )
                    {
                        if( [view isKindOfClass:[UILabel class]] )
                        {
                            count ++;
                            if ( count == 2 ) { //仅对message左对齐
                                UILabel* label = (UILabel*) view;
                                label.textAlignment =NSTextAlignmentLeft;
                            }
                        }
                    }
                }
                
                [alertView show];
                return;
            }
        }
    }
}
-(NSString*) getMobileIdentification {
    NSString *deviceID;
    UIDevice *device = [UIDevice currentDevice];//创建设备对象
    NSUUID *UUID = [device identifierForVendor];
    deviceID = [UUID UUIDString];
    deviceID = [deviceID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    // [deviceID sha1_base64];
    return [deviceID sha1_base64];
}
-(NSString *)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appCurVersionNum;
}
-(NSString *)getSystemVersion
{
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    return phoneVersion;
}
-(NSString *)getMobileBrand
{
    NSString* phoneModel = [[UIDevice currentDevice] model];
    return phoneModel;
}
-(NSString *)getMobileType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform =[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

#pragma mark - 定位

- (BOOL)locationManagerEnabled {
    //    NSLog(@"定位   locationServicesEnabled：%d authorizationStatus:%d",[CLLocationManager locationServicesEnabled],[CLLocationManager authorizationStatus]);
    
    BOOL enabled = NO;
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
            CLLocationManager *locManager = [[CLLocationManager alloc] init];
            locManager.delegate = self;
            self.locManager = locManager;
            locManager.distanceFilter = kCLLocationAccuracyThreeKilometers;
            locManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            //调用请求：
            if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
            {
                //设置定位权限 仅ios8有意义
                [self.locManager requestWhenInUseAuthorization];// 前台定位
            }
            [self.locManager startUpdatingLocation];
            NSLog(@"用户允许定位");
            enabled = YES;
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            
            /** 清除定位信息 */
            DeviceSimple *simple=[DeviceSimple sharedDeviceData];
            simple.longitude = [NSString stringWithFormat:@"0"];
            simple.latitude = [NSString stringWithFormat:@"0"];
            simple.city = [NSString stringWithFormat:@"_ _ _ _ _"];
            NSLog(@"用户不允许定位");
        }
    
    return enabled;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    // 获取当前所在的城市名
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //根据经纬度反向地理编译出地址信息
    
    __block  NSString *location ;
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error) {
         
         if (array.count > 0) {
             
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             location = [NSString stringWithFormat:@"name:%@\n thoroughfare:%@\n subThoroughfare:%@\n locality:%@\n subLocality:%@\n administrativeArea:%@\n subAdministrativeArea:%@\n postalCode:%@\n ISOcountryCode:%@\n country:%@\n inlandWater:%@\n ocean:%@\n areasOfInterest:%@\n  经纬度：%f-%f",placemark.name,placemark.thoroughfare,placemark.subThoroughfare,placemark.locality,placemark.subLocality,placemark.administrativeArea,placemark.subAdministrativeArea,placemark.postalCode,placemark.ISOcountryCode,placemark.country,placemark.inlandWater,placemark.ocean,placemark.areasOfInterest,currentLocation.coordinate.longitude,currentLocation.coordinate.latitude];
             NSLog(@"当前位置:%@",location);
             /** 记录定位信息 */
             DeviceSimple *simple=[DeviceSimple sharedDeviceData];
             simple.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
             simple.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
             simple.city = [NSString stringWithFormat:@"%@",placemark.locality];
             
             /** 只定位一次 */
             [self.locManager stopUpdatingLocation];
         }
         else if (error == nil && [array count] == 0) {
             location = @"No results were returned.";
             DeviceSimple *simple=[DeviceSimple sharedDeviceData];
             simple.longitude = [NSString stringWithFormat:@"0"];
             simple.latitude = [NSString stringWithFormat:@"0"];
             simple.city = [NSString stringWithFormat:@"_ _ _ _ _"];
         }
         else if (error != nil) {
             location = @"An error occurred";
             DeviceSimple *simple=[DeviceSimple sharedDeviceData];
             simple.longitude = [NSString stringWithFormat:@"0"];
             simple.latitude = [NSString stringWithFormat:@"0"];
             simple.city = [NSString stringWithFormat:@"_ _ _ _ _"];
         }
         
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    /** 清除定位信息 */
    DeviceSimple *simple=[DeviceSimple sharedDeviceData];
    simple.longitude = [NSString stringWithFormat:@"0"];
    simple.latitude = [NSString stringWithFormat:@"0"];
    simple.city = [NSString stringWithFormat:@"_ _ _ _ _"];
    
    if(error.code == kCLErrorLocationUnknown)
    {
        NSLog(@"Currently unable to retrieve location.");
    }
    else if(error.code == kCLErrorNetwork)
    {
        NSLog(@"Network used to retrieve location is unavailable.");
    }
    else if(error.code == kCLErrorDenied)
    {
        NSLog(@"Permission to retrieve location is denied.");
        [manager stopUpdatingLocation];
    }
}
@end
