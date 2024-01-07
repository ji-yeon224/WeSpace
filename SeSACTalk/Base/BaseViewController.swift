//
//  BaseViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/2/24.
//

import UIKit
import Toast

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        view.backgroundColor = Constants.Color.background
    }
    func showToastMessage(message: String, position: ToastPosition) {
            
        var style = ToastStyle()
        style.backgroundColor = .brand
        style.messageFont = Font.body.fontStyle
        style.messageColor = Constants.Color.white
        
        DispatchQueue.main.async {
            self.view.makeToast(message, duration: 1.0, position: position, style: style)
        }
    }
}
