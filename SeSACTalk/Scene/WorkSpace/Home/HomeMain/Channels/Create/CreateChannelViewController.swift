//
//  CreateChannelViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/21/24.
//

import UIKit

final class CreateChannelViewController: BaseViewController {
    
    private let mainView = CreateChannelView()
    private var workspace: WorkSpace?
    
    init(workspace: WorkSpace?) {
        super.init(nibName: nil, bundle: nil)
        self.workspace = workspace
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
        title = "채널 생성"
        configNav()
    }
    
}

extension ChangeManagerReactor {
    func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}

