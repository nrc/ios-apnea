//
//  Run.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 1/05/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import Foundation

// A run is a recording of a single session of apnea training.

class Run: Codable {
    var plan: PlanId
    var description: String
    var args: [RunArg]
    var details: [RunArg] = []
    // nil = complete the whole plan
    var completedReps: Int? = nil
    
    init(desc: PlanDesc) {
        self.plan = desc.id
        self.description = desc.name
        self.args = desc.args.map { RunArg.init(name: $0) }
    }
}

struct RunArg: Codable {
    var name: String
    var value: Int = 0
    
    init(name: String) {
        self.name = name
    }
    
    init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}
