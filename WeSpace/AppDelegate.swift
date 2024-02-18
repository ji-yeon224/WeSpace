//
//  AppDelegate.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit
import IQKeyboardManagerSwift
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore
import FirebaseMessaging
import Firebase
import iamport_ios

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let unNotification = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        //        UIApplication.shared.registerForRemoteNotifications()
        KakaoSDK.initSDK(appKey: APIKey.kakaokey)
        
        FirebaseApp.configure()
        
        
        unNotification.delegate = self // 알림 허용 권한 확인
        unNotification.removeAllDeliveredNotifications()
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        
        Messaging.messaging().delegate = self
        
        UserDefaultsManager.setInitChatId()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // foreground push noti
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
//        print(notification.request.content.userInfo)
        
        guard let responseInfo = notification.request.content.userInfo as? Dictionary<String, Any> else {
            return
        }
        
        if let type = responseInfo["type"] as? String {
            if type == "channel" {
                if let id = responseInfo["channel_id"] as? String, let channelId = Int(id) {
                    if UserDefaultsManager.channelId != channelId {
                        completionHandler([.list, .banner, .badge])
                        unNotification.removeAllDeliveredNotifications() // 포그라운드 시 쌓이지 않게
                    }
                }
               
            } else if type == "dm" {
                if let id = responseInfo["room_id"] as? String , let dmId = Int(id) {
                    if UserDefaultsManager.dmId != dmId {
                        completionHandler([.list, .banner, .badge])
                        unNotification.removeAllDeliveredNotifications() // 포그라운드 시 쌓이지 않게
                    }
                }
                
            }
        }
        
        
    }
    
    // 푸시 클릭해서 들어옴
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // 푸시 클릭해서 들어올 때 제거
        unNotification.removeAllDeliveredNotifications()
        guard let responseInfo = response.notification.request.content.userInfo as? Dictionary<String, Any> else {
            return
        }
        
        var data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: responseInfo)
        } catch {
            print("decode error")
        }
        
        if let data = data {
            PushNotiCoordinator.shared.configPushNotiTabAction(responseInfo: data)
        }
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        Iamport.shared.receivedURL(url)
        return false
    }
}

extension AppDelegate: MessagingDelegate {
    
    // 토큰 갱신 모니터링
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                UserDefaultsManager.deviceToken = token
                if UserDefaultsManager.isLogin {
                    DeviceTokenManager.shared.requestSaveDeviceToken(token: token)
                }
                
            }
        }
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}
