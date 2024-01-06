//
//  UINavigationController+Extension.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/6/24.
//

import UIKit

extension UINavigationController {
    
    func setupBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = Constants.Color.white
        
       
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.isTranslucent = false
    }
    
}
