//
//  HomeTabBarController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit

final class HomeTabBarController: UITabBarController {
    
    private var channelPush: Bool = false
    private var dmPush: Bool = false
    
    init(workspace: WorkSpace, type: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        var defaultTab = 0
        if type == "dm" {
            defaultTab = 1
            dmPush = true
        } else {
            defaultTab = 0
            channelPush = true
            
        }
        
        setTabBar(ws: workspace)
        self.selectedIndex = defaultTab
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        tabBar.barTintColor = Constants.Color.background
        tabBar.tintColor = Constants.Color.basicText
        tabBar.unselectedItemTintColor = Constants.Color.inActive
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = Constants.Color.seperator?.cgColor
        
    }
    
    private func setTabBar(ws: WorkSpace) {
        
        let home = HomeViewController(workspace: ws, push: channelPush)
        home.tabBarItem.image = .home
        home.tabBarItem.selectedImage = .homeActive
        home.tabBarItem.title = "홈"
        let homeNav = UINavigationController(rootViewController: home)
        
        let dm = DMListViewController(workspace: ws, push: dmPush)
        dm.tabBarItem.image = .message
        dm.tabBarItem.selectedImage = .messageActive
        dm.tabBarItem.title = "DM"
        let dmNav = UINavigationController(rootViewController: dm)
        
        let search = SearchViewController()
        search.tabBarItem.image = .search
        search.tabBarItem.selectedImage = .searchActive
        search.tabBarItem.title = "검색"
        let searchNav = UINavigationController(rootViewController: search)
        
        let info = InfoViewController()
        info.tabBarItem.image = .setting
        info.tabBarItem.selectedImage = .settingActive
        info.tabBarItem.title = "설정"
//        let infoNav = UINavigationController(rootViewController: info)
        
        viewControllers = [homeNav, dmNav, searchNav, info]
        
    }
}

