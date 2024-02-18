//
//  BaseTableViewCell.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/8/24.
//

import UIKit
import SnapKit
import Then

class BaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() { }
    
    func setConstraints() {
        
    }
    
    
    
}
