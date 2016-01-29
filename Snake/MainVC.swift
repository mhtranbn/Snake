////
////  MainVC.swift
////  Snake
////
////  Created by mhtran on 12/21/14.
////  Copyright (c) 2014 mhtran. All rights reserved.
////

import UIKit
import Foundation
import AVFoundation
import MediaPlayer
import Social
//import GoogleMobileAds


struct WorldSize {
    var width:Int
    var height:Int
}

struct Point {
    var x:Int
    var y:Int
}

enum Direction: Int {
    case left = 1
    case right = 2
    case up = 3
    case down = 4
    
    func canChangeTo(newDirection:Direction) -> Bool {
        var canChange = false
        switch self {
        case .left, .right:
            canChange = newDirection == .up || newDirection == .down
        case .up, .down:
            canChange = newDirection == .left || newDirection == .right
        }
        return canChange
    }
    
    func move(point:Point, worldSize:WorldSize) -> (Point) {
        var theX = point.x
        var theY = point.y
        switch self {
        case .left:
            if --theX < 0 {
                theX = worldSize.width - 1
            }
        case .up:
            if --theY < 0 {
                theY = worldSize.height - 1
            }
        case .right:
            if ++theX >= worldSize.width {
                theX = 0
            }
        case .down:
            if ++theY >= worldSize.height {
                theY = 0
            }
        }
        return Point(x: theX, y: theY)
    }
}



class Snake {
    var worldSize : WorldSize
    var length:Int = 0
    var points:Array<Point> = []
    var direction:Direction = .left
    var directionLocked:Bool = false
    
    init(inSize:WorldSize, length inLength:Int) {
        self.worldSize = inSize
        self.length = inLength
        
        let x:Int = self.worldSize.width
//        let y:Int = self.worldSize.height
        for i in 0...inLength {
            let p:Point = Point(x:x + i , y: x)
            self.points.append(p)
        }
    }
    
    func move() {
        let head = self.direction.move(points[0], worldSize: self.worldSize)
        self.points.insert(head, atIndex: 0)
        self.points.removeLast()
    }
    func changeDirection(newDirection:Direction) {
        if self.directionLocked {
            return
        }
        if self.direction.canChangeTo(newDirection) {
            self.direction = newDirection
        }
    }
    
    func increaseLength(inLength:Int) {
        let lastPoint:Point = self.points[self.points.count-1]
        let theOneBeforeLastPoint:Point = self.points[self.points.count-2]
        var x = lastPoint.x - theOneBeforeLastPoint.x
        var y = lastPoint.y - theOneBeforeLastPoint.y
        if lastPoint.x == 0 &&
            theOneBeforeLastPoint.x == self.worldSize.width - 1	{
                x = 1
        }
        if (lastPoint.x == self.worldSize.width - 1 && theOneBeforeLastPoint.x == 0) {
            x = -1
        }
        if (lastPoint.y == 0 && theOneBeforeLastPoint.y == self.worldSize.height - 1) {
            y = 1
        }
        if (lastPoint.y == self.worldSize.height - 1 && theOneBeforeLastPoint.y == 0) {
            y = -1
        }
        for i in 0..<inLength {
            let theX:Int = (lastPoint.x + x * (i + 1)) % worldSize.width
            let theY:Int = (lastPoint.y + y * (i + 1)) % worldSize.height
            self.points.append(Point(x:theX, y:theY))
        }
    }
    
    func isHeadHitBody() -> Bool {
        let headPoint = self.points[0]
        for bodyPoint in self.points[1..<self.points.count] {
            if (bodyPoint.x == headPoint.x &&
                bodyPoint.y == headPoint.y) {
                    return true
            }
        }
        return false
    }
    
    
    func lockDirection() {
        self.directionLocked = true
    }
    
    func unlockDirection() {
        self.directionLocked = false
    }
}

protocol SnakeViewDelegate {
    func snakeForSnakeView(view:SnakeVC) -> Snake?
    func pointOfFruitForSnakeView(view:SnakeVC) -> Point?
}

class SnakeVC : UIView {
    var delegate:SnakeViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundSnake.png")!)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundSnake.png")!)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if let snake:Snake = delegate?.snakeForSnakeView(self) {
            let worldSize = snake.worldSize
            if worldSize.width <= 0 || worldSize.height <= 0 {
                return
            }
//            var vb = self.bounds.size.width
//            var vc = self.bounds.size.height
            let w = Int(Float(self.bounds.size.width) / Float(worldSize.width))
            let h = Int(Float(self.bounds.size.width) / Float(worldSize.width))
            UIColor.blueColor().set()
            let points = snake.points
            for point in points {
                
                let rect = CGRect(x: point.x * w, y: point.y * h, width:w, height:w)
                UIBezierPath(rect: rect).fill()
            }
            
            if let fruit = delegate?.pointOfFruitForSnakeView(self) {
                
                UIColor.brownColor().set()
                let rect = CGRect(x: fruit.x * w, y: fruit.y * h, width: w, height: w)
                UIBezierPath(ovalInRect: rect).fill()
            }
        }}
}

class Level {
    
}


class MainVC: UIViewController, AVAudioPlayerDelegate, SnakeViewDelegate {
    
    
    
    var hightScore: NSNumber?
    var scoretg: Int?
    var heightScoreLable: UILabel?
    var alert = UIAlertView()
    var backgroundMusic = AVAudioPlayer()
    var t: Double = 0.016
    var snakeVC:SnakeVC?
    var timer:NSTimer?
    var score: NSNumber?
    var scoreLabel: UILabel?
    var snake:Snake?
    var fruit:Point?
    var audioPlayer = AVAudioPlayer()
    var eatQuery: SystemSoundID = 0
    var die: SystemSoundID = 0
    var backgroundMusicP: AVAudioPlayer!
    var playMusic: AVAudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        alert.delegate = self
        playBackgroundMusic("soundBackgroundtest", ex: "m4a")
        self.snakeVC = SnakeVC(frame: self.view.bounds)
        self.navigationController?.navigationBar.translucent = false
        self.snakeVC!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.insertSubview(self.snakeVC!, atIndex: 0)
        if let view = self.snakeVC {
            view.delegate = self
            
        }
        for direction in [UISwipeGestureRecognizerDirection.Right,
            UISwipeGestureRecognizerDirection.Left,
            UISwipeGestureRecognizerDirection.Up,
            UISwipeGestureRecognizerDirection.Down] {
                let gr = UISwipeGestureRecognizer(target: self, action: "swipe:")
                gr.direction = direction
                self.view.addGestureRecognizer(gr)
        }
        if (self.timer != nil) {
            return
        }
        scoreLabel = UILabel(frame: CGRect(x:0, y:0, width:200, height:50))
        scoreLabel!.text = ""
        scoreLabel!.textAlignment = NSTextAlignment.Center
        scoreLabel?.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        self.view.addSubview(scoreLabel!)
        scoreLabel?.center.x = self.view.bounds.size.width/2
        scoreLabel?.center.y = 70
        let screenShotMethodtg : NSNumber? = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        heightScoreLable = UILabel(frame: CGRect(x:0, y:0, width:200, height:60))
        heightScoreLable?.text = screenShotMethodtg!.stringValue
        heightScoreLable?.textAlignment = NSTextAlignment.Center
        heightScoreLable?.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        self.view.addSubview(heightScoreLable!)
        heightScoreLable?.center.x = self.view.bounds.size.width/2
        heightScoreLable?.center.y = 90
        let worldSize = WorldSize(width: 2, height: 2)
        self.snake = Snake(inSize: worldSize, length: 1)
        self.createQuarry()
        AudioServicesPlaySystemSound(eatQuery)
        startGame()
//        let nbannerView = GADBannerView()
//        nbannerView.adUnitID = "ca-app-pub-6539656833486891/3902372969"
//        nbannerView.rootViewController = self
//        let re = GADRequest()
//        nbannerView.loadRequest(re)
//        self.view.addSubview(nbannerView)

        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Rotating the banner for iOS less than 8.0
    override func  didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)  {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func playBackgroundMusic(filename: String, ex: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: ex)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        
        do {
            backgroundMusicP = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicP.numberOfLoops = -1
            backgroundMusicP.prepareToPlay()
            backgroundMusicP.play()
            
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func playMusic(filename: String, ex: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: ex)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        
        do {
            playMusic = try AVAudioPlayer(contentsOfURL: newURL)
            playMusic.prepareToPlay()
            playMusic.play()
            
        } catch let error as NSError {
            print(error.description)
        }
    }

    
    func swipe (gr:UISwipeGestureRecognizer) {
        let direction = gr.direction
        switch direction {
        case UISwipeGestureRecognizerDirection.Right:
            if (self.snake?.changeDirection(Direction.right) != nil) {
                self.snake?.lockDirection()
            }
        case UISwipeGestureRecognizerDirection.Left:
            if (self.snake?.changeDirection(Direction.left) != nil) {
                self.snake?.lockDirection()
            }
        case UISwipeGestureRecognizerDirection.Up:
            if (self.snake?.changeDirection(Direction.up) != nil) {
                self.snake?.lockDirection()
            }
        case UISwipeGestureRecognizerDirection.Down:
            if (self.snake?.changeDirection(Direction.down) != nil) {
                self.snake?.lockDirection()
            }
        default:
            assert(false, "")
        }
        
        
    }
    
    func startGame() {
        score = 0
        if (self.timer != nil) {
            return
        }
        let wx = 16
        let hx = floor(snakeVC!.bounds.size.height / (snakeVC!.bounds.size.width/CGFloat(wx)))
        let worldSize = WorldSize(width: wx, height: Int(hx))
        self.snake = Snake(inSize: worldSize, length: 2)
        self.createQuarry()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.12, target: self, selector: "timerMethod:", userInfo: nil, repeats: true)
        self.snakeVC!.setNeedsDisplay()
    }
    
    func endGame() {
        highScore()
        let highScoretg : NSNumber? = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        heightScoreLable?.text = highScoretg!.stringValue
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        screenShotMethod()
        self.timer!.invalidate()
        self.timer = nil
        playMusic("die", ex:"mp3")
        showResult()
    }
    
    func screenShotMethod() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, 0);
        self.view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
    
    func showFaceBook() {
        let facebook = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        facebook.completionHandler = {
            result in
            switch result {
            case SLComposeViewControllerResult.Cancelled:
                self.showResult()
                
            case SLComposeViewControllerResult.Done:
                self.showResult()

            }
        }
        
        facebook.setInitialText("Oh my god! Score in game \"Snake 2025\" is \(score!.stringValue).")
        facebook.addImage(self.screenShotMethod()) //Add an image if you like?
        facebook.addURL(NSURL(string: "https://www.facebook.com/SnakePoor")) //A url which takes you into safari if tapped on
        
        self.presentViewController(facebook, animated: false, completion: {
            
        })
        
    }
    
    func showTweetSheet() {
        let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        tweetSheet.completionHandler = {
            result in
            switch result {
            case SLComposeViewControllerResult.Cancelled:
                self.showResult()
                
            case SLComposeViewControllerResult.Done:
                self.showResult()
            }
        }
        
        tweetSheet.setInitialText("Oh my god! Score in game \"Snake 2025\" is \(score!.stringValue).") //The default text in the tweet
        tweetSheet.addImage(self.screenShotMethod()) //Add an image if you like?
        tweetSheet.addURL(NSURL(string: "https://twitter.com/mhtranbn")) //A url which takes you into safari if tapped on
        
        self.presentViewController(tweetSheet, animated: false, completion: {
            //Optional completion statement
        })
    }

    
    
    func timerMethod(timer:NSTimer) {
        self.snake?.move()
        let headHitBody = self.snake?.isHeadHitBody()
        if headHitBody == true {
            self.endGame()
            return
        }
        let head = self.snake?.points[0]
        if head?.x == self.fruit?.x &&
            head?.y == self.fruit?.y {
                self.snake!.increaseLength(1)
                playMusic("eat", ex:"wav")
                score = Int(score!) + 1
                scoreLabel!.text = score!.stringValue
                
                self.createQuarry()
        }
        self.snake?.unlockDirection()
        self.snakeVC!.setNeedsDisplay()
    }
    
    func snakeForSnakeView(view:SnakeVC) -> Snake? {
        return self.snake
    }
    func pointOfFruitForSnakeView(view:SnakeVC) -> Point? {
        return self.fruit
    }
    
    func setupLevel() {
        
    }
    
    func createQuarry(){
        srandomdev()
        let worldSize = self.snake!.worldSize
        var x = 0, y = 0
        while (true) {
            x = random() % worldSize.width
            y = random() % worldSize.height
            var isBody = false
            for p in self.snake!.points {
                if p.x == x && p.y == y {
                    isBody = true
                    break
                }
            }
            if !isBody {
                
                break
            }
        }
        self.fruit = Point(x: x, y: y)
    }
    
    func resetGame() {

        playMusic("die", ex: "mp3")
        let worldSize = WorldSize(width: 2, height: 2)
        self.snake = Snake(inSize: worldSize, length: 1)
        self.createQuarry()
        AudioServicesPlaySystemSound(eatQuery)
        startGame()
    }
    
    func showResult(){
        backgroundMusicP.pause()
        self.scoreLabel?.hidden
        alert.title = "Game over! Your score is \(score!.stringValue)."
        alert.message = "To continue playing, hit 'Play Again'"
        alert.addButtonWithTitle("Share Facebook")
        alert.addButtonWithTitle("Share Twitter")
        alert.addButtonWithTitle("Play Again")
        alert.addButtonWithTitle("End Game")
        alert.show()
    }
    
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
        case 1:
            NSNotificationCenter.defaultCenter().postNotificationName("tweet", object: nil)
            
            self.showTweetSheet()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "tweet", name: "tweet", object: nil)
            break;
            
        case 0:
            NSNotificationCenter.defaultCenter().postNotificationName("facebook", object: nil)
            self.showFaceBook()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "facebook", name: "facebook", object: nil)
            
            break;
            
        case 3:
            self.dismissViewControllerAnimated(true, completion: nil)
            
            break;
        case 2:
            
            self.resetGame()
            
            break;
        default:
            break;
            
        }
    }
    
    func highScore() -> Int
    {
        var highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        
        //Check if score is higher than NSUserDefaults stored value and change NSUserDefaults stored value if it's true
        let scoretg: Int = Int(score!) * 1
        if scoretg > highScore
        {
            NSUserDefaults.standardUserDefaults().setInteger(scoretg, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
            highScore = scoretg
        }
        return highScore;
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//         notify StartApp auto Banner orientation change
        if #available(iOS 8.0, *) {
            super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        } else {
            // Fallback on earlier versions
        }
    }
    
}

