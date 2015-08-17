//
//  LogicalView.swift
//  Snake
//
//  Created by mhtran on 2/4/15.
//  Copyright (c) 2015 mhtran. All rights reserved.
//

import UIKit

class LogicalView: UIViewController, STADelegateProtocol {

    var credit: UILabel?
    var vc = MainVC()
    var startAppAdAutoLoad: STAStartAppAd?
    
    /*
    Declaration of STAStartAppAd which later on will be used
    for loading when user clicks on a button and showing the
    loaded ad when the ad was loaded with delegation
    */
    var startAppAdLoadShow: STAStartAppAd?
    
    /*
    Declaration of StartApp Banner view with automatic positioning
    */
    var startAppBannerAuto: STABannerView?
    
    /*
    Declaration of StartApp Banner view with fixed positioning and size
    */
    var startAppBannerFixed: STABannerView?
    
    
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
        startAppAdAutoLoad = STAStartAppAd()
        startAppAdLoadShow = STAStartAppAd()
//        startAppAdLoadShow!.loadAd(STAAdType_Automatic, withDelegate: self)
        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true)
        var centerP = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
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
        var imageb2 = UIImage(named: "My_app.png") as UIImage!
        button2.center = CGPoint(x: centerP.x + 120, y: centerP.y * 50/51 + 145)
        button2.setBackgroundImage(imageb2, forState: .Normal)
        button2.addTarget(self, action: "touchMyApp", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button2)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startAppAdAutoLoad!.loadAd()
        /*
        load the StartApp auto position banner, banner size will be assigned automatically by  StartApp
        NOTE: replace the ApplicationID and the PublisherID with your own IDs
        */
        
        startAppBannerAuto = STABannerView(size: STA_AutoAdSize, autoOrigin: STAAdOrigin_Top, withView: self.view, withDelegate: nil);
        
        self.view.addSubview(startAppBannerAuto!)
        
        
        /*
        load the StartApp fixed position banner - in (0, 200)
        NOTE: replace the ApplicationID and the PublisherID with your own IDs
        */
        
    }
    
    func touchMyApp(){
        var url:NSURL? = NSURL(string: "itms-apps://itunes.apple.com/app/id966430780")
        UIApplication.sharedApplication().openURL(url!)
//        UIApplication.sharedApplication().openURL(NSURL(string:"http://itunes.com/apps/impossiblehurry")!);
    }
        // Rotating the banner for iOS less than 8.0
    override func  didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)  {
        // notify StartApp auto Banner orientation change
        startAppBannerAuto!.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        
        // notify StartApp fixed position Banner orientation change
        startAppBannerFixed!.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    }
    
    func didLoadAd(ad: STAAbstractAd) {
        //        println("StartApp Ad had been loaded successfully")
        startAppAdLoadShow!.showAd()
    }
    
    // StartApp Ad failed to load
    func failedLoadAd(ad: STAAbstractAd, withError error: NSError) {
        //        println("StartApp Ad had failed to load")
    }
    
    // StartApp Ad is being displayed
    func didShowAd(ad: STAAbstractAd) {
        //        println("StartApp Ad is being displayed")
    }
    
    // StartApp Ad failed to display
    func failedShowAd(ad: STAAbstractAd, withError error: NSError) {
        //        println("StartApp Ad is failed to display")
    }
    
    // StartApp Ad is being displayed
    func didCloseAd(ad: STAAbstractAd) {
        //        println("StartApp Ad was closed")
    }
    
    // StartApp Ad is being displayed
    func didClickAd(ad: STAAbstractAd) {
        //        println("StartApp Ad was clicked")
    }


   

}
