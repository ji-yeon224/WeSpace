//
//  SceneDelegate.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit
import KakaoSDKAuth
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var disposeBag = DisposeBag()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        if UserDefaultsManager.isLogin && UserDefaultsManager.refreshTokenExpire > Date() {
            
            EnterViewControllerMananger.shared.fetchWorkspace()
                .asObservable()
                .bind(with: self, onNext: { owner, vc in
//                    print(vc)
                    SideMenuVCManager.shared.initSideMenu()
                    owner.window?.rootViewController = vc
                    owner.window?.makeKeyAndVisible()
                })
                .disposed(by: EnterViewControllerMananger.shared.disposeBag)
        } else {
            UserDefaultsManager.initToken()
            window?.rootViewController = OnBoardingViewController()
            window?.makeKeyAndVisible()
        }
        
       
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        if SocketNetworkManager.shared.isConnected {
            SocketNetworkManager.shared.disconnect()
        }
        UserDefaultsManager.setInitChatId()
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        // 중단된게 있다면 다시 연결
        SocketNetworkManager.shared.reconnect()
        
        //앱 진입 시 쌓인 알림 스택 제거
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // 연결된게 있다면 중단
        SocketNetworkManager.shared.pauseConnect()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
    
    
}

