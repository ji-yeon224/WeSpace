//
//  SideMenuVCManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/15/24.
//

import UIKit
import SideMenu

final class SideMenuVCManager {
    
    static let shared = SideMenuVCManager()
    private init() { }
    
    private weak var vc: UIViewController?
    private var listVC: WorkspaceListViewController?
    private var menuVC: SideMenuNavigationController?
    
    
    func initSideMenu(vc: UIViewController, curWS: WorkSpace? = nil) {
        self.vc = vc
        self.listVC = WorkspaceListViewController()
        if let listVC = listVC {
            menuVC = SideMenuNavigationController(rootViewController: listVC)
        }
        
        setupSideMenu()
        listVC?.workspace = curWS
    }
    func setWorkspaceData(ws: WorkSpace? = nil) {
        listVC?.workspace = ws
    }
    
    func presentSideMenu(){
        guard let menuVC = menuVC else { return }
        vc?.present(menuVC, animated: true)
    }
    
    private func setupSideMenu() {
        
        guard let vc = vc else { return }
        guard let menuVC = menuVC else { return }
        
        SideMenuManager.default.leftMenuNavigationController = menuVC
        SideMenuManager.default.addPanGestureToPresent(toView: vc.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: vc.navigationController!.view, forMenu: .left)
        menuVC.statusBarEndAlpha = 0
        menuVC.presentationStyle = .menuSlideIn
        menuVC.enableSwipeToDismissGesture = true
        menuVC.menuWidth = Constants.Design.deviceWidth / 1.3
        menuVC.pushStyle = .default
        menuVC.presentationStyle.menuStartAlpha = 1
        menuVC.presentationStyle.backgroundColor = .alpha
        
        
        
    }
    
    
    
}

