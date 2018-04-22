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
    var model: TimeModel!
    
    //MARK: Actions
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        self.model.start()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO stop/restart button
        // TODO plan selector
        // TODO log book
        model = TimeModel.init(plan: defaultO2Plan(), view: self)
        update()
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
    }
    
    func onStop() {
        UIApplication.shared.isIdleTimerDisabled = false;
    }
}

