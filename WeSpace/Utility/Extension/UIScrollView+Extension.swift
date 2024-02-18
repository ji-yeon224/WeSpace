//
//  UIScrollView+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/2/24.
//

import UIKit

extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
//    func scrollToBottom() {
//        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
//        if(bottomOffset.y > 0) {
//            setContentOffset(bottomOffset, animated: true)
//        }
//    }
}
