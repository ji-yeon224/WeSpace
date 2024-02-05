//
//  ChangeCHManagerViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/5/24.
//

import UIKit
import ReactorKit

final class ChangeCHManagerViewController: BaseViewController {
    
    private let mainView = ChangeManagerView()
    var disposeBag = DisposeBag()
    var channel: Channel?
    private var items: [User]?
    
    
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = [
            User(userId: 1, email: "aa", nickname: "aa", profileImage: nil),
            User(userId: 2, email: "bb", nickname: "bb", profileImage: nil),
            User(userId: 3, email: "cc", nickname: "cc", profileImage: nil)
        
        ]
        updateSnapShot(data: user)
    }
    
    override func configure() {
        super.configure()
        title = "채널 관리자 변경"
        configNav()
        
    }
    
    
    private func updateSnapShot(data: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, User>()
        snapshot.appendSections([""])
        snapshot.appendItems(data)
        mainView.dataSource.apply(snapshot)
    }
}

extension ChangeCHManagerViewController {
    
}


extension ChangeCHManagerViewController {
    private func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}
