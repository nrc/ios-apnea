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
    // `nil` => wait for user action
    // Invariant - first state time returned by a plan must be non-nil
    var time: Int?
    var label: String
}

class PlanDesc {
    var name: String
    var args: [String]
    var create: (_: [Int]) -> Plan
    
    init(name: String, args: [String], create: @escaping (_: [Int]) -> Plan) {
        self.name = name
        self.args = args
        self.create = create
    }
}

func planDescs() -> [PlanDesc] {
    return [
        PlanDesc.init(
            name: "O2 table",
            args: ["reps", "start time (s)", "increment (s)", "rest time (s)"],
            create: { (args: [Int]) -> Plan in
                return O2Plan.init(reps: args[0], startTime: args[1], increment: args[2], restTime: args[3])
            }
        ),
        PlanDesc.init(
            name: "CO2 table",
            args: ["reps", "time (s)", "starting rest time (s)", "increment (s)"],
            create: { (args: [Int]) -> Plan in
                return CO2Plan.init(reps: args[0], time: args[1], restTime: args[2], increment: args[3])
            }
        ),
        PlanDesc.init(
            name: "One breath CO2 table",
            args: ["reps", "time (s)"],
            create: { (args: [Int]) -> Plan in
                return OneBreathCO2Plan.init(reps: args[0], time: args[1])
            }
        ),
    ]
}

func defaultO2Plan() -> Plan {
    return O2Plan.init(reps: 6, startTime: 120, increment: 15, restTime: 120)
    // return O2Plan.init(reps: 3, startTime: 10, increment: 2, restTime: 3)
}

func testOneBreathCO2Plan() -> Plan {
    return OneBreathCO2Plan(reps: 3, time: 10)
}

class O2Plan: Plan {
    var reps: Int
    var time: Int
    var increment: Int
    var restTime: Int
    
    var resting: Bool = false
    
    init(reps: Int, startTime: Int, increment: Int, restTime: Int) {
        self.reps = reps
        self.time = startTime
        self.increment = increment
        self.restTime = restTime
    }
    
    func nextState() -> PlanState? {
        if reps <= 0 {
            return nil
        }
        
        if resting {
            resting = false
            let result = PlanState.init(time: self.time, label: "hold (\(reps))")
            reps -= 1
            self.time += self.increment
            return result
        } else {
            resting = true
            return PlanState.init(time: self.restTime, label: "rest (\(reps))")
        }
    }
}

class CO2Plan: Plan {
    var reps: Int
    var time: Int
    var increment: Int
    var restTime: Int
    
    var resting: Bool = false
    
    init(reps: Int, time: Int, restTime: Int, increment: Int) {
        self.reps = reps
        self.time = time
        self.restTime = restTime
        self.increment = increment
    }
    
    func nextState() -> PlanState? {
        if reps <= 0 {
            return nil
        }
        
        if resting {
            resting = false
            let result = PlanState.init(time: self.time, label: "hold (\(reps))")
            reps -= 1
            self.restTime -= self.increment
            return result
        } else {
            resting = true
            return PlanState.init(time: self.restTime, label: "rest (\(reps))")
        }
    }
}

class OneBreathCO2Plan: Plan {
    var reps: Int
    var time: Int
    
    var resting: Bool = true
    
    init(reps: Int, time: Int) {
        self.reps = reps
        self.time = time
    }
    
    func nextState() -> PlanState? {
        if reps <= 0 {
            return nil
        }
        
        if resting {
            resting = false
            let result = PlanState.init(time: self.time, label: "hold (\(reps))")
            reps -= 1
            return result
        } else {
            resting = true
            return PlanState.init(time: nil, label: "one breath (\(reps))")
        }
    }
}
