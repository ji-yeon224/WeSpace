//
//  PortonePurchaseViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import UIKit
import WebKit
import iamport_ios
import RxSwift

final class PortonePurchaseViewController: BaseViewController {
    
    private let mainView = PortonePurchaseView()
    private var item: CoinItem?
    
    weak var delegate: PortOneResponseDelegate?
    
    override func loadView() {
        self.view = mainView
    }
    
    init(item: CoinItem) {
        super.init(nibName: nil, bundle: nil)
        self.item = item
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configNav()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        mainView.willRemoveSubview(mainView.webView)
        mainView.webView.stopLoading()
        mainView.webView.removeFromSuperview()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        PortonePurchaseManager.shared.closePortone()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "결제하기"
        if let item = item {
            PortonePurchaseManager.shared.requirePurchase(webView: mainView.webView, amount: item.amount, name: item.item)
        }
        
        PortonePurchaseManager.shared.purchaseResponse
            .subscribe(with: self) { owner, value in
                owner.delegate?.purchaseResponse(success: value.0, data: value.1, item: owner.item)
                owner.navigationController?.popViewController(animated: true)
                
                
            }
            .disposed(by: PortonePurchaseManager.shared.disposeBag)
        
    }
    
    
    
    
}

extension PortonePurchaseViewController {
    private func configNav() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
    }
    
    @objc private func backButtonTapped() {
        showPopUp(title: Text.purchaseBackButton, message: Text.purchaseBackMsg, align: .center, cancelTitle: "취소", okTitle: "확인", cancelCompletion: nil) {
            self.navigationController?.popViewController(animated: true)
        }

        
    }
}

