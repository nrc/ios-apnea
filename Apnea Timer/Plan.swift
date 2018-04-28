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
    func clone() -> Plan
}

struct PlanState {
    // `nil` => wait for user action
    // Invariant - first state time returned by a plan must be non-nil
    var time: Int?
    var label: String
}

// PlanIds should be constant over time, i.e., if a PlanDesc changes, it's id must change too.
// They don't need to be sequential, but there must not be duplicates.
// Current largest id used: 4
struct PlanId: Equatable {
    let value: Int
    
    init(_ value: Int) {
        self.value = value
    }
}

class PlanDesc {
    var id: PlanId
    var name: String
    var args: [String]
    var defaults: [Int]
    var create: (_: [Int]) -> Plan
    
    init(id: PlanId, name: String, args: [String], defaults: [Int], create: @escaping (_: [Int]) -> Plan) {
        self.id = id
        self.name = name
        assert(args.count == defaults.count)
        self.args = args
        self.defaults = defaults
        self.create = create
    }
    
    func makeDefault() -> Plan {
        return self.create(self.defaults)
    }
}

func planDescs() -> [PlanDesc] {
    return [
        PlanDesc.init(
            id: PlanId.init(0),
            name: "O2 table",
            args: ["reps", "start time (s)", "increment (s)", "rest time (s)"],
            defaults: [6, 120, 15, 120],
            create: { (args: [Int]) -> Plan in
                return O2Plan.init(reps: args[0], startTime: args[1], increment: args[2], restTime: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(2),
            name: "O2 table (exhale)",
            args: ["reps", "start time (s)", "increment (s)", "rest time (s)"],
            defaults: [7, 30, 10, 60],
            create: { (args: [Int]) -> Plan in
                return O2Plan.init(reps: args[0], startTime: args[1], increment: args[2], restTime: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(4),
            name: "CO2 table",
            args: ["reps", "time (s)", "starting rest time (s)", "increment (s)"],
            defaults: [6, 120, 120, 15],
            create: { (args: [Int]) -> Plan in
                return CO2Plan.init(reps: args[0], time: args[1], restTime: args[2], increment: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(3),
            name: "One breath CO2 table",
            args: ["reps", "time (s)"],
            defaults: [6, 95],
            create: { (args: [Int]) -> Plan in
                return OneBreathCO2Plan.init(reps: args[0], time: args[1])
            }
        ),
    ]
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
    
    func clone() -> Plan {
        return O2Plan.init(reps: self.reps, startTime: self.time, increment: self.increment, restTime: self.restTime)
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
    
    func clone() -> Plan {
        return CO2Plan.init(reps: self.reps, time: self.time, restTime: self.restTime, increment: self.increment)
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
    
    func clone() -> Plan {
        return OneBreathCO2Plan.init(reps: self.reps, time: self.time)
    }
}
