//
//  Database.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 28/11/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Foundation
import RealmSwift

public class Database {
    
    public static let shared: Database = Database()
    let queue = DispatchQueue(label: "background.realm")
    
    init() {
        // Get our Realm file's parent directory
        let realm: Realm = try! Realm()
        
        let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
        
        print("Realm Folder: \(folderPath)")
        
        // Disable file protection for this directory to enable background fetch
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath)
    }
    
    func realm(completion: @escaping ((_ realm: Realm) -> Void)) {
        DispatchQueue.main.async {
            autoreleasepool {
                completion(try! Realm())
            }
        }
        
    }
    
}
