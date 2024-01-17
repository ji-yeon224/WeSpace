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


enum WSSettingType {
    case exit, change, delete
}

final class WorkspaceListViewController: BaseViewController, View {
    
    
    var workspace: WorkSpace?
    var items: [WorkSpace] = []
    private var setType: WSSettingType = .change
    var disposeBag = DisposeBag()
    
    private let mainView = WorkspaceListView()
    private let alertView = AlertViewController()

    private let requestAllWorkspace = PublishRelay<Bool>()
    private let workspaceEdit = PublishRelay<Bool>()
    private let workspaceExit = PublishRelay<Bool>()
    private let changeManager = PublishRelay<Bool>()
    private let deleteWorkspaceList = PublishRelay<Bool>()
    private let workspaceItem = PublishRelay<[WorkSpace]>()
    
    private let requestExit = PublishRelay<Void>()
    private let requestDelete = PublishRelay<Void>()
    
    override func loadView() {
        self.view = mainView
//        mainView.workspaceId = workspace!.workspaceId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
        alertView.delegate = self
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
        requestAllWorkspace.accept(true)
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
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, _ in
                let vc = MakeViewController(mode: .edit, info: owner.workspace)
                vc.delegate = owner
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        workspaceExit
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, _ in
                if owner.workspace?.ownerId == UserDefaultsManager.userId {
                    owner.alertView.showAlertWithOK(title: Text.wsExitTitle, message: Text.workspaceExitManager)
                } else {
                    owner.alertView.showAlertWithCancel(title: Text.wsExitTitle, message: Text.workspaceExit, okText: "나가기")
                }
                
                owner.present(owner.alertView, animated: false)
            }
            .disposed(by: disposeBag)
        
        deleteWorkspaceList
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, _ in
                owner.alertView.showAlertWithCancel(title: Text.wsDeleteTitle, message: Text.workspaceDelete, okText: "삭제")
                owner.present(owner.alertView, animated: false)
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
        
        
        
    }
    
    private func bindAction(reactor: WorkspaceListReactor) {
        
        requestAllWorkspace
            .map { _ in Reactor.Action.requestAllWorkspace }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestExit
            .map { _ in Reactor.Action.requestExit(id: self.workspace?.workspaceId)}
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
            .distinctUntilChanged()
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

extension WorkspaceListViewController: AlertDelegate {
    func cancelButtonTap() {
        print("cancel")
    }
    func okButtonTap() {
        switch setType {
        case .change:
            print("change ok")
        case .delete:
            requestDelete.accept(())
        case .exit:
            if workspace?.ownerId == UserDefaultsManager.userId { // 관리자가 누름
                print("관리자임")
            } else {
                requestExit.accept(())
            }
        }
        print("ok")
    }
}

extension WorkspaceListViewController: MakeWSDelegate {
    func editComplete(data: WorkSpace) {
        self.workspace = data
        requestAllWorkspace.accept(true)
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
            self.workspaceEdit.accept(true)
        }
        let exit = UIAlertAction(title: "워크스페이스 나가기", style: .default) { _ in
            self.workspaceExit.accept(true)
            self.setType = .exit
        }
        let changeManager = UIAlertAction(title: "워크스페이스 관리자 변경", style: .default) { _ in
            self.changeManager.accept(true)
            self.setType = .change
        }
        let delete = UIAlertAction(title: "워크스페이스 삭제", style: .destructive) { _ in
            self.deleteWorkspaceList.accept(true)
            self.setType = .delete
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
            self.setType = .exit
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        [exit, cancel].forEach {
            actionSheet.addAction($0)
        }
        
        return actionSheet
    }
}
