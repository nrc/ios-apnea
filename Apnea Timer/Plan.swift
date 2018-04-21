//
//  Plan.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 21/04/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import Foundation

protocol Plan {
    // Invariant - must return at least one state before terminating
    func nextState() -> PlanState?
}

// TODO handle user-controlled rests
struct PlanState {
    var time: Int
    var label: String
}

func defaultO2Plan() -> Plan {
    return O2Plan.init(sets: 6, time: 180, restTime: 120)
}

// TODO time should increase with each set
class O2Plan: Plan {
    var sets: Int
    var time: Int
    var restTime: Int
    
    var resting: Bool = false
    var curSet: Int = 0
    
    init(sets: Int, time: Int, restTime: Int) {
        self.sets = sets
        self.time = time
        self.restTime = restTime
    }
    
    func nextState() -> PlanState? {
        if curSet >= sets {
            return nil
        }
        
        if resting {
            resting = false
            curSet += 1
            return PlanState.init(time: self.time, label: "hold")
        } else {
            resting = true
            return PlanState.init(time: self.restTime, label: "rest")
        }
    }
}
