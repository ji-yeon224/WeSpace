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
        mainView.delegate = self
        configNav()
        bindEvent()
        configData()
    }
    
    private func configData() {
        
        let section1 = [CoinCollectionItem(coin: 10, price: nil)]
        let section2 = [
            CoinCollectionItem(coin: 10, price: 100),
            CoinCollectionItem(coin: 50, price: 500),
            CoinCollectionItem(coin: 100, price: 1000)
        ]
        let data = [
            CoinSectionModel(section: 0, items: section1),
            CoinSectionModel(section: 1, items: section2)
        ]
        coinItems.accept(data)
    }
    
    
}

extension CoinViewController: CoinPurchageDelegate {
    func purchaseCoin(count: Int, price: Int) {
        print(count, price)
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
