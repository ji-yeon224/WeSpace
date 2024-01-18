//
//  ChangeManagerViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/18/24.
//

import UIKit
import ReactorKit

final class ChangeManagerViewController: BaseViewController {
    
    private let mainView = ChangeManagerView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "워크스페이스 관리자 변경"
    }
    
    
    
    
}
