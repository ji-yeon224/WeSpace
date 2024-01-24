//
//  RealmProtocol.swift
//  SeSACTalk
//
//  Created by 김지연 on 1/24/24.
//


import Foundation
import RealmSwift


protocol RealmDB {
    func read<T: Object>(object: T.Type) -> Results<T>
    func write<T: Object>(object: [T])
}

class RealmManager: RealmDB {
    
    static let shared = RealmManager()
    
    let realm:Realm
    
    init() {
        realm = try! Realm()
    }
    
    func getRealmLocation() {
        print("=====Realm 경로: ", realm.configuration.fileURL!)
    }
    
    
    func read<T: Object>( object: T.Type) -> Results<T> {
        return realm.objects(object)
    }
    
    func write<T: Object>(object: [T])  {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print(error)
        }
    }
    
    
    
    
    
}
