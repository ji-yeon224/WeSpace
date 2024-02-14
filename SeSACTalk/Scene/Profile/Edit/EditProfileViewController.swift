//
//  EditProfileViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import UIKit

final class EditProfileViewController: BaseViewController {
    
    private let mainView = EditProfileView()
    private var editType: EditProfileType = .editNickname
    private var profileData: ProfileUpdateReqDTO?
    
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
        
        guard let profileData = profileData else { return }
        mainView.configTextFieldData(type: editType, data: profileData)
        
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
