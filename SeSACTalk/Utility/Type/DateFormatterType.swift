//
//  DateFormatterType.swift
//  SeSACTalk
//
//  Created by 김지연 on 2/7/24.
//

import Foundation

enum DateFormatterType: String {
    case fullDate = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case time1 = "hh:mm a"
    case time2 = "a hh:mm"
    case yearByDot = "yy. MM. dd"
    case yearByLan = "yyyy년 MM월 dd일"
}
