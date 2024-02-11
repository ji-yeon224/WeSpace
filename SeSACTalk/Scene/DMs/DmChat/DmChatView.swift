//
//  DmChatView.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/8/24.
//

import UIKit

final class DmChatView: BaseView {
    
    lazy var tableView = UITableView(frame: .zero).then {
        $0.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 300
        $0.separatorStyle = .none
        $0.keyboardDismissMode = .onDrag
    }
    var tabledataSource: UITableViewDiffableDataSource<String, DmChat>!
    
    private let bottomView = UIStackView().then {
        $0.backgroundColor = .white
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: .zero, right: 16)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    let chatWriteView = ChatWriteView()
    
    override func configure() {
        backgroundColor = Constants.Color.secondaryBG
        
        addSubview(tableView)
        addSubview(bottomView)
        bottomView.addArrangedSubview(chatWriteView)
        configureDataSource()
    }
    
    override func setConstraints() {
        
        tableView.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).inset(16)
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(bottomView.snp.top).offset(-5)
        }
        
        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-8)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    
    
    private func configureDataSource() {
        
        tabledataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as? ChatTableViewCell else { return UITableViewCell() }
            
            cell.selectionStyle = .none
            
            cell.nickNameLabel.text = itemIdentifier.user?.nickname
            if let profileImg = itemIdentifier.user?.profileImage, !profileImg.isEmpty {
                cell.profileImageView.setImage(with: profileImg)
            } else {
                let img = Constants.Image.dummyProfile
                cell.profileImageView.image = img[(itemIdentifier.user?.userId ?? 0)%3]
            }
            
            if let text = itemIdentifier.content, !text.isEmpty {
                cell.chatTextLabel.text = itemIdentifier.content
                cell.chatMsgView.isHidden = false
            } else {
                cell.chatMsgView.isHidden = true
            }
            
            cell.timeLabel.text = itemIdentifier.createdAt.convertToTimeString
            if !itemIdentifier.files.isEmpty {

                if let imgUrls = itemIdentifier.imgUrls, !imgUrls.isEmpty{
                    
                    let imgs = ChannelRepository().loadImageFromDocuments(fileName: imgUrls)
                    
                    if imgs.count > 0 {
                        cell.configUIImage(imgs: imgs)
                    } else {
                        cell.configImage(files: itemIdentifier.files)
                    }
                    
                }else {
                    cell.configImage(files: itemIdentifier.files)
                }
                
                cell.chatImgView.isHidden = false
                cell.stackView.isHidden = false
                cell.layoutSubviews()
            } else {
                cell.chatImgView.isHidden = true
                cell.stackView.isHidden = true
            }
            
            return cell
        })
    }
    
    
}
