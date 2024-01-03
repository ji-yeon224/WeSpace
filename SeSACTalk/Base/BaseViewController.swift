//
//  BaseViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        view.backgroundColor = Constants.Color.background
    }
    
}
