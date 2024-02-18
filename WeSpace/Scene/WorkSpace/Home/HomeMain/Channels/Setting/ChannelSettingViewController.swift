//
//  ChannelSettingViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/2/24.
//

import UIKit
import ReactorKit
import RxCocoa

final class ChannelSettingViewController: BaseViewController {
    
    private let mainView = ChannelSettingView()
    var disposeBag = DisposeBag()
    
    private var chName: String?
    private var channel: Channel?
    private var workspace: WorkSpace?
    private var requestChannelInfo = PublishRelay<(Int, String)>()
    private var requestExitChannel = PublishRelay<Void>()
    private var requestDeleteChannel = PublishRelay<Void>()
    
    weak var delegate: ChannelSettingDelegate?
    var memberList: [ChannelMemberItem] = []
    
    
    
    init(chName: String, ws: WorkSpace) {
        super.init(nibName: nil, bundle: nil)
        self.chName = chName
        self.workspace = ws
        
    }
    
    deinit {
        self.disposeBag = DisposeBag()
        print("ChannelSetting deinit")
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let name = chName, let ws = workspace else {
            self.showToastMessage(message: "데이터를 불러올 수 없습니다.", position: .top)
            return
        }
        
        requestChannelInfo.accept((ws.workspaceId, name)) // 해당 채널 전체 정보
        
    }
    
    override func configure() {
        super.configure()
        
        self.reactor = ChannelSettingReactor()
        
        configNav()
        title = "채널 설정"
        mainView.configDummyData()
        mainView.setButtonHidden(isAdmin: true)
        
        
    }
    
    
    
    
    
}

// ReactorKit
extension ChannelSettingViewController: View {
    
    func bind(reactor: ChannelSettingReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    
    private func bindAction(reactor: ChannelSettingReactor) {
        requestChannelInfo
            .map { Reactor.Action.requestChannelInfo(wsId: $0.0, name: $0.1)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestExitChannel
            .withUnretained(self)
            .map { owner, _ in
                Reactor.Action.requestExitChannel(wsId: owner.workspace?.workspaceId, name: owner.channel?.name, chId: owner.channel?.channelID)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestDeleteChannel
            .withUnretained(self)
            .map { owner, _ in
                Reactor.Action.requestDeleteChannel(wsId: owner.workspace?.workspaceId, name: owner.chName, chId: owner.channel?.channelID)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: ChannelSettingReactor) {
        
        reactor.state
            .map { $0.msg }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .top)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.channelInfo }
            .filter{ $0 != .none }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, value in
                if let channel = value {
                    owner.channel = channel
                    owner.mainView.setChannelInfo(name: channel.name, description: channel.description)
                    if value?.ownerID == UserDefaultsManager.userId { // 관리자이면
                        owner.mainView.setButtonHidden(isAdmin: true)
                    } else {
                        owner.mainView.setButtonHidden(isAdmin: false)
                        
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.memberInfo }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .filter { !$0.isEmpty }
            .drive(with: self) { owner, value in
                owner.memberList = value.map {
                    ChannelMemberItem(title: "", subItems: [], item: $0)
                }
                let item = ChannelMemberItem(title: "멤버 (\(value.count))", subItems: owner.memberList, item: nil)
                owner.updateSnapShot(item: item)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.exitSuccess }
            .asDriver(onErrorJustReturn: [])
            .filter{ !$0.isEmpty }
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                owner.delegate?.channelExitRefresh(data: value)
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.successDelete }
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()
            .filter { $0 }
            .drive(with: self) { owner, value in
                NotificationCenter.default.post(name: .refreshWS, object: nil)
                owner.navigationController?.popToRootViewController(animated: true)
                
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindEvent() {
        mainView.collectionView.rx.itemSelected
            .asDriver()
            .drive(with: self) { owner, indexPath in
                if indexPath.item == 0 {
                    owner.mainView.scrollView.updateContentView()
                    owner.mainView.collectionView.layoutIfNeeded()
                    
                }
            }
            .disposed(by: disposeBag)
        
        mainView.editButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                if let workspace = owner.workspace {
                    let vc = CreateChannelViewController(wsId: workspace.workspaceId, channel: owner.channel, mode: .edit)
                    vc.updateComplete = { info in
                        owner.showToastMessage(message: ChannelToastMessage.successEdit.message, position: .bottom)
                        owner.mainView.setChannelInfo(name: info.name, description: info.description)
                        
                    }
                    owner.presentPageSheet(vc: vc)
                }
            }
            .disposed(by: disposeBag)
        
        mainView.exitButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.showExitPopupView()
            }
            .disposed(by: disposeBag)
        
        mainView.changeButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let vc = ChangeCHManagerViewController()
                vc.channel = owner.channel
                vc.delegate = self
                let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
                nav.setupBarAppearance()
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        mainView.deleteButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showPopUp(title: Text.channelDeleteTitle, message: Text.channelDeleteMessage, align: .center, cancelTitle: "취소", okTitle: "삭제", okCompletion:  {
                    owner.requestDeleteChannel.accept(())
                })
            }
            .disposed(by: disposeBag)
    }
    
    
}

extension ChannelSettingViewController: ChannelCHManagerDelegate{
    func successChangeCHMAnager(data: Channel) {
        showToastMessage(message: ChannelToastMessage.successChange.message, position: .bottom)
        NotificationCenter.default.post(name: .refreshChannel, object: nil)
        channel = data
        mainView.setButtonHidden(isAdmin: false)
    }
}

extension ChannelSettingViewController {
    private func showExitPopupView() {
        // 관리자이면
        if channel?.ownerID == UserDefaultsManager.userId {
            showPopUp(title: Text.exitChannelTitle, message: Text.exitChannelManagerMessage, okTitle: "확인", okCompletion:  { })
        } else {
            showPopUp(title: Text.exitChannelTitle, message: Text.exitChannelMessage, align: .center, cancelTitle: "취소", okTitle: "삭제") { } okCompletion: {
                self.requestExitChannel.accept(())
            }

        }
    }
}


// collectionView
extension ChannelSettingViewController {
    
    private func updateSnapShot(item: ChannelMemberItem) {
        mainView.collectionView.collectionViewLayout = mainView.createLayout(userCnt: item.subItems.count)
        let snapshot = initialSnapshot(items: [item])
        mainView.dataSource.apply(snapshot, to: "", animatingDifferences: true)
        
    }
    
    
    private func initialSnapshot(items: [ChannelMemberItem]) -> NSDiffableDataSourceSectionSnapshot<ChannelMemberItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<ChannelMemberItem>()
        
        snapshot.append(items, to: nil)
        for item in items where !item.subItems.isEmpty {
            snapshot.append(item.subItems, to: item)
            snapshot.expand(items)
            
        }
        
        return snapshot
    }
}

extension ChannelSettingViewController {
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    private func presentPageSheet(vc: UIViewController) {
        let nav = PageSheetManager.sheetPresentation(vc, detent: .large())
        nav.setupBarAppearance()
        present(nav, animated: true)
    }
}


