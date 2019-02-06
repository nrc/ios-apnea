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
    // the timer calls the plan's onStop when it is stopped, either by the plan or by the user
    func onStop(elapsedSeconds: Int)
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
                return O2Plan.init(desc: desc, reps: args[0], startTime: args[1], increment: args[2], restTime: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(2),
            name: "O2 table (exhale)",
            args: ["reps", "start time (s)", "increment (s)", "rest time (s)"],
            defaults: [7, 30, 10, 60],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return O2Plan.init(desc: desc, reps: args[0], startTime: args[1], increment: args[2], restTime: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(4),
            name: "CO2 table",
            args: ["reps", "time (s)", "starting rest time (s)", "increment (s)"],
            defaults: [6, 120, 120, 15],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return CO2Plan.init(desc: desc, reps: args[0], time: args[1], restTime: args[2], increment: args[3])
            }
        ),
        PlanDesc.init(
            id: PlanId.init(3),
            name: "One breath CO2 table",
            args: ["reps", "time (s)"],
            defaults: [6, 95],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return OneBreathCO2Plan.init(desc: desc, reps: args[0], time: args[1])
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
        PlanDesc.init(
            id: PlanId.init(6),
            name: "Breathe",
            args: ["reps", "inhale", "exhale"],
            defaults: [15, 5, 7],
            create: { (desc: PlanDesc, args: [Int]) -> Plan in
                return BreathePlan.init(desc: desc, reps: args[0], inhale: args[1], exhale: args[2])
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
    
    var record: Run
    var desc: PlanDesc

    init(desc: PlanDesc, reps: Int, startTime: Int, increment: Int, restTime: Int) {
        self.reps = reps
        self.time = startTime
        self.increment = increment
        self.restTime = restTime

        self.desc = desc
        self.record = Run.init(desc: desc)
        self.record.args[0].value = reps
        self.record.args[1].value = startTime
        self.record.args[2].value = increment
        self.record.args[3].value = restTime
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
        return O2Plan.init(desc: desc, reps: self.reps, startTime: self.time, increment: self.increment, restTime: self.restTime)
    }

    func getRecord() -> Run? {
        if reps > 0 {
            let completedReps = self.record.args[0].value - reps
            record.completedReps = completedReps
            if completedReps == 0 {
                return nil
            }
        }
        return record
    }
    func onStop(elapsedSeconds: Int) {
        // FIXME record the time for the set where the user stopped as a detail
    }
}

class CO2Plan: Plan {
    var reps: Int
    var time: Int
    var increment: Int
    var restTime: Int
    
    var resting: Bool = false
    
    var record: Run
    var desc: PlanDesc

    init(desc: PlanDesc, reps: Int, time: Int, restTime: Int, increment: Int) {
        self.reps = reps
        self.time = time
        self.restTime = restTime
        self.increment = increment
        
        self.desc = desc
        self.record = Run.init(desc: desc)
        self.record.args[0].value = reps
        self.record.args[1].value = time
        self.record.args[2].value = restTime
        self.record.args[3].value = increment
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
            var rest: Int? = self.restTime
            if rest! < 0 {
                rest = nil
            }
            return PlanState.init(time: rest, label: "rest (\(reps))")
        }
    }
    
    func clone() -> Plan {
        return CO2Plan.init(desc: desc, reps: self.reps, time: self.time, restTime: self.restTime, increment: self.increment)
    }

    func getRecord() -> Run? {
        if reps > 0 {
            let completedReps = self.record.args[0].value - reps
            record.completedReps = completedReps
            if completedReps == 0 {
                return nil
            }
        }
        return record
    }
    func onStop(elapsedSeconds: Int) {
        // FIXME record the time for the set where the user stopped as a detail
    }
}

class OneBreathCO2Plan: Plan {
    var reps: Int
    var time: Int
    
    var resting: Bool = true
    
    var record: Run
    var desc: PlanDesc
    
    init(desc: PlanDesc, reps: Int, time: Int) {
        self.desc = desc
        self.record = Run.init(desc: desc)
        self.record.args[0].value = reps
        self.record.args[1].value = time

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
            record.details.append(RunArg.init(name: "rest (s)", value: elapsedSeconds!))
            return result
        } else {
            resting = true
            return PlanState.init(time: nil, label: "one breath (\(reps))")
        }
    }
    
    func clone() -> Plan {
        return OneBreathCO2Plan.init(desc: self.desc, reps: self.reps, time: self.time)
    }

    func getRecord() -> Run? {
        if record.details.count < self.record.args[0].value {
            record.completedReps = record.details.count
        }
        if record.details.count == 0 {
            return nil
        } else {
            return record
        }
    }
    func onStop(elapsedSeconds: Int) {
        // FIXME record the time for the set where the user stopped as a detail
        // We can't do this just yet, because we rely on the number of details being the number of reps
    }
}

class MaxPlan: Plan {
    enum State {
        case Fresh
        case WarmUpRest
        case WarmUp
        case MaxRest
        case Max
        case Done
        
        func next() -> State {
            switch self {
            case State.Fresh:
                return State.WarmUpRest
            case State.WarmUpRest:
                return State.WarmUp
            case State.WarmUp:
                return State.MaxRest
            case State.MaxRest:
                return State.Max
            case State.Max:
                return State.Done
            case State.Done:
                return State.Done
            }
        }
        
        func planState() -> PlanState? {
            switch self {
            case State.Fresh:
                fatalError()
            case State.WarmUpRest:
                return PlanState.init(time: 120, label: "rest")
            case State.WarmUp:
                return PlanState.init(time: 120, label: "hold")
            case State.MaxRest:
                return PlanState.init(time: 300, label: "rest")
            case State.Max:
                return PlanState.init(time: nil, label: "max hold")
            case State.Done:
                return nil
            }
        }
    }
    
    var curState: State = State.Fresh
    var record: Run
    var desc: PlanDesc

    init(desc: PlanDesc) {
        self.desc = desc
        self.record = Run.init(desc: desc)
    }
   
    func nextState(elapsedSeconds: Int?) -> PlanState? {
        if curState == State.Done {
            fatalError()
        }
        curState = curState.next()
        let result = curState.planState()
        return result
    }
    
    func clone() -> Plan {
        return MaxPlan.init(desc: desc)
    }

    func getRecord() -> Run? {
        // Only record a run if we made it to the warm up
        if curState != State.WarmUpRest && curState != State.Fresh {
            return record
        } else {
            return nil
        }
    }

    func onStop(elapsedSeconds: Int) {
        if curState == State.Max || curState == State.Done {
            record.details.append(RunArg.init(name: "Max hold (s)", value: elapsedSeconds))
        } else {
            record.completedReps = 0
            if curState == State.WarmUp {
                record.details.append(RunArg.init(name: "Warm up (s)", value: elapsedSeconds))
            }
        }

        curState = State.Done
    }
}

class BreathePlan: Plan {
    var reps: Int
    var inhale: Int
    var exhale: Int
    
    var record: Run
    var desc: PlanDesc
    
    var inhaling: Bool = false
    
    init(desc: PlanDesc, reps: Int, inhale: Int, exhale: Int) {
        self.reps = reps
        self.inhale = inhale
        self.exhale = exhale
        
        self.desc = desc
        self.record = Run.init(desc: desc)
        self.record.args[0].value = reps
        self.record.args[1].value = inhale
        self.record.args[2].value = exhale
    }
    
    func nextState(elapsedSeconds: Int?) -> PlanState? {
        if reps <= 0 && !inhaling {
            return nil
        }

        inhaling = !inhaling
        if inhaling {
            reps -= 1
            return PlanState.init(time: inhale, label: "inhale")
        }
        
        return PlanState.init(time: exhale, label: "exhale")
    }
    
    func clone() -> Plan {
        return BreathePlan.init(desc: desc, reps: self.reps, inhale: self.inhale, exhale: self.exhale)
    }
    
    func getRecord() -> Run? {
        if reps > 0 {
            let completedReps = self.record.args[0].value - reps
            record.completedReps = completedReps
            if completedReps == 0 {
                return nil
            }
        }
        return record
    }
    func onStop(elapsedSeconds: Int) {}
}
