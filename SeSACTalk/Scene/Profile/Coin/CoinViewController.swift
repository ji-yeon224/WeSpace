//
//  CoinViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import UIKit
import ReactorKit
import RxCocoa

final class CoinViewController: BaseViewController {
    
    
    private let mainView = CoinView()
    var disposeBag = DisposeBag()
    var coin = 0
    
    private var coinItems = PublishRelay<[CoinSectionModel]>()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func configure() {
        super.configure()
        configNav()
        bindEvent()
        configData()
    }
    
    private func configData() {
        
        let section1 = [CoinCollectionItem(title: "현재 보유한 코인", coin: "10개", price: nil)]
        let section2 = [
            CoinCollectionItem(title: "10 Coin", coin: nil, price: "₩100"),
            CoinCollectionItem(title: "50 Coin", coin: nil, price: "₩500"),
            CoinCollectionItem(title: "100 Coin", coin: nil, price: "₩1000")
        ]
        let data = [
            CoinSectionModel(section: 0, items: section1),
            CoinSectionModel(section: 1, items: section2)
        ]
        coinItems.accept(data)
    }
    
    
}

extension CoinViewController {
    private func bindEvent() {
        coinItems
            .bind(to: mainView.collectionView.rx.items(dataSource: mainView.rxdataSource))
            .disposed(by: disposeBag)
    }
}

extension CoinViewController {
    private func configNav() {
        title = "코인샵"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .left, style: .plain, target: self, action: #selector(backButtonTapped))
        
        navigationItem.leftBarButtonItem?.tintColor = .basicText
        navigationController?.setupBarAppearance()
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
