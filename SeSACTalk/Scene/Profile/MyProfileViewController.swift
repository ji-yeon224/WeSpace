//
//  MyProfileViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/13/24.
//

import UIKit
import ReactorKit
import RxCocoa

final class MyProfileViewController: BaseViewController {
    
    private let mainView = MyProfileView()
    
    private let dummy1 = [
        MyProfileEditItem(type: .coin),
        MyProfileEditItem(type: .nickname, subText: "jigom"),
        MyProfileEditItem(type: .phone, subText: "010-1111-1111"),
        
    ]
    
    private let dummy2 = [
        MyProfileEditItem(type: .email, email: "aa@aa.com"),
        MyProfileEditItem(type: .linkSocial, vendor: "apple"),
        MyProfileEditItem(type: .logout)
    ]
    
    override func loadView() {
        self.view = mainView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionSnapShot()
        updateSnapShot()
    }
    
    override func configure() {
        super.configure()
        configNav()
        
    }
    
    
}

// CollectionView
extension MyProfileViewController {
    private func sectionSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<MyProfileSection, MyProfileEditItem>()
        snapshot.appendSections([.section1, .section2])
        mainView.dataSource.apply(snapshot)
        
    }
    
    private func setSectionItem() -> [MyProfileSection: [MyProfileEditItem]] {
        var items: [MyProfileSection: [MyProfileEditItem]] = [:]
        items[.section1] = dummy1
        items[.section2] = dummy2
        return items
    }
    
    private func updateSnapShot() {
        for (section, items) in setSectionItem() {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<MyProfileEditItem>()
            sectionSnapshot.append(items)
            mainView.dataSource.apply(sectionSnapshot, to: section, animatingDifferences: false)
        }
    }
}

// Nav
extension MyProfileViewController {
    private func configNav() {
        title = "내 정보 수정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
