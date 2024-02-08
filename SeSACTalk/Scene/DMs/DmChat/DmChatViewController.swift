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
    
    private let mainView = ChatView()
    private var dmUserInfo: User?
    private var myInfo: User?
    private var dmRoomInfo: DMsRoom?
    
    private var selectImageModel = SelectImageModel(section: "", items: [])
    private var imgData = PublishRelay<[SelectImageModel]>()
    
    private var selectedAssetIdentifiers = [String]()
    private let selectImgCount = BehaviorRelay(value: 0)
    var disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
    }
    
    init(myInfo: User?, dmInfo: DMsRoom) {
        super.init(nibName: nil, bundle: nil)
        self.myInfo = myInfo
        self.dmUserInfo = dmInfo.user
        self.dmRoomInfo = dmInfo
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configure() {
        view.backgroundColor = .secondaryBackground
        configNav()
        title = dmUserInfo?.nickname
        navigationController?.navigationBar.isHidden = false
        bindEvent()
    }
}

extension DmChatViewController {
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
        
    }
}

extension DmChatViewController {
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
