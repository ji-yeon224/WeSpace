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
    
    private var requestItemList = PublishRelay<Void>()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func configure() {
        super.configure()
        self.reactor = CoinReactor()
        mainView.delegate = self
        configNav()
        requestItemList.accept(())
    }
    
    private func configData(item: [CoinItem]) -> [CoinSectionModel] {
        
        let section1 = [CoinCollectionItem(count: coin, item: nil)]
        let itemListSection = item.map { CoinCollectionItem(count: nil, item: $0)}
        let data = [
            CoinSectionModel(section: 0, items: section1),
            CoinSectionModel(section: 1, items: itemListSection)
        ]
        return data
    }
    
    
}

extension CoinViewController: CoinPurchaseDelegate {
    func purchaseCoin(item: CoinItem) {
        print(item)
    }
}

extension CoinViewController: View {
    
    func bind(reactor: CoinReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindEvent()
    }
    
    private func bindAction(reactor: CoinReactor) {
        requestItemList
            .map { Reactor.Action.requestItemList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: CoinReactor) {
        reactor.state
            .map { $0.msg }
            .filter { $0 != .none }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, value in
                if let value = value {
                    owner.showToastMessage(message: value, position: .bottom)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.loginRequest }
            .filter { $0 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, value in
                print("login request")
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.itemList }
            .filter { !$0.isEmpty }
            .asDriver(onErrorJustReturn: [])
            .map {
                return self.configData(item: $0)
            }
            .drive(mainView.collectionView.rx.items(dataSource: mainView.rxdataSource))
            .disposed(by: disposeBag)
        
    }
    
    private func bindEvent() {
//        coinItems
//            .bind(to: mainView.collectionView.rx.items(dataSource: mainView.rxdataSource))
//            .disposed(by: disposeBag)
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
