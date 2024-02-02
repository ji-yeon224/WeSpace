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

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        UIApplication.shared.registerForRemoteNotifications()
        KakaoSDK.initSDK(appKey: APIKey.kakaokey)
        
        FirebaseApp.configure()
                
                
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        
        Messaging.messaging().delegate = self
        
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
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return false
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //print("Firebase registration token: \(String(describing: fcmToken))")
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
//            print("FCM registration token: \(token)")
              UserDefaultsManager.deviceToken = token 
          }
        }
//        let dataDict: [String: String] = ["token": fcmToken ?? ""]
//        NotificationCenter.default.post(
//            name: Notification.Name("FCMToken"),
//            object: nil,
//            userInfo: dataDict
//        )
//        print("FCM ", fcmToken)
//        UserDefaultsManager.deviceToken = fcmToken ?? ""
        
        
        
    }
}
