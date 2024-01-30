//
//  SearchChannelView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import UIKit
import RxDataSources

final class SearchChannelView: BaseView {
    
    private let separator = UIView().then {
        $0.backgroundColor = .seperator
    }
    
    let tableView = UITableView(frame: .zero).then {
        $0.register(SearchChannelCell.self, forCellReuseIdentifier: SearchChannelCell.identifier)
        $0.rowHeight = 41
        $0.separatorStyle = .none
    }
    
    var dataSource: RxTableViewSectionedReloadDataSource<ChannelSectionModel>!
    
    override func configure() {
        backgroundColor = .secondaryBackground
        addSubview(tableView)
        configDataSource()
    }
    
    override func setConstraints() {
        
        
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(self)
            make.top.equalTo(self).inset(3)
        }
    }
    
    private func configDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchChannelCell.identifier, for: indexPath) as? SearchChannelCell else { return UITableViewCell() }
            
            cell.selectionStyle = .none
            
            cell.channelNameLabel.text = item.name
            
            
            return cell
        })
    }
    
    
}


