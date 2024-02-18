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
                   align: NSTextAlignment? = .center,
                   cancelTitle: String? = nil,
                   okTitle: String = "확인",
                   cancelCompletion: (() -> Void)? = nil,
                   okCompletion: (() -> Void)? = nil) {
        let alertViewController = AlertViewController(titleText: title,
                                                      messageText: message,
                                                        textAligment: align
        )
        showPopUp(alertViewController: alertViewController,
                  cancelTitle: cancelTitle,
                  okTitle: okTitle,
                  cancelCompletion: cancelCompletion,
                  okCompletion: okCompletion)
    }


    private func showPopUp(alertViewController: AlertViewController,
                           cancelTitle: String?,
                           okTitle: String,
                           cancelCompletion: (() -> Void)? = nil,
                           okCompletion: (() -> Void)?) {
        
        if let cancelTitle = cancelTitle {
            alertViewController.addActionToButton(title: cancelTitle,
                                                  backgroundColor: .inactive) {
                alertViewController.dismiss(animated: false, completion: cancelCompletion)
            }
        }
        

        alertViewController.addActionToButton(title: okTitle,
                                              backgroundColor: .brand) {
            alertViewController.dismiss(animated: false, completion: okCompletion)
        }
        present(alertViewController, animated: false, completion: nil)
    }
}
