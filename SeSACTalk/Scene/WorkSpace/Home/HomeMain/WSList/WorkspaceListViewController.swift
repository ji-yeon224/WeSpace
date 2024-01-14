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
    
    let data = [
        WorkSpace(workspaceId: 1, name: "2222", description: "sssss", thumbnail: "static/workspaceThumbnail/1704906408551.jpeg", ownerId: 1, createdAt: "2024-01-11T02:06:48.570Z"),
        WorkSpace(workspaceId: 1, name: "2222", description: "sssss", thumbnail: "static/workspaceThumbnail/1704906408551.jpeg", ownerId: 1, createdAt: "2024-01-11T02:06:48.570Z")
    ]
    
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
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.viewDisappear()
        print(#function)
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.viewAppear()
    }
    
    private func updateSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, WorkSpace>()
        snapshot.appendSections([""])
        snapshot.appendItems(data)
//        snapshot.appendItems(account, toSection: "계정")
        mainView.dataSource.apply(snapshot)
    }
    
}
