//
//  CoinView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/14/24.
//

import UIKit
import RxDataSources

final class CoinView: BaseView {
    
    weak var delegate: CoinPurchageDelegate?
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(CoinCollectionCell.self, forCellWithReuseIdentifier: CoinCollectionCell.identifier)
    }
    
    var rxdataSource: RxCollectionViewSectionedReloadDataSource<CoinSectionModel>!
    
    override func configure() {
        super.configure()
        addSubview(collectionView)
        configDataSource()
    }
    
    override func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = false
        configuration.backgroundColor = .background
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
    
    private func configDataSource() {
        
        rxdataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CoinCollectionCell.identifier, for: indexPath) as? CoinCollectionCell else { return UICollectionViewCell() }
            
            cell.setCellComponents(section: indexPath.section)
            if indexPath.section == 0 {
                cell.cellTitle.text = "🌱 현재 보유한 코인"
                if let coin = item.coin {
                    cell.coinCountLabel.text = "\(coin)개"
                }
                
            }
            else {
                
                if let coin = item.coin, let price = item.price {
                    cell.cellTitle.text = "🌱 \(coin) Coin"
                    cell.buyButton.setTitle("₩\(price)", for: .normal)
                    cell.buyButton.rx.tap
                        .bind(with: self) { owner, _ in
                            if let coin = item.coin, let price = item.price {
                                owner.delegate?.purchaseCoin(count: coin, price: price)
                            }
                        }
                        .disposed(by: cell.disposeBag)
                }
                
            }
            
            return cell
        })
    }
    
    
}
