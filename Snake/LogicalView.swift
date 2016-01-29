//
//  LogicalView.swift
//  Snake
//
//  Created by mhtran on 2/4/15.
//  Copyright (c) 2015 mhtran. All rights reserved.
//

import UIKit
import GoogleMobileAds
class MyBannerView: GADBannerView, GADBannerViewDelegate {
    
}
class LogicalView: UIViewController, GADBannerViewDelegate{

    var credit: UILabel?
    var vc = MainVC()
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var backGround: UIImageView!
   
  
    @IBOutlet weak var play: UILabel!
    
    @IBOutlet weak var fff: UIButton!
    
    @IBAction func playB(sender: AnyObject) {

        self.presentViewController(MainVC(), animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        NSLog("push")

    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
        let centerP = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        fff?.center = CGPoint(x: centerP.x  * 8/6, y: centerP.y * 3/2)
        play?.center = CGPoint(x: centerP.x , y: centerP.y * 3/2)
        credit = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        credit?.text = "credit by abtranbn"

        
        credit?.textAlignment = NSTextAlignment.Center
        credit?.center = CGPoint(x: centerP.x , y: centerP.y * 2 - 100)
        credit?.font = UIFont (name: "Zapfino", size: 8)
        self.view.addSubview(credit!)
        
        var button2 = UIButton()
        button2 = UIButton(frame: CGRectMake(20, 30, 40, 40))
        let imageb2 = UIImage(named: "My_app.png") as UIImage!
        button2.center = CGPoint(x: centerP.x + 120, y: centerP.y * 50/51 + 145)
        button2.setBackgroundImage(imageb2, forState: .Normal)
        button2.addTarget(self, action: "touchMyApp", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button2)
        UIView.animateWithDuration(0.6 ,delay:0, options: [.Repeat, .Autoreverse, .TransitionCrossDissolve, .AllowUserInteraction], animations: {
            self.fff.transform = CGAffineTransformMakeScale(0.6, 0.6)
            },
            completion: { finish in
                UIView.animateWithDuration(0.6){
                    self.fff.transform = CGAffineTransformIdentity
                }
        })
        bannerView.adUnitID = "ca-app-pub-6539656833486891/3902372969"
        bannerView.rootViewController = self
        self.bannerView.delegate = self
        let re = GADRequest()
        bannerView.loadRequest(re)
//        self.view.addSubview(bannerView)

    }
    
    
    func touchMyApp(){
        let url:NSURL? = NSURL(string: "itms-apps://itunes.apple.com/app/id966430780")
        UIApplication.sharedApplication().openURL(url!)
    }
        // Rotating the banner for iOS less than 8.0
    override func  didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)  {
        // notify StartApp auto Banner orientation change
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    }
    
}
