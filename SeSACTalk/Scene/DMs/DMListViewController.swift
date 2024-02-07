//
//  DMListViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import UIKit

final class DMListViewController: BaseViewController {
    
    private var workspaceId: Int?
    
    init(wsId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.workspaceId = wsId
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("dmvc")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("dmvw")
    }
    
    override func configure() {
        super.configure()
        navigationController?.navigationBar.isHidden = true
    }
    
    
}
