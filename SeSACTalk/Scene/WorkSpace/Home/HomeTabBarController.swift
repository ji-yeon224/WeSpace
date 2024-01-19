//
//  HomeTabBarController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class HomeTabBarController: UITabBarController {
    
    init(workspace: WorkSpace) {
        super.init(nibName: nil, bundle: nil)
        setTabBar(ws: workspace)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = Constants.Color.background
        tabBar.tintColor = Constants.Color.basicText
        tabBar.unselectedItemTintColor = Constants.Color.basicText
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = Constants.Color.seperator?.cgColor
        
    }
    
    private func setTabBar(ws: WorkSpace) {
        
        let home = HomeViewController(workspace: ws)
        home.tabBarItem.image = .home
        home.tabBarItem.selectedImage = .homeActive
        let homeNav = UINavigationController(rootViewController: home)
        
        let info = InfoViewController()
        info.tabBarItem.title = "info"
        
        viewControllers = [homeNav, info]
        
    }
}

