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
    var disposeBag = DisposeBag()
    private let requestMyInfo = PublishRelay<Void>()
    private let changeProfileImage = PublishRelay<SelectImage>()
    
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
    private var section: [MyProfileSectionModel] = []
    private let collectionItems = PublishRelay<[MyProfileSectionModel]>()
    
    override func loadView() {
        self.view = mainView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        sectionSnapShot()
//        updateSnapShot()
        section = [MyProfileSectionModel(section: .section1, items: dummy1),
                   MyProfileSectionModel(section: .section2, items: dummy2)]
        collectionItems.accept(section)
        requestMyInfo.accept(())
    }
    
    override func configure() {
        super.configure()
        configNav()
        self.reactor = MyProfileReactor()
    }
    
    
}

extension MyProfileViewController: View {
    func bind(reactor: MyProfileReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: MyProfileReactor) {
        requestMyInfo
            .map { Reactor.Action.requestMyInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        changeProfileImage
            .map { Reactor.Action.changeProfileImage(data: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: MyProfileReactor) {
        reactor.state
            .map { $0.msg }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != .none }
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
            .bind(with: self) { owner, value in
                print("loginRequest")
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.myProfile }
            .filter { !$0.isEmpty }
            .asDriver(onErrorJustReturn: [])
            .drive(mainView.collectionView.rx.items(dataSource: mainView.rxdataSource))
            .disposed(by: disposeBag)
            
        reactor.state
            .map { $0.profileImage }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                owner.mainView.setProfileImage(value: value)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindEvent() {
        
        mainView.collectionView.rx.modelSelected(MyProfileEditItem.self)
            .bind(with: self) { owner, value in
                print(value)
            }
            .disposed(by: disposeBag)
        
        mainView.profileImageView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                PHPickerManager.shared.presentPicker(vc: owner, selectedId: nil)
            }
            .disposed(by: disposeBag)
        
        PHPickerManager.shared.selectedImage
            .bind(with: self) { owner, image in
                if !image.1.isEmpty {
                    owner.changeProfileImage.accept(SelectImage(img: image.1[0]))
//                    owner.mainView.profileImageView.imageView.image = image.1[0]
                    
//                    owner.mainView.profileImageView.imageView.setImage(img: image.1[0])
//                    owner.img = owner.mainView.imageView.image
                }
            }
            .disposed(by: disposeBag)
        
        
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
