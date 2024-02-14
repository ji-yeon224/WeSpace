//
//  EditProfileViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import UIKit
import ReactorKit
import RxCocoa
import AnyFormatKit

final class EditProfileViewController: BaseViewController {
    
    private let mainView = EditProfileView()
    private var editType: EditProfileType = .editNickname
    private var profileData: ProfileUpdateReqDTO?
    
    private var requestUpdate = PublishRelay<ProfileUpdateReqDTO>()
    
    var disposeBag = DisposeBag()
    
    var successUpdate: (() -> Void)?
    
    init(type: EditProfileType, data: ProfileUpdateReqDTO) {
        super.init(nibName: nil, bundle: nil)
        self.editType = type
        self.profileData = data
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
    }
    
    override func configure() {
        super.configure()
        configNav()
        self.reactor = EditProfileReactor()
        
        guard let profileData = profileData else { return }
        mainView.configTextFieldData(type: editType, data: profileData)
        
    }
    
    
    
}

extension EditProfileViewController: View {
    func bind(reactor: EditProfileReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        
        switch editType {
        case .editNickname:
            bindNicknameEvent()
        case .editPhone:
            bindPhoneEvent()
        }
    }
    
    private func bindAction(reactor: EditProfileReactor) {
        requestUpdate
            .map { Reactor.Action.requestEdit(type: self.editType, data: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: EditProfileReactor) {
        reactor.state
            .map { $0.msg }
            .filter { $0 != .none }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                if let value = value {
                    owner.showToastMessage(message: value, position: .top)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.successUpdate }
            .asDriver(onErrorJustReturn: false)
            .filter { $0 }
            .drive(with: self) { owner, _ in
                owner.successUpdate?()
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindNicknameEvent() {
        
        mainView.completeButton.rx.tap
            .withLatestFrom(mainView.editTextfield.rx.text.orEmpty)
            .map({
                return $0
            })
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, value in
                owner.requestUpdate.accept(ProfileUpdateReqDTO(nickname: value, phone: owner.profileData?.phone))
            }
            .disposed(by: disposeBag)
        
        mainView.editTextfield.rx.text.orEmpty
            .asDriver()
            .drive(with: self) { owner, value in
                let enable = value.isEmpty || value == owner.profileData?.nickname
                owner.mainView.setButtonEnable(isActive: !enable)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindPhoneEvent() {
        
        mainView.completeButton.rx.tap
            .withLatestFrom(mainView.editTextfield.rx.text.orEmpty)
            .map({
                return $0
            })
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, value in
                if let profileData = owner.profileData {
                    owner.requestUpdate.accept(ProfileUpdateReqDTO(nickname: profileData.nickname, phone: value))
                }
            }
            .disposed(by: disposeBag)
        
        mainView.editTextfield.rx.text.orEmpty
            .asDriver()
            .drive(with: self) { owner, value in
                let empty = value.isEmpty || value == owner.profileData?.phone
                owner.mainView.setButtonEnable(isActive: !empty)
            }
            .disposed(by: disposeBag)
        
        mainView.editTextfield.rx.text.orEmpty
            .asDriver()
            .map {
                if "\($0)".lastString.isNumber {
                    return "\($0)"
                } else {
                    let index = "\($0)".index("\($0)".startIndex, offsetBy: $0.count)
                    return String($0[..<index])
                }
            }
            .drive(with: self) { owner, value in
                if value.count > 13 {
                    let index = value.index(value.startIndex, offsetBy: 13)
                    owner.mainView.editTextfield.text = String(value[..<index])
                } else {
                    let characterSet = CharacterSet(charactersIn: value.lastString)
                    if CharacterSet.decimalDigits.isSuperset(of: characterSet) == false {
                        owner.mainView.editTextfield.text = owner.mainView.editTextfield.text
                        
                    } else {
                        let formatter = DefaultTextInputFormatter(textPattern: "###-####-####")
                        let result = formatter.formatInput(currentText: value, range: NSRange(location: value.count-1, length: 1), replacementString: value.lastString)
                        owner.mainView.editTextfield.text = result.formattedText
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

extension EditProfileViewController {
    private func configNav() {
        switch editType {
        case .editNickname:
            title = "닉네임"
        case .editPhone:
            title = "연락처"
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
