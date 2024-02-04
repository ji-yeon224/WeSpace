//
//  ChatViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit
import ReactorKit
import RxCocoa
import RxDataSources

final class ChatViewController: BaseViewController {
    
    private let mainView = ChatView()
    private var channel: ChannelDTO?
    private var workspace: WorkSpace?
    private var userInfo: [Int: User] = [:]
    
    private var selectImageModel = SelectImageModel(section: "", items: [])
    private var imgData = PublishRelay<[SelectImageModel]>()
    private var requestUncheckedChat = PublishRelay<String?>()
    private var chatData: [ChannelMessage] = []
    private var lastDate: String?
//    private var selectLimit = 5
    private var selectedAssetIdentifiers = [String]()
    private let selectImgCount = BehaviorRelay(value: 0)
    var disposeBag = DisposeBag()
    
    var refreshHome: (() -> Void)?
    
    init(info: ChannelDTO, workspace: WorkSpace, chatItems: [ChannelMessage], userInfo: [Int: User]) {
        super.init(nibName: nil, bundle: nil)
        self.channel = info
        self.workspace = workspace
        self.userInfo = userInfo
//        print(workspace.workspaceId)
//        print(chatItems)
        
        
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mainView
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let channel = channel else { return }
        
        if !SocketNetworkManager.shared.isConnected {
            SocketNetworkManager.shared.configSocketManager(type: .channel(chId: channel.channelId))
            SocketNetworkManager.shared.connect()
        }
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        
        configData()
        self.reactor = ChatReactor()
        self.reactor?.channelRecord = channel
        requestUncheckedChat.accept(lastDate)
        updateTableSnapShot()
        
        ChannelMsgRepository().getLocation()
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if SocketNetworkManager.shared.isConnected {
            SocketNetworkManager.shared.disconnect()
        }
        
    }
    
    private func configData() {
        if let channel = channel {
            let chats = channel.chatItem.map {
                $0.toDomain()
            }
            chatData.append(contentsOf: chats)
            
            lastDate = chats.last?.createdAt
        }
        
    }
    
    
    override func configure() {
        configNav()
        
        guard let channel = channel else { return }
        
        title = "# " + channel.name
        
        mainView.chatWriteView.delegate = self
        
        
        if let workspace = workspace {
            mainView.wsId = workspace.workspaceId
        }
        mainView.userInfo = self.userInfo
    }
    
    private func bindEvent() {
        mainView.chatWriteView.textView.rx.didChange
            .bind(with: self) { owner, _ in
                
                let chatWriteView = owner.mainView.chatWriteView
                let size = CGSize(width: chatWriteView.frame.width, height: .infinity)
                let estimatedSize = chatWriteView.textView.sizeThatFits(size)
                let isMaxHeight = estimatedSize.height >= 54
                
                if isMaxHeight {
                    chatWriteView.textView.isScrollEnabled = true
                } else { chatWriteView.textView.isScrollEnabled = false }
                
                if chatWriteView.textView.text.count > 0 {
                    chatWriteView.placeholder.isHidden = true
                } else {
                    chatWriteView.placeholder.isHidden = false
                }
                
            }
            .disposed(by: disposeBag)
        
        mainView.chatWriteView.imageButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.configSelectImage()
            }
            .disposed(by: disposeBag)
        
        selectImgCount
            .asDriver()
            .map { count in
                return count == 0
            }
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                owner.mainView.chatWriteView.imgCollectionView.isHidden = value
            }
            .disposed(by: disposeBag)
        
        imgData
            .bind(to: mainView.chatWriteView.imgCollectionView.rx.items(dataSource: mainView.chatWriteView.rxDataSource))
            .disposed(by: disposeBag)
        
        let buttonEnable = Observable.combineLatest(selectImgCount, mainView.chatWriteView.textView.rx.text.orEmpty) { imgCnt, text in
            return imgCnt > 0 || !text.isEmpty
        }
        
        buttonEnable
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, value in
                let img: UIImage = value ? .sendActive : .sendInactive
                owner.mainView.chatWriteView.sendButton.setImage(img, for: .normal)
                owner.mainView.chatWriteView.sendButton.isEnabled = value
            }
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItem?.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                // channel name, workspaceId
                if let channel = owner.channel, let workspace = owner.workspace {
                    let vc = ChannelSettingViewController(chName: channel.name, ws: workspace)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            .disposed(by: disposeBag)
        
        
    }
    
    
    
}

extension ChatViewController: View {
    func bind(reactor: ChatReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: ChatReactor) {
        
        NotificationCenter.default.rx.notification(.refreshChannel)
            .map { _ in Reactor.Action.fetchChannel(wsId: self.workspace?.workspaceId, chId: self.channel?.channelId)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.chatWriteView.sendButton.rx.tap
            .withLatestFrom(mainView.chatWriteView.textView.rx.text.orEmpty, resultSelector: { _, value in
                return value
            })
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .withUnretained(self)
            .map { Reactor.Action.sendRequest(channel: self.channel, id: self.workspace?.workspaceId, content: $0.1, files: self.selectImageModel.items)}
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        requestUncheckedChat
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .map { Reactor.Action.requestUncheckedMsg(date: $0.1, wsId: self.workspace?.workspaceId, name: self.channel?.name)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        SocketNetworkManager.shared.chatMessage
            .map { Reactor.Action.receiveMsg(wsId: self.workspace?.workspaceId, channel: self.channel, chatData: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: ChatReactor) {
        
        reactor.state
            .map { $0.fetchChatSuccess }
            .asDriver(onErrorJustReturn: [])
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .drive(with: self) { owner, value in
                owner.chatData.append(contentsOf: value)
                owner.updateTableSnapShot()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.msg }
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.showToastMessage(message: value, position: .top)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.sendSuccess }
            .filter { $0 != .none }
            .distinctUntilChanged { prev, cur in
                prev?.id == cur?.id
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                if let value = value {
                    owner.chatData.append(value)
                    owner.updateTableSnapShot()
                    owner.mainView.tableView.scrollToRow(at: IndexPath(item: owner.chatData.count-1, section: 0), at: .bottom, animated: false)
                    owner.initImageCell()
                    owner.mainView.chatWriteView.textView.text = nil
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.saveReceive }
            .filter { $0 != .none }
            .distinctUntilChanged { prev, cur in
                prev?.id == cur?.id
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                if let value = value {
                    owner.chatData.append(value)
                    owner.updateTableSnapShot()
                    owner.mainView.tableView.scrollToRow(at: IndexPath(item: owner.chatData.count-1, section: 0), at: .bottom, animated: false)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.channelRecord }
            .distinctUntilChanged()
            .filter { $0 != .none }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                owner.channel = value
                if let value = value {
                    owner.title = "# \(value.name)"
                }
                
            }
            .disposed(by: disposeBag)
        
    }
    
}

extension ChatViewController {
    private func configSelectImage() {
        PHPickerManager.shared.presentPicker(vc: self, selectLimit: 5, selectedId: selectedAssetIdentifiers)
        PHPickerManager.shared.selectedImage
            .bind(with: self) { owner, image in
                owner.setImageCell(identifier: image.0, img: image.1)
            }
            .disposed(by: PHPickerManager.shared.disposeBag)
    }
    
    private func setImageCell(identifier: [String], img: [UIImage]) {
        let imgList = img.map { return SelectImage(img: $0)}
        selectedAssetIdentifiers = identifier
        selectImgCount.accept(imgList.count)
        selectImageModel = SelectImageModel(section: "", items: imgList)
        imgData.accept([selectImageModel])
    }
    
    private func initImageCell() {
        selectedAssetIdentifiers.removeAll()
        selectImgCount.accept(0)
        selectImageModel.items.removeAll()
        imgData.accept([selectImageModel])
    }
    
    
    private func updateTableSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, ChannelMessage>()
        snapshot.appendSections([""])
        snapshot.appendItems(chatData)
        mainView.tabledataSource.apply(snapshot, animatingDifferences: false)
        
    }
}

extension ChatViewController: ChatImageSelectDelegate {
    func deleteImage(indexPath: IndexPath) {
        selectedAssetIdentifiers.remove(at: indexPath.item)
        selectImageModel.items.remove(at: indexPath.item)
        selectImgCount.accept(selectImageModel.items.count)
        imgData.accept([selectImageModel])
    }
}

extension ChatViewController {
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Constants.Image.chatSetting, style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationItem.rightBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
    }
    
    @objc private func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
        refreshHome?()
        navigationController?.popToRootViewController(animated: true)
        if SocketNetworkManager.shared.isConnected {
            SocketNetworkManager.shared.disconnect()
        }
    }
}

