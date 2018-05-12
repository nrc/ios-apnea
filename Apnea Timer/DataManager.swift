//
//  DataManager.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 5/05/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import Foundation

class DataManager {
    internal static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    internal static let ArchiveURL = DocumentsDirectory.appendingPathComponent("runs")

    internal static var singleton: DataManager?
    
    static func getDataManager() -> DataManager {
        // FIXME rather than loading lazily, we might want to pre-load at some point
        if let singleton = singleton {
            return singleton
        }
        
        singleton = DataManager()
        return singleton!
    }
    
    var records: [Run]
    
    init() {
        var records = DataManager.loadRecords()
        if records == nil {
            records = []
        }
        self.records = records!
    }
    
    func append(record: Run) {
        records.append(record)
        save()
    }
    
    internal func save() {
        do {
            let data = try PropertyListEncoder().encode(records)
            try data.write(to: DataManager.ArchiveURL, options: .noFileProtection)
        } catch {
            print("run could not be encoded \(error)")
        }
    }
    
    internal static func loadRecords() -> [Run]? {
        do {
            let data = try Data(contentsOf: ArchiveURL)
            let records = try PropertyListDecoder().decode([Run].self, from: data)
            return records
        } catch {
            print("run could not be decoded \(error)")
            return nil
        }
    }
}

