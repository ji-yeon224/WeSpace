//
//  OtherProfileViewController.swift
//  WeSpace
//
//  Created by 김지연 on 2/19/24.
//

import UIKit
import ReactorKit
import RxCocoa

final class OtherProfileViewController: BaseViewController {
    
    
    private let mainView = OtherProfileView()
    private var items: [OtherProfileItem] = []
    private var userId: Int?
    
    private let requestUserInfo = PublishRelay<Int>()
    var disposeBag = DisposeBag()
    
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
        configNav()
        self.reactor = OtherProfileReactor()
        if let userId = userId {
            requestUserInfo.accept(userId)
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<String, OtherProfileItem>()
        snapshot.appendSections([""])
        
        snapshot.appendItems(items)
        mainView.dataSource.apply(snapshot)
    }
 
    
}

extension OtherProfileViewController: View {
    func bind(reactor: OtherProfileReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: OtherProfileReactor) {
        requestUserInfo
            .map { Reactor.Action.requestProfile(id: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: OtherProfileReactor) {
        reactor.state
            .map { $0.msg }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                if let value = value {
                    owner.showToastMessage(message: value, position: .bottom)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.loginRequest }
            .distinctUntilChanged()
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, value in
                if value {
                    print("login request")
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.userInfo }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .filter { !$0.isEmpty }
            .drive(with: self) { owner, value in
                owner.items = value
                owner.updateSnapshot()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.profileImage }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                if let img = value {
                    owner.mainView.profileImageView.setImage(with: img)
                } else {
                    
                    owner.mainView.profileImageView.image = Constants.Image.dummyProfile[(owner.userId ?? 0) % 3]
                }
            }
            .disposed(by: disposeBag)
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
