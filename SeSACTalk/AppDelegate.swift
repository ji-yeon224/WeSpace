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
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        //        UIApplication.shared.registerForRemoteNotifications()
        KakaoSDK.initSDK(appKey: APIKey.kakaokey)
        
        FirebaseApp.configure()
        
        
        UNUserNotificationCenter.current().delegate = self // 알림 허용 권한 확인
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        
        Messaging.messaging().delegate = self
        
        // 등록된 토큰 가져오기
        //        Messaging.messaging().token { token, error in
        //          if let error = error {
        //            print("Error fetching FCM registration token: \(error)")
        //          } else if let token = token {
        //            print("88FCM registration token: \(token)")
        //              UserDefaultsManager.deviceToken = token
        //              DeviceTokenManager.shared.requestSaveDeviceToken(token: token)
        //          }
        //        }
        
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
        
        //        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Messaging.messaging().apnsToken = deviceToken
        //        print(token)
        //        UserDefaultsManager.deviceToken = token
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.list, .banner])
//        print(notification.request.content.userInfo)
        
        guard let responseInfo = notification.request.content.userInfo as? Dictionary<String, Any> else {
            return
        }
        
        var data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: responseInfo)
        } catch {
            print("decode error")
        }
        
        if let type = responseInfo["type"] as? String {
            if type == "channel" {
                if let data = data {
                    do {
                        let jsonData = try JSONDecoder().decode(ChannelPushDTO.self, from: data)
                        print(jsonData)
                    } catch {
                        print("error", error)
                    }
                }
            } else if type == "dm" {
                if let data = data {
                    do {
                        let jsonData = try JSONDecoder().decode(DmPushDTO.self, from: data)
                        print(jsonData)
                    } catch {
                        print("error", error)
                    }
                }
            }
        }
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        //        print(response.notification.request.content.userInfo)
        
        
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
        //        print("Firebase registration token: \(String(describing: fcmToken))")
        print(#function)
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
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
        //        print("FCM ", fcmToken)
        //        UserDefaultsManager.deviceToken = fcmToken ?? ""
        
        
        
    }
}
