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
    private var channel: Channel?
    
    private var selectImageModel = SelectImageModel(section: "", items: [])
    private var imgData = PublishRelay<[SelectImageModel]>()
//    private var selectLimit = 5
    private var selectedAssetIdentifiers = [String]()
    private let selectImgCount = BehaviorRelay(value: 0)
    var disposeBag = DisposeBag()
    
    init(info: Channel) {
        super.init(nibName: nil, bundle: nil)
        self.channel = info
        
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
        navigationController?.navigationBar.isHidden = false
        updateSnapShot(data: dummy)
    }
    
    
    override func configure() {
        configNav()
        
        guard let channel = channel else { return }
        
        title = "# " + channel.name
        bindEvent()
        mainView.chatWriteView.delegate = self
        
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
        
        mainView.chatWriteView.imgCollectionView.rx.itemSelected
            .bind(with: self) { owner, index in
                print(index)
            }
            .disposed(by: disposeBag)
        
        
        imgData
            .bind(to: mainView.chatWriteView.imgCollectionView.rx.items(dataSource: mainView.chatWriteView.rxDataSource))
            .disposed(by: disposeBag)
        
    }
    
    
    
}

extension ChatViewController {
    private func configSelectImage() {
        PHPickerManager.shared.presentPicker(vc: self, selectLimit: 5, selectedId: selectedAssetIdentifiers)
        PHPickerManager.shared.selectedImage
            .bind(with: self) { owner, image in
                let imgList = image.1.map { return SelectImage(img: $0)}
                owner.selectedAssetIdentifiers = image.0
                owner.selectImgCount.accept(imgList.count)
                owner.selectImageModel = SelectImageModel(section: "", items: imgList)
                owner.imgData.accept([owner.selectImageModel])
            }
            .disposed(by: PHPickerManager.shared.disposeBag)
    }
    
    private func updateSnapShot(data: [ChannelMessage]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, ChannelMessage>()
        snapshot.appendSections([""])
        snapshot.appendItems(data)
        mainView.dataSource.apply(snapshot)
        
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .list, style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationItem.rightBarButtonItem?.tintColor = .basicText
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
 
let dummy: [ChannelMessage] = [
ChannelMessage(channelID: 1, channelName: "hh", chatID: 1, content: "안녕", createdAt: "2023-12-21T22:47:30.236Z", files: [], user: User(userId: 2, email: "a@a.com", nickname: "jjiyy", profileImage: nil)),
ChannelMessage(channelID: 1, channelName: "hh", chatID: 1, content: "안녕dddsdkfjlsdkjflsdjfljsdlfjlsdjflsdjflkjslfjlsdk", createdAt: "2023-12-21T22:47:30.236Z", files: [], user: User(userId: 2, email: "a@a.com", nickname: "jjiyy", profileImage: nil)),
ChannelMessage(channelID: 1, channelName: "hh", chatID: 1, content: "안녕aaa", createdAt: "2023-12-21T22:47:30.236Z", files: [], user: User(userId: 2, email: "a@a.com", nickname: "jjiyy", profileImage: nil))

]
