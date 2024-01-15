//
//  WorkspaceListViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/13/24.
//

import UIKit
import SideMenu
import RxSwift
import RxGesture

final class WorkspaceListViewController: BaseViewController {
    
    var workspaceData: [WorkSpace] = []
    var workspaceId: Int?
    
    private let disposeBag = DisposeBag()
    
    private let mainView = WorkspaceListView()
    weak var delegate: WorkSpaceListDelegate?
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func configure() {
        view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
        bindAction()
        if workspaceData.isEmpty {
            mainView.showWorkspaceList(show: false)
            bindEmpty()
        } else {
            mainView.showWorkspaceList(show: true)
            if let id = workspaceId {
                mainView.workspaceId = id
            }
            
            updateSnapShot()
        }
        
        
    }
    
    private func bindAction() {
        mainView.addWorkspaceView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                let vc = MakeViewController()
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindEmpty() {
        mainView.emptyView.makeButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = MakeViewController()
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
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
