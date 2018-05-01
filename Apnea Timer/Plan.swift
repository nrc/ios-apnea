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
    func nextState(elapsedSeconds: Int?) -> PlanState?
    func clone() -> Plan
    func getRecord() -> Run?
}

struct PlanState {
    // `nil` => wait for user action
    // Invariant - first state time returned by a plan must be non-nil
    var time: Int?
    var label: String
}

// PlanIds should be constant over time, i.e., if a PlanDesc changes, it's id must change too.
// They don't need to be sequential, but there must not be duplicates.
// Current largest id used: 5
struct PlanId: Equatable, Codable {
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
    // The PlanDesc arg should always be `self`
    internal var create: (_: PlanDesc, _: [Int]) -> Plan
    
    init(id: PlanId, name: String, args: [String], defaults: [Int], create: @escaping (_: PlanDesc, _: [Int]) -> Plan) {
        self.id = id
        self.name = name
        assert(args.count == defaults.count)
        self.args = args
        self.defaults = defaults
        self.create = create
    }
    
    func makeDefault() -> Plan {
        return self.create(self, self.defaults)
    }
    
    func make(args: [Int]) -> Plan {
        return self.create(self, args)
    }
}

func planDescs() -> [PlanDesc] {
    return [
        PlanDesc.init(
            id: PlanId.init(0),
            name: "O2 table",
            args: ["reps", "start time (s)", "increment (s)", "rest time (s)"],
            defaults: [6, 120, 15, 120],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return O2Plan.init(reps: args[0], startTime: args[1], increment: args[2], restTime: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(2),
            name: "O2 table (exhale)",
            args: ["reps", "start time (s)", "increment (s)", "rest time (s)"],
            defaults: [7, 30, 10, 60],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return O2Plan.init(reps: args[0], startTime: args[1], increment: args[2], restTime: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(4),
            name: "CO2 table",
            args: ["reps", "time (s)", "starting rest time (s)", "increment (s)"],
            defaults: [6, 120, 120, 15],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return CO2Plan.init(reps: args[0], time: args[1], restTime: args[2], increment: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(3),
            name: "One breath CO2 table",
            args: ["reps", "time (s)"],
            defaults: [6, 95],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return OneBreathCO2Plan.init(reps: args[0], time: args[1])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(5),
            name: "Max hold",
            args: [],
            defaults: [],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return MaxPlan.init(desc: desc)
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
    
    func nextState(elapsedSeconds: Int?) -> PlanState? {
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

    // TODO
    func getRecord() -> Run? {
        return nil
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
    
    func nextState(elapsedSeconds: Int?) -> PlanState? {
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

    // TODO
    func getRecord() -> Run? {
        return nil
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
    
    func nextState(elapsedSeconds: Int?) -> PlanState? {
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

    // TODO
    func getRecord() -> Run? {
        return nil
    }
}

class MaxPlan: Plan {
    enum State {
        case WarmUpRest
        case WarmUp
        case MaxRest
        case Max
        
        func next() -> State? {
            switch self {
            case State.WarmUpRest:
                return State.WarmUp
            case State.WarmUp:
                return State.MaxRest
            case State.MaxRest:
                return State.Max
            case State.Max:
                return nil
            }
        }
        
        func planState() -> PlanState {
            switch self {
            case State.WarmUpRest:
                return PlanState.init(time: 120, label: "rest")
            case State.WarmUp:
                return PlanState.init(time: 120, label: "hold")
            case State.MaxRest:
                return PlanState.init(time: 300, label: "rest")
            case State.Max:
                return PlanState.init(time: nil, label: "max hold")
            }
        }
    }
    
    var curState: State? = State.WarmUpRest
    var record: Run
    var desc: PlanDesc

    init(desc: PlanDesc) {
        self.desc = desc
        self.record = Run.init(desc: desc)
    }
   
    func nextState(elapsedSeconds: Int?) -> PlanState? {
        guard let curState = self.curState else {
            return nil
        }
        if curState == State.Max {
            // TODO currently broken because the timer is not counting the hold
            record.details.append(RunArg.init(name: "Max hold (s)", value: elapsedSeconds!))
        }
        let result = curState.planState()
        self.curState = curState.next()
        return result
    }
    
    func clone() -> Plan {
        return MaxPlan.init(desc: desc)
    }

    func getRecord() -> Run? {
        // Only record a run if we made it pass the warm up
        if curState == nil {
            return record
        } else {
            return nil
        }
    }
}
