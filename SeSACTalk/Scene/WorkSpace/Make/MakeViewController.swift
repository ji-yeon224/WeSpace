//
//  MakeViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/7/24.
//

import UIKit

final class MakeViewController: BaseViewController {
    
    private let mainView = MakeView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configure() {
        super.configure()
        
    }
    
    
}
