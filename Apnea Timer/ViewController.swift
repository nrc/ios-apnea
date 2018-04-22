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
    
    //MARK: Actions
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        self.model.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO log book
        setModel()
        update()
    }
    
    func setModel() {
        // TODO plan selector
        model = TimeModel.init(plan: testOneBreathCO2Plan(), view: self)
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
        toolBar.items![3] = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(ViewController.tapStopButton))
    }
    
    func onStop() {
        UIApplication.shared.isIdleTimerDisabled = false;
        toolBar.items![3] = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(ViewController.tapRestartButton))
    }
    
    @objc func tapStopButton() {
        model.stop()
    }
    
    @objc func tapRestartButton() {
        setModel()
        update()
    }
}
