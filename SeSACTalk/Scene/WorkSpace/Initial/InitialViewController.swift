//
//  InitialViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit

final class InitialViewController: BaseViewController {
    
    private let mainView = InitialView()
    
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "시작하기"
    }
    
    override func configure() {
        super.configure()
    }
    
    
    
}
