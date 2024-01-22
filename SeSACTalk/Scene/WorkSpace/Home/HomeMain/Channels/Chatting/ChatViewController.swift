//
//  ChatViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit
import ReactorKit
import RxCocoa

final class ChatViewController: BaseViewController {
    
    private let mainView = ChatView()
    private var channel: Channel?
    
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
    }
    
    private func updateSnapShot(data: [ChannelMessage]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, ChannelMessage>()
        snapshot.appendSections([""])
        snapshot.appendItems(data)
        mainView.dataSource.apply(snapshot)
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
