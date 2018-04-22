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

struct PlanState {
    // nil => wait for user action
    var time: Int?
    var label: String
}

func defaultO2Plan() -> Plan {
    return O2Plan.init(sets: 6, startTime: 120, increment: 15, restTime: 120)
    // return O2Plan.init(sets: 3, startTime: 10, increment: 2, restTime: 3)
}

class O2Plan: Plan {
    var sets: Int
    var time: Int
    var increment: Int
    var restTime: Int
    
    var resting: Bool = false
    
    init(sets: Int, startTime: Int, increment: Int, restTime: Int) {
        self.sets = sets
        self.time = startTime
        self.increment = increment
        self.restTime = restTime
    }
    
    func nextState() -> PlanState? {
        if sets <= 0 {
            return nil
        }
        
        if resting {
            resting = false
            let result = PlanState.init(time: self.time, label: "hold (\(sets))")
            sets -= 1
            self.time += self.increment
            return result
        } else {
            resting = true
            return PlanState.init(time: self.restTime, label: "rest (\(sets))")
        }
    }
}

// TODO other plans
