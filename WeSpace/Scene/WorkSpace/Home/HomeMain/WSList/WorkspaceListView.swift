//
//  WorkspaceListView.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/13/24.
//

import UIKit

final class WorkspaceListView: BaseView {
    
    weak var delegate: WorkSpaceListDelegate?
    
    var workspaceId = -1
    
    private let backView = UIView().then {
        $0.backgroundColor = Constants.Color.secondaryBG
        $0.layer.cornerRadius = 25
    }
    private let divider = UIView().then {
        $0.backgroundColor = .seperator
    }
    
    private let topView = UIView().then {
        $0.backgroundColor =  Constants.Color.background
    }
    
    private let titleLabel = CustomBasicLabel(text: "워크스페이스", fontType: .title1)
    
    // 워크스페이스 없을 때
    let emptyView = WorkspaceEmptyView()
    
    // 있을 때
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout()).then {
        $0.isHidden = true
    }
    
    var dataSource: UICollectionViewDiffableDataSource<String, WorkSpace>!
    
    
    
    let addWorkspaceView = WorkspaceListSettingView(img: .plus, title: "워크스페이스 추가")
    let helpView = WorkspaceListSettingView(img: .help, title: "도움말")
    
    
    override func configure() {
        backgroundColor = .clear
        
        
        addSubview(backView)
        
        [topView, divider, emptyView, collectionView, addWorkspaceView, helpView].forEach {
            backView.addSubview($0)
        }
        
        topView.addSubview(titleLabel)
        configDataSource()
    }
    
    override func setConstraints() {
        backView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
            make.width.equalTo(Constants.Design.deviceWidth / 1.3)
        }
        
        topView.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.top.horizontalEdges.equalTo(backView)
//            make.top.equalTo(safeAreaLayoutGuide)
        }
        setTopViewConstraints()
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(helpView.snp.top)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(3)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(helpView.snp.top)
        }
        
        helpView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(backView)
            make.height.equalTo(41)
        }
        addWorkspaceView.snp.makeConstraints { make in
            make.bottom.equalTo(helpView.snp.top)
            make.horizontalEdges.equalTo(backView)
            make.height.equalTo(41)
        }
        
    }
    
    private func setTopViewConstraints() {
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(topView).inset(16)
            make.leading.equalTo(topView).inset(18)
        }
       
    }
    
    func showWorkspaceList(show: Bool) {
        emptyView.isHidden = show
        collectionView.isHidden = !show
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let size = Constants.Design.deviceWidth / 1.3 - 5//self.frame.width - 40
        layout.itemSize = CGSize(width: size, height: 72)
        return layout
    }
    func configDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<WorkspaceListCell, WorkSpace> { cell, indexPath, itemIdentifier in
            cell.workspaceName.text = itemIdentifier.name
            cell.workspaceImageView.setImage(with: itemIdentifier.thumbnail)
            cell.dateLabel.text = itemIdentifier.createdAt.convertToDateFormat            
            if itemIdentifier.workspaceId == self.workspaceId {
                cell.backView.backgroundColor = .customGray
                cell.menuButton.isHidden = false
                cell.menuButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.delegate?.workspaceSettingTapped()
                    }
                    .disposed(by: cell.disposeBag)
            }
            
        }
        
        
        dataSource = UICollectionViewDiffableDataSource<String, WorkSpace>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            collectionView.layoutIfNeeded()
            return cell
        })
    }
}

