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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var curentLevelOfWater = 0.0

    var SFGauge = SFGaugeView()
    @IBOutlet weak var meterView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       self.meterConfig()
        //Getting the current usage from AWS
        self.getUserInfo()
        let helloWorldTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(MeterViewController.getUserInfo), userInfo: nil, repeats: true)

        

    }
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: false) { 
            
        }
    }
    func getUserInfo() {
        // Define server side script URL
        let scriptUrl = "http://ec2-54-84-48-230.compute-1.amazonaws.com/api/v1/device/history/firstDevice"
        let urlWithParams = scriptUrl + ""
        // Create NSURL Ibject
        let myUrl = NSURL(string: urlWithParams);
        
        // Creaste URL Request
        let request = NSMutableURLRequest(url:myUrl! as URL);
        
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "GET"
        
        // If needed you could add Authorization header value
        // Add Basic Authorization
        /*
         let username = "myUserName"
         let password = "myPassword"
         let loginString = NSString(format: "%@:%@", username, password)
         let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
         let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
         request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")
         */
        
        // Or it could be a single Authorization Token value
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    print(convertedJsonIntoDict)
                    
                    
                    // Get value by key
                    let res = convertedJsonIntoDict["results"]!

                        let twDataArray = (res as! NSArray) as Array
                    
                    print("should print first element on the history")
                    let num = (twDataArray.last?["amount"]!)
                    
                    self.curentLevelOfWater = num! as! Double
                    print(self.curentLevelOfWater)
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        self.SFGauge.currentLevel = Int(curentLevelOfWater)

    }
    
    func meterConfig(){
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
        SFGauge.frame = self.meterView.frame
//        SFGauge = SFGaugeView(frame: self.meterView.frame)
        SFGauge.bgColor = UIColor.colorFromHex(hexString: "#add8e6")
        SFGauge.needleColor = UIColor.colorFromHex(hexString: "#000080")
        SFGauge.backgroundColor = UIColor.colorFromHex(hexString: "#464646")
        SFGauge.maxImage = "unhappyWater"
        SFGauge.minImage = "happyWater"
        SFGauge.maxlevel = 81000
        SFGauge.minlevel = 0
        SFGauge.currentLevel = Int(self.curentLevelOfWater)
        
        self.meterView.addSubview(SFGauge)
        
        //End of meter config
    }

}
