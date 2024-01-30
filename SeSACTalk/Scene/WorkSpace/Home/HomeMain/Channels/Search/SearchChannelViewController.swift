//
//  SearchChannelViewController.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/30/24.
//

import UIKit
import ReactorKit

final class SearchChannelViewController: BaseViewController {
    
    private let mainView = SearchChannelView()
    private var channelItems: [Channel] = []
    private var items = PublishSubject<[ChannelSectionModel]>()
    
    var disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = mainView
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "채널 탐색"
        bindEvent()
        channelItems = [
            
            Channel(workspaceID: 1, channelID: 1, name: "qq", description: "qq", ownerID: 1, channelPrivate: 1, createdAt: "11"),
            Channel(workspaceID: 1, channelID: 1, name: "qq", description: "qq", ownerID: 1, channelPrivate: 1, createdAt: "11"),
            Channel(workspaceID: 1, channelID: 1, name: "qq", description: "qq", ownerID: 1, channelPrivate: 1, createdAt: "11")
        ]
        
        items.onNext([ChannelSectionModel(section: "", items: channelItems)])
        
    }
    
    
    override func configure() {
        configNav()
    }
    
    
    private func bindEvent() {
        
        items
            .bind(to: mainView.tableView.rx.items(dataSource: mainView.dataSource))
            .disposed(by: disposeBag)
        
        
    }
    
    
    
}

extension SearchChannelViewController {
    func configNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.Image.xmark, style: .plain, target: self, action: #selector(xButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Color.black
        
        navigationController?.setupBarAppearance()
    }
    @objc private func xButtonTapped() {
        dismiss(animated: true)
    }
}
