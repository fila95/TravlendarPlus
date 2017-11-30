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
    
    let realm: Realm = try! Realm()
    
    init() {
        // Get our Realm file's parent directory
        let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
        
        print("Realm Folder: \(folderPath)")
        
        // Disable file protection for this directory to enable background fetch
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: folderPath)
    }
    
}
