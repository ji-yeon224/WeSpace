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
    private var amount: String?
    private var name: String?
    private var item: CoinItem?
    
    private var disposeBag = DisposeBag()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PortonePurchaseManager.shared.closePortone()
        mainView.willRemoveSubview(mainView.webView)
        mainView.webView.stopLoading()
        mainView.webView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "결제하기"
        if let item = item {
            PortonePurchaseManager.shared.requirePurchase(webView: mainView.webView, amount: item.amount, name: item.item)
        }
        
        PortonePurchaseManager.shared.purchaseResponse
            .subscribe(with: self) { owner, value in
                print("@@@@@")
                owner.delegate?.purchaseResponse(success: value.0, data: value.1, item: owner.item)
                owner.navigationController?.popViewController(animated: true)
                
                
            }
            .disposed(by: PortonePurchaseManager.shared.disposeBag)
        
    }
    
    
    
    
}

