//
//  SearchChannelViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import UIKit
import ReactorKit

final class SearchChannelViewController: BaseViewController {
    
    private let mainView = SearchChannelView()
    
    private let requestChannelList = PublishSubject<Int?>()
    private let requestMyChannels = PublishSubject<Int>()
    private let saveToDB = PublishSubject<Channel>()
    
    private var myChannelList: [Int:Channel] = [:]
    private var wsId: Int?
    private var workspace: WorkSpace?
    
    weak var delegate: SearchChannelDelegate?
    
    var disposeBag = DisposeBag()
    
    init(workspace: WorkSpace) {
        super.init(nibName: nil, bundle: nil)
        self.wsId = workspace.workspaceId
        self.workspace = workspace
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
        title = "채널 탐색"
    }
    
    
    override func configure() {
        configNav()
        self.reactor = SearchChannelReactor()
        guard let wsId = wsId else {
            showToastMessage(message: "채널 목록을 불러올 수 없습니다.", position: .bottom)
            return
        }
        requestMyChannels.onNext(wsId)
//        requestChannelList.onNext(wsId)
        navigationController?.navigationBar.isHidden = false
        
    }
    
    
    
    
    
}

extension SearchChannelViewController: View {
    
    func bind(reactor: SearchChannelReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: SearchChannelReactor) {
        
        requestMyChannels
            .map { Reactor.Action.requestMyChannels(wsId: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        requestChannelList
            .map { Reactor.Action.requestChannelList(wsId: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveToDB
            .map { Reactor.Action.saveChannel(wsId: self.workspace?.workspaceId, chId: $0.channelID, name: $0.name)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: SearchChannelReactor) {
        
        reactor.state
            .map { $0.channelList }
            .distinctUntilChanged {
                return $0.count == $1.count
            }
            .filter { $0.count != 0 }
            .asDriver(onErrorJustReturn: [])
            .drive(mainView.tableView.rx.items(dataSource: mainView.dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.msg }
            .filter {
                !$0.isEmpty
            }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .bottom)
            }
            .disposed(by: disposeBag)
            
        reactor.state
            .map { $0.myChannelList }
            .asDriver(onErrorJustReturn: [:])
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .drive(with: self) { owner, dict in
                owner.myChannelList = dict
                owner.requestChannelList.onNext(owner.wsId)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.saveChannel }
            .filter { $0 != .none }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                if let value = value, let workspace = owner.workspace {
                    let vc = ChatViewController(info: value, workspace: workspace, chatItems: [])
                    vc.refreshHome = {
                        NotificationCenter.default.post(name: .refreshChannel, object: nil)
                    }
                    vc.hidesBottomBarWhenPushed = true
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    
    private func bindEvent() {
        
        mainView.tableView.rx.modelSelected(Channel.self)
            .asDriver()
            .drive(with: self) { owner, value in
                if owner.myChannelList[value.channelID] != nil { // 이미 속한 채널
                    owner.moveChannel(channel: value, join: false)
                } else {
                    
                    let joinMsg = Text.joinChannel.replacingOccurrences(of: "{channel}", with: value.name)
                    
                    owner.showPopUp(title: Text.joinTitle, message: joinMsg, align: .center, cancelTitle: "취소", okTitle: "확인") { } okCompletion: {
                        owner.joinChannel(channel: value)
                    }

                }
            }
            .disposed(by: disposeBag)
        
    }
    
}

extension SearchChannelViewController {
    
    private func joinChannel(channel: Channel) {
        saveToDB.onNext(channel)
        
    }
    
    private func moveChannel(channel: Channel, join: Bool) {
        
        delegate?.moveToChannel(channel: channel, join: join)
        navigationController?.popViewController(animated: false)
    }
    
    
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
        
        navigationController?.setupBarAppearance()
    }
    @objc private func xButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
