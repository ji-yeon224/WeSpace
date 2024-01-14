//
//  WorkspaceListViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/13/24.
//

import UIKit
import SideMenu
import RxGesture

final class WorkspaceListViewController: BaseViewController {
    
    private let mainView = WorkspaceListView()
    weak var delegate: WorkSpaceListDelegate?
    override func loadView() {
        self.view = mainView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.viewDisappear()
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.viewAppear()
    }
    
    
}
