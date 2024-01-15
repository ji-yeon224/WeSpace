//
//  WorkspaceListViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/13/24.
//

import UIKit
import SideMenu

import RxSwift
import RxCocoa
import RxGesture

final class WorkspaceListViewController: BaseViewController {
    
    var workspaceData: [WorkSpace] = []
    var workspace: WorkSpace?
    
    private let disposeBag = DisposeBag()
    
    private let mainView = WorkspaceListView()
//    weak var delegate: WorkSpaceListDelegate?
    
    private let workspaceEdit = PublishRelay<Bool>()
    private let workspaceExit = PublishRelay<Bool>()
    private let changeManager = PublishRelay<Bool>()
    private let deleteWorkspaceList = PublishRelay<Bool>()

    
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
        
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
            if let ws = workspace {
                mainView.workspaceId = ws.workspaceId
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
        
        workspaceEdit
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, _ in
                 
            }
        
        
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

extension WorkspaceListViewController: WorkSpaceListDelegate {
    func workspaceSettingTapped() {
        
        if workspace?.ownerId == UserDefaultsManager.userId {
            present(showManagerActionSheet(), animated: true)
        } else {
            present(showActionSheet(), animated: true)
        }
        
    }
    
    private func showManagerActionSheet() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "워크스페이스 편집", style: .default) { _ in
            self.workspaceEdit.accept(true)
        }
        let exit = UIAlertAction(title: "워크스페이스 나가기", style: .default) { _ in
            self.workspaceExit.accept(true)
        }
        let changeManager = UIAlertAction(title: "워크스페이스 관리자 변경", style: .default) { _ in
            self.changeManager.accept(true)
        }
        let delete = UIAlertAction(title: "워크스페이스 삭제", style: .destructive) { _ in
            self.deleteWorkspaceList.accept(true)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        [edit, exit, changeManager, delete, cancel].forEach {
            actionSheet.addAction($0)
        }
        return actionSheet
    }
    
    private func showActionSheet() -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let exit = UIAlertAction(title: "워크스페이스 나가기", style: .default) { _ in
            self.workspaceExit.accept(true)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        [exit, cancel].forEach {
            actionSheet.addAction($0)
        }
        
        return actionSheet
    }
}
