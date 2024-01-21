//
//  ChatViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit

final class ChatViewController: BaseViewController {
    
    private let mainView = ChatView()
    private var channel: Channel?
    
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
    }
    
    
    override func configure() {
        configNav()
        
        guard let channel = channel else { return }
        
        title = channel.name
        
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
 
