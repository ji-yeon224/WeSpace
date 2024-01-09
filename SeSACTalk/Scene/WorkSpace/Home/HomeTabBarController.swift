//
//  HomeTabBarController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class HomeTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = Constants.Color.background
        tabBar.tintColor = Constants.Color.mainColor
        tabBar.unselectedItemTintColor = Constants.Color.basicText
        setTabBar()
        
    }
    
    private func setTabBar() {
        
        let home = HomeViewController()
        home.tabBarItem.image = .home
        home.tabBarItem.selectedImage = .homeActive
//        boardVC.tabBarItem.title = "Board"
        let homeNav = UINavigationController(rootViewController: home)
        
       
        
        viewControllers = [home]
        
    }
}

