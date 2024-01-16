//
//  AlertViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/16/24.
//

import UIKit
import SnapKit

import RxCocoa
import RxSwift

final class AlertViewController: BaseViewController {
    
    private let alertWithOKView = AlertWithOKView()
    private let alertWithCancelView = AlertWithCancelView()
    private let disposeBag = DisposeBag()
    
    weak var delegate: AlertDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .alpha
        view.addSubview(alertWithOKView)
        view.addSubview(alertWithCancelView)
        setConstraints()
        bindAction()
    }
    
    private func setConstraints() {
        alertWithOKView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        alertWithCancelView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
    
    func showAlertWithOK(title: String, message: String) {
        alertWithCancelView.isHidden = true
        alertWithOKView.isHidden = false
        alertWithOKView.titleLabel.text = title
        alertWithOKView.messageLabel.text = message
        
    }
    
    func showAlertWithCancel(title: String, message: String, okText: String = "확인") {
        alertWithCancelView.isHidden = false
        alertWithOKView.isHidden = true
        alertWithCancelView.titleLabel.text = title
        alertWithCancelView.messageLabel.text = message
        alertWithCancelView.okButton.setTitle(okText, for: .normal)
    }
    
    private func bindAction() {
        alertWithOKView.okButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.delegate?.okButtonTap()
                owner.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
        
        alertWithCancelView.okButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.delegate?.okButtonTap()
                owner.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
        
        alertWithCancelView.cancelButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.delegate?.cancelButtonTap()
                owner.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    
    
    
}
