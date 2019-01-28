//
//  ViewController.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 1/01/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TimeView {
    //MARK: Properties
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!

    var model: TimeModel!
    var plan: Plan!
    var planMemo: ConfigMemo!
    
    //MARK: Actions
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        self.model.start()
    }

    @IBAction func unwindFromConfigure(sender: UIStoryboardSegue) {
        if let configController = sender.source as? ConfigureController, let plan = configController.savedPlan {
            self.plan = plan.0
            planMemo = plan.1
            setModel()
            update()
        }
    }

    @IBAction func unwindFromLogBook(sender: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Try to initialise the plan from the last logged session. If that
        // fails because the log book is empty, or we don't have the plan
        // description any more, use the first default plan.
        let logBook = DataManager.getDataManager().records
        var initedPlan = false
        if let last = logBook.last {
            let descs = planDescs()
            for desc in descs {
                if desc.id == last.plan {
                    plan = desc.make(args: last.args.map { $0.value })
                    planMemo = memo(fromRun: last)
                    initedPlan = true
                    break
                }
            }
        }
        if !initedPlan {
            let defaultDesc = planDescs()[0]
            plan = defaultDesc.makeDefault()
            planMemo = memo(fromDescDefaults: defaultDesc)
        }
        setModel()
        update()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            if let configController = navigationController.topViewController as? ConfigureController {
                configController.curMemo = planMemo
            }
        }
    }
    
    func setModel() {
        model = TimeModel.init(plan: plan.clone(), view: self, beeper: BeepVibrate.init())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func update() {
        timerLabel.text = model.timeLabel()
        actionLabel.text = model.textLabel()
    }
    
    func onStart() {
        UIApplication.shared.isIdleTimerDisabled = true;
        toolBar.items![5] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(ViewController.tapStopButton))
    }
    
    func onStop() {
        UIApplication.shared.isIdleTimerDisabled = false;
        toolBar.items![5] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(ViewController.tapRestartButton))
    }
    
    @objc func tapStopButton() {
        model.stop()
    }
    
    @objc func tapRestartButton() {
        setModel()
        update()
    }
}
