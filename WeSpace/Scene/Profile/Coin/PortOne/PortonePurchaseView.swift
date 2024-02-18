//
//  PortonePurchaseView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/16/24.
//

import UIKit
import WebKit

final class PortonePurchaseView: BaseView {
    let webView = WKWebView().then {
        $0.backgroundColor = .clear
    }
    
    override func configure() {
        addSubview(webView)
    }
    
    override func setConstraints() {
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
