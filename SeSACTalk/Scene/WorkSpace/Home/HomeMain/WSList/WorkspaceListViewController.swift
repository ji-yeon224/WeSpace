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
import ReactorKit



final class WorkspaceListViewController: BaseViewController, View {
    
    
    var workspace: WorkSpace?
    var items: [WorkSpace] = []
    var disposeBag = DisposeBag()
    
    private let mainView = WorkspaceListView()
    private let alertView = AlertViewController()

    private let requestAllWorkspace = PublishRelay<Void>()
    private let workspaceEdit = PublishRelay<Void>()
    private let workspaceExit = PublishRelay<Void>()
    private let changeManager = PublishRelay<Void>()
    private let deleteWorkspaceList = PublishRelay<Void>()
    private let workspaceItem = PublishRelay<[WorkSpace]>()
    
    private let requestExit = PublishRelay<Int>()
    private let requestDelete = PublishRelay<Void>()
    
    
    override func loadView() {
        self.view = mainView
//        mainView.workspaceId = workspace!.workspaceId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .isSideVCAppear, object: nil, userInfo: [UserInfo.alphaShow: false])
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .isSideVCAppear, object: nil, userInfo: [UserInfo.alphaShow: true])
        if let ws = workspace {
            mainView.workspaceId = ws.workspaceId
        }
        requestAllWorkspace.accept(())
    }
    
    override func configure() {
        view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
        if let ws = workspace {
            mainView.workspaceId = ws.workspaceId
        }
        self.reactor = WorkspaceListReactor()
//        requestAllWorkspace.accept(true)
        alertView.modalPresentationStyle = .overFullScreen
        
    }
    
    private func configView(isEmpty: Bool) {
        if isEmpty {
            mainView.showWorkspaceList(show: false)
            bindEmpty()
        } else {
            mainView.showWorkspaceList(show: true)
            if let ws = workspace {
                mainView.workspaceId = ws.workspaceId
            }
        }
    }
    
    func bind(reactor: WorkspaceListReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindEvent() {
        mainView.addWorkspaceView.rx.tapGesture()
            .when(.recognized)
            .debug()
            .bind(with: self) { owner, _ in
                let vc = MakeViewController()
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                vc.delegate = self
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        workspaceEdit
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                let vc = MakeViewController(mode: .edit, info: owner.workspace)
                vc.delegate = owner
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        workspaceExit
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                if owner.workspace?.ownerId == UserDefaultsManager.userId {
                    owner.showPopUp(title: Text.wsExitTitle, message: Text.workspaceExitManager, okTitle: "나가기", okCompletion: nil)
                    
                } else {
                    owner.showPopUp(title: Text.wsExitTitle, message: Text.workspaceExit, align: .center, cancelTitle: "취소", okTitle: "나가기") { } okCompletion: {
                        if let workspace = owner.workspace {
                            owner.requestExit.accept((workspace.workspaceId))
                        }
                        
                    }

                }
                
            }
            .disposed(by: disposeBag)
        
        deleteWorkspaceList
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.showPopUp(title: Text.wsDeleteTitle, message: Text.workspaceDelete, cancelTitle: "취소", okTitle: "삭제") { } okCompletion: {
                    owner.requestDelete.accept(())
                }

            }
            .disposed(by: disposeBag)
        
        workspaceItem
            .filter {
                $0.isEmpty == false
            }
            .bind(with: self) { owner, value in
                owner.items = value
                owner.updateSnapShot(data: value)
                owner.configView(isEmpty: value.isEmpty)
            }
            .disposed(by: disposeBag)
        
        mainView.collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.dismiss(animated: false)
                NotificationCenter.default.post(name: .resetWS, object: nil, userInfo: [UserInfo.workspace: owner.items[indexPath.item]])
//                NotificationCenter.default.post(name: .refreshWS, object: nil)
                
            }
            .disposed(by: disposeBag)
        
        changeManager
            .bind(with: self) { owner, _ in
                let vc = ChangeWSManagerViewController()
                vc.workspace = owner.workspace
                vc.delegate = self
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindAction(reactor: WorkspaceListReactor) {
        
        requestAllWorkspace
            .map { _ in Reactor.Action.requestAllWorkspace }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestExit
            .map { Reactor.Action.requestExit(id: self.workspace?.workspaceId, owner: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestDelete
            .map { _ in Reactor.Action.requestDelete(id: self.workspace?.workspaceId)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: WorkspaceListReactor) {
        reactor.state
            .map { $0.allWorkspace }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.workspaceItem.accept(value)
                owner.configView(isEmpty: value.isEmpty)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.message }
            .filter {
                !$0.isEmpty
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                debugPrint("ERROR - \(value)")
                owner.showToastMessage(message: value, position: .bottom)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.successLeave }
            .filter {
                $0 != .none
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                if let value = value {
                    if value.isEmpty {
                        owner.presentHomeEmptyView()
                    } else {
                        owner.presentOtherWorkspace(workspace: value[0])
                    }
                }
               
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.successDelete }
            .filter {
                $0 != .none
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .debug()
            .bind(with: self) { owner, value in
                if let value = value {
                    print(value.count)
                    if value.isEmpty {
                        owner.presentHomeEmptyView()
                    } else {
                        owner.presentOtherWorkspace(workspace: value[0])
                    }
                }
            }
            .disposed(by: disposeBag)
        
            
    }
    
    private func presentOtherWorkspace(workspace: WorkSpace) {
        NotificationCenter.default.post(name: .resetWS, object: nil, userInfo: [UserInfo.workspace: workspace])
        dismiss(animated: false)
    }
    
    private func presentHomeEmptyView() {
        let nav = UINavigationController(rootViewController: HomeEmptyViewController())
        view.window?.rootViewController = nav
        view.window?.makeKeyAndVisible()
        dismiss(animated: true)
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
    
    
    
    private func updateSnapShot(data: [WorkSpace]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, WorkSpace>()
        snapshot.appendSections([""])
        snapshot.appendItems(data)
        mainView.dataSource.apply(snapshot)
    }
    
}

extension WorkspaceListViewController: ChangeWSManageDelegate {
    func completeChanageManager(data: WorkSpace) {
        self.workspace = data
        
    }
}


extension WorkspaceListViewController: MakeWSDelegate {
    func editComplete(data: WorkSpace) {
        self.workspace = data
        requestAllWorkspace.accept(())
        showToastMessage(message: WorkspaceToastMessage.editWorkspace.message, position: .bottom)
        NotificationCenter.default.post(name: .refreshWS, object: nil)
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
            self.workspaceEdit.accept(())
        }
        let exit = UIAlertAction(title: "워크스페이스 나가기", style: .default) { _ in
            self.workspaceExit.accept(())
        }
        let changeManager = UIAlertAction(title: "워크스페이스 관리자 변경", style: .default) { _ in
            self.changeManager.accept(())
        }
        let delete = UIAlertAction(title: "워크스페이스 삭제", style: .destructive) { _ in
            self.deleteWorkspaceList.accept(())
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
            self.workspaceExit.accept(())
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        [exit, cancel].forEach {
            actionSheet.addAction($0)
        }
        
        return actionSheet
    }
}
