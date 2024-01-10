//
//  UIImage+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/10/24.
//

import UIKit

extension UIImage {
    func resize(width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let height = self.size.height * scale
        //        print(width, height)
        let size = CGSize(width: width, height: height)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { [weak self] context in
            guard let self = self else { return }
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return renderImage
    }
}
