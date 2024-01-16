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
    
    
//    var workspaceData: [WorkSpace] = []
    var workspace: WorkSpace?
    var items: [WorkSpace] = []
    var disposeBag = DisposeBag()
    
    private let mainView = WorkspaceListView()
//    weak var delegate: WorkSpaceListDelegate?
    private let requestAllWorkspace = PublishRelay<Bool>()
    private let workspaceEdit = PublishRelay<Bool>()
    private let workspaceExit = PublishRelay<Bool>()
    private let changeManager = PublishRelay<Bool>()
    private let deleteWorkspaceList = PublishRelay<Bool>()
    private let workspaceItem = PublishRelay<[WorkSpace]>()
    
    override func loadView() {
        self.view = mainView
//        mainView.workspaceId = workspace!.workspaceId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
    }
    
    
    
    override func configure() {
        view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
        if let ws = workspace {
            mainView.workspaceId = ws.workspaceId
        }
        self.reactor = WorkspaceListReactor()
        requestAllWorkspace.accept(true)
        
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
    }
    
    private func bindAction(reactor: WorkspaceListReactor) {
        mainView.addWorkspaceView.rx.tapGesture()
            .when(.recognized)
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
                let nv = PageSheetManager.sheetPresentation(vc, detent: .large())
                owner.present(nv, animated: true)
            }
            .disposed(by: disposeBag)
        
        requestAllWorkspace
            .map { _ in Reactor.Action.requestAllWorkspace }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        workspaceItem
            .filter {
                $0.isEmpty == false
            }
            .bind(with: self) { owner, value in
                owner.updateSnapShot(data: value)
                owner.configView(isEmpty: value.isEmpty)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: WorkspaceListReactor) {
        reactor.state
            .map { $0.allWorkspace }
            .distinctUntilChanged()
            .filter { $0.isEmpty == false }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.workspaceItem.accept(value)
                owner.configView(isEmpty: value.isEmpty)
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
        print(#function)
        NotificationCenter.default.post(name: .isSideVCAppear, object: nil, userInfo: ["show": true])
    }
    
    private func updateSnapShot(data: [WorkSpace]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, WorkSpace>()
        snapshot.appendSections([""])
        snapshot.appendItems(data)
        mainView.dataSource.apply(snapshot)
    }
    
}

extension WorkspaceListViewController: MakeWSDelegate {
    func editComplete(data: WorkSpace) {
        self.workspace = data
        requestAllWorkspace.accept(true)
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
