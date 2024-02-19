//
//  OtherProfileViewController.swift
//  WeSpace
//
//  Created by 김지연 on 2/19/24.
//

import UIKit
import ReactorKit

final class OtherProfileViewController: BaseViewController {
    
    
    private let mainView = OtherProfileView()
    private var items: [OtherProfileItem] = []
    private var userId: Int?
    
    override func loadView() {
        self.view = mainView
    }
    init(userId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.userId = userId
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = [OtherProfileItem(title: "닉네임", subText: "Jiyeon"),
                     OtherProfileItem(title: "이메일", subText: "a@a.com")
        ]
        self.items = items
        updateSnapshot()
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, OtherProfileItem>()
        snapshot.appendSections([""])
        
        snapshot.appendItems(items)
        mainView.dataSource.apply(snapshot)
    }
 
    
}

extension OtherProfileViewController {
    private func configNav() {
        title = "프로필"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
