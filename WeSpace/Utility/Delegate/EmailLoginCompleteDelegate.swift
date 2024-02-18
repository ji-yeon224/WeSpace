//
//  EmailLoginCompleteDelegate.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/17/24.
//

import Foundation
protocol EmailLoginCompleteDelegate: AnyObject {
    func completeLogin(workspace: WorkSpace?)
}
