//
//  MeterViewController.swift
//  GraphView
//
//  Created by Mohamed Ayadi on 11/6/16.
//
//

import UIKit
import SFGaugeView


class MeterViewController: UIViewController {

    @IBOutlet weak var meterView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Meter config
        
        //        Set up parameters
        //
        //        maxlevel = The maximum level of gauge control (unsigned int value)
        //        minlevel = The minimum level of gauge control (unsigned int value)
        //        needleColor = Color of needle
        //        bgColor = Background Color of gauge control
        //        hideLevel = If set to YES the current level is hidden
        //        minImage = An image for min level (see screenshot)
        //        maxImage = An image for max level (see screenshot)
        //        currentLevel = Sets the current Level
        //        autoAdjustImageColors = Overlays the images with needleColor (default: NO)
        //
        
        let SFGauge = SFGaugeView(frame: meterView.frame)
        SFGauge.bgColor = UIColor.colorFromHex(hexString: "#add8e6")
        SFGauge.needleColor = UIColor.colorFromHex(hexString: "#000080")
        SFGauge.backgroundColor = UIColor.colorFromHex(hexString: "#464646")
        SFGauge.maxlevel = 81
        SFGauge.minlevel = 0
        SFGauge.currentLevel = 10
        
        meterView.addSubview(SFGauge)
      

    }
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: false) { 
            
        }
    }


}
