//
//  WorkspaceListViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/13/24.
//

import UIKit
import SideMenu
import RxGesture

final class WorkspaceListViewController: BaseViewController {
    
    var workspaceData: [WorkSpace] = []
    
    
    private let mainView = WorkspaceListView()
    weak var delegate: WorkSpaceListDelegate?
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
        updateSnapShot()
        mainView.showWorkspaceList(show: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .isSideVCAppear, object: nil, userInfo: ["show": false])
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .isSideVCAppear, object: nil, userInfo: ["show": true])
    }
    
    private func updateSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, WorkSpace>()
        snapshot.appendSections([""])
        snapshot.appendItems(workspaceData)
        mainView.dataSource.apply(snapshot)
    }
    
}
