//
//  ReusableProtocol.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/18/24.
//

import Foundation
import UIKit

protocol ReusableProtocol {
    static var identifier: String { get }
}

extension UICollectionViewCell: ReusableProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
