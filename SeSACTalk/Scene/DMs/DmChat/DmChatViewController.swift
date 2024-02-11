//
//  DmChatViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import UIKit
import ReactorKit
import RxCocoa

final class DmChatViewController: BaseViewController {
    
    private let mainView = DmChatView()
    private var dmUserInfo: User?
    private var myInfo: User?
    private var dmRoomInfo: DmDTO?
    
    private var selectImageModel = SelectImageModel(section: "", items: [])
    private var imgData = PublishRelay<[SelectImageModel]>()
    private var dmData: [DmChat] = []
    
    
    private var selectedAssetIdentifiers = [String]()
    private let selectImgCount = BehaviorRelay(value: 0)
    var disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
    }
    
    init(myInfo: User?, dmInfo: DmDTO?, dmChatItem: [DmChat]?) {
        super.init(nibName: nil, bundle: nil)
        self.myInfo = myInfo
        self.dmRoomInfo = dmInfo
        if let chatItem = dmChatItem {
            self.dmData.append(contentsOf: chatItem)
        }
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DmRepository().getLocation()
    }
    
    override func configure() {
        self.reactor = DmChatReactor()
        view.backgroundColor = .secondaryBackground
        configNav()
        title = dmUserInfo?.nickname
        navigationController?.navigationBar.isHidden = false
        mainView.chatWriteView.delegate = self
        updateTableSnapShot()
//        bindEvent()
    }
}

extension DmChatViewController: View {
    
    func bind(reactor: DmChatReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: DmChatReactor) {
        
        mainView.chatWriteView.sendButton.rx.tap
            .withLatestFrom(mainView.chatWriteView.textView.rx.text.orEmpty, resultSelector: { _, value in
                return value
            })
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .withUnretained(self)
            .map { owner, value in
                Reactor.Action.sendReqeust(dmInfo: owner.dmRoomInfo, content: value, files: owner.selectImageModel.items)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: DmChatReactor) {
        
        reactor.state
            .map { $0.sendSuccess }
            .filter { $0 != .none }
            .distinctUntilChanged { prev, cur in
                prev?.dmId == cur?.dmId
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                if let value = value {
                    print(value)
                    owner.dmData.append(value)
                    owner.updateTableSnapShot()
                    owner.mainView.tableView.scrollToRow(at: IndexPath(item: owner.dmData.count-1, section: 0), at: .bottom, animated: false)
                    owner.initImageCell()
                    owner.mainView.chatWriteView.textView.text = nil
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindEvent() {
        mainView.chatWriteView.textView.rx.didChange
            .asDriver()
            .drive(with: self) { owner, _ in
                
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
            .observe(on: MainScheduler.instance)
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
        
    }
}


extension DmChatViewController: ChatImageSelectDelegate {
    func deleteImage(indexPath: IndexPath) {
        selectedAssetIdentifiers.remove(at: indexPath.item)
        selectImageModel.items.remove(at: indexPath.item)
        selectImgCount.accept(selectImageModel.items.count)
        imgData.accept([selectImageModel])
    }
}

extension DmChatViewController {
    
    private func updateTableSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, DmChat>()
        snapshot.appendSections([""])
        snapshot.appendItems(dmData)
        mainView.tabledataSource.apply(snapshot, animatingDifferences: false)
        
    }
    
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
}

extension DmChatViewController {
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
        if SocketNetworkManager.shared.isConnected {
            SocketNetworkManager.shared.disconnect()
        }
    }
}
