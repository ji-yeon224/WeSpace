//
//  PortonePurchaseManager.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import UIKit
import WebKit
import iamport_ios
import RxSwift

final class PortonePurchaseManager {
    
    //    private var amount: String?
    //    private var name: String
    private var webView: WKWebView?
    private var payment: IamportPayment?
    let purchaseResponse = PublishSubject<(Bool, PortOneValidationReqDTO?)>()
    var disposeBag = DisposeBag()
    
    static let shared = PortonePurchaseManager()
    private init() { }
    
    private func config(amount: String, name: String) -> IamportPayment {
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(APIKey.key)_\(Int(Date().timeIntervalSince1970))",
            amount: amount).then {
                $0.pay_method = PayMethod.card.rawValue
                $0.name = name
                $0.buyer_name = "김지연"
                $0.app_scheme = "sesac"
            }
    }
    
    func requirePurchase(webView: WKWebView, amount: String, name: String) {
        let payment = config(amount: amount, name: name)
        Iamport.shared.paymentWebView(webViewMode: webView,
                                      userCode: APIKey.userCode, payment: payment) { [weak self] iamportResponse in
            guard let self = self else { return }
            if let response = iamportResponse {
                self.completePurchase(data: response)
            } else {
                debugPrint(#function, "PURCHASE REQUIRE ERROR")
            }
            
        }
    }
    
    private func completePurchase(data: IamportResponse) {
        if let success = data.success, success {
            if let imp_uid = data.imp_uid, let merchant_uid = data.merchant_uid {
                purchaseResponse.onNext((true, PortOneValidationReqDTO(imp_uid: imp_uid, merchant_uid: merchant_uid)))
                
            } else {
                purchaseResponse.onNext((false, nil))
            }
            
        } else {
            if let error_msg = data.error_msg, let error_code = data.error_code {
                debugPrint("PURCHASE ERROR ", error_code, error_msg)
                
            } else {
                debugPrint("PURCHASE ERROR")
            }
            purchaseResponse.onNext((false, nil))
        }
        
        purchaseResponse.onCompleted()
        
    }
    
    func closePortone() {
        Iamport.shared.close()
    }
}
