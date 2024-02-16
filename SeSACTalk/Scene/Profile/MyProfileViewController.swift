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
    private let requestLogout = PublishRelay<String?>()
    
    private var section: [MyProfileSectionModel] = []
    private let collectionItems = PublishRelay<[MyProfileSectionModel]>()
    
    private var myInfo: MyProfile?
    
    override func loadView() {
        self.view = mainView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        requestLogout
            .map { Reactor.Action.requestLogout(vendor: $0) }
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
            .map { $0.profileImage }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                owner.mainView.setProfileImage(value: value)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.profileData }
            .filter { $0 != nil }
            .bind(with: self) { owner, value in
                if let value = value {
                    owner.mainView.setProfileImage(value: value.profileImage)
                    owner.collectionItems.accept(owner.setUserProfile(data: value))
                    owner.myInfo = value
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.logoutSuccess }
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, _ in
                UserDefaultsManager.initToken()
                owner.view?.window?.rootViewController = OnBoardingViewController()
                owner.view.window?.makeKeyAndVisible()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bindEvent() {
        
        mainView.collectionView.rx.modelSelected(MyProfileEditItem.self)
            .bind(with: self) { owner, value in
                owner.editProfile(dataType: value.type)
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
                }
            }
            .disposed(by: disposeBag)
        
        collectionItems
            .asDriver(onErrorJustReturn: [])
            .drive(mainView.collectionView.rx.items(dataSource: mainView.rxdataSource))
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.refreshMyInfo)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, _ in
                owner.requestMyInfo.accept(())
            }
            .disposed(by: disposeBag)
    }
    
}

extension MyProfileViewController {
    
    private func editProfile(dataType: MyProfileEditType) {
        guard let myInfo = myInfo else { return }
        switch dataType {
        case .coin:
            print("coin")
            let vc = CoinViewController()
            vc.coin = myInfo.sesacCoin
            navigationController?.pushViewController(vc, animated: true)
        case .nickname:
            let vc = EditProfileViewController(type: .editNickname, data: ProfileUpdateReqDTO(nickname: myInfo.nickname, phone: myInfo.phone ?? ""))
            vc.successUpdate = {
                self.showToastMessage(message: UserToastMessage.updateNickname.message, position: .bottom)
                self.requestMyInfo.accept(())
            }
            navigationController?.pushViewController(vc, animated: true)
            
        case .phone:
            let vc = EditProfileViewController(type: .editPhone, data: ProfileUpdateReqDTO(nickname: myInfo.nickname, phone: myInfo.phone ?? ""))
            vc.successUpdate = {
                self.showToastMessage(message: UserToastMessage.updatePhone.message, position: .bottom)
                self.requestMyInfo.accept(())
            }
            navigationController?.pushViewController(vc, animated: true)
        case .email, .linkSocial:
            break
        case .logout:
            
            showPopUp(title: "로그아웃", message: "정말 로그아웃 할까요?", align: .center, cancelTitle: "취소", okTitle: "로그아웃", okCompletion:  {
                self.requestLogout.accept(self.myInfo?.vendor)
            })

        }
    }
    
    private func setUserProfile(data: MyProfile) -> [MyProfileSectionModel] {
        let section1: [MyProfileEditItem] = [
            MyProfileEditItem(type: .coin, coin: data.sesacCoin),
            MyProfileEditItem(type: .nickname, subText: data.nickname),
            MyProfileEditItem(type: .phone, subText: data.phone)
        ]
        var section2: [MyProfileEditItem] = []
        section2.append(MyProfileEditItem(type: .email, email: data.email))
        if let vendor = data.vendor {
            section2.append(MyProfileEditItem(type: .linkSocial, vendor: vendor))
        }
        section2.append(MyProfileEditItem(type: .logout))
        
        return [MyProfileSectionModel(section: .section1, items: section1),
                     MyProfileSectionModel(section: .section2, items: section2)]
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
        navigationController?.popViewController(animated: true)
    }
}
