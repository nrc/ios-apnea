//
//  DataManager.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 5/05/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import Foundation

internal struct Info {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("runs")
}

func save(record: Run) {
    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(record, toFile: Info.ArchiveURL.path)
    assert(isSuccessfulSave)
}

func loadRecords() -> [Run]? {
    return NSKeyedUnarchiver.unarchiveObject(withFile: Info.ArchiveURL.path) as? [Run]
}
