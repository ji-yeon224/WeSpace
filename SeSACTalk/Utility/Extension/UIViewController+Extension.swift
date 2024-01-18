//
//  UIViewController+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/18/24.
//

import UIKit

extension UIViewController {
    func showPopUp(title: String,
                   message: String,
                   leftActionTitle: String? = nil,
                   rightActionTitle: String = "확인",
                   leftActionCompletion: (() -> Void)? = nil,
                   rightActionCompletion: (() -> Void)? = nil) {
        let alertViewController1 = AlertViewController1(titleText: title,
                                                      messageText: message)
        showPopUp(alertViewController1: alertViewController1,
                  leftActionTitle: leftActionTitle,
                  rightActionTitle: rightActionTitle,
                  rightActionCompletion: rightActionCompletion)
    }


    private func showPopUp(alertViewController1: AlertViewController1,
                           leftActionTitle: String?,
                           rightActionTitle: String,
                           leftActionCompletion: (() -> Void)? = nil,
                           rightActionCompletion: (() -> Void)?) {
        
        if let leftActionTitle = leftActionTitle {
            alertViewController1.addActionToButton(title: leftActionTitle,
                                                  backgroundColor: .inactive) {
                alertViewController1.dismiss(animated: false, completion: leftActionCompletion)
            }
        }
        

        alertViewController1.addActionToButton(title: rightActionTitle,
                                              backgroundColor: .brand) {
            alertViewController1.dismiss(animated: false, completion: rightActionCompletion)
        }
        present(alertViewController1, animated: false, completion: nil)
    }
}
