//
//  LevelScene.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 1/2/16.
//  Copyright © 2016 Jonathan Fiorentini. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

//Sublevels provide increasing difficulty
// Choose levels (each level contains 10 games)
// Can buy/unlock new levels
// Can buy/unlock after 10 games if want to continue
// Generate 20 games per "level", can buy or unlock new levels
// Add random motion of level labels (spin, locked spinning)

class LevelScene: SKScene {
    var horizontalSlidingNode:SKNode
    var startTouch:CGPoint
    var startPosition:CGPoint
    var startTouchTime:Date
    var margin:CGFloat
    var offshoot:CGFloat
    let levelString = "level"
    var referencePosition:CGPoint // Position of the first menu object
    var touchSensitive = true
    fileprivate var topMargin:CGFloat
    fileprivate var bottomMargin:CGFloat
    fileprivate var leftMargin:CGFloat
    fileprivate var rightMargin:CGFloat
    var displayedInApp = false
    var appPurchases:InAppPurchasesViewController?
    
    override init(size:CGSize) {
        horizontalSlidingNode = SKNode()
        startTouch  = CGPoint()
        startPosition = CGPoint()
        startTouchTime = Date()
        margin = 30
        offshoot = 40
        referencePosition = CGPoint()
        self.topMargin = CGFloat()
        self.bottomMargin = CGFloat()
        self.leftMargin = CGFloat()
        self.rightMargin = CGFloat()
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        referencePosition = CGPoint(x: self.frame.midX, y: self.frame.midY+self.frame.height*2/8)
        self.topMargin = self.frame.height - 40
        self.bottomMargin =  40
        self.leftMargin = 30
        self.rightMargin = self.frame.width - 30
        self.backgroundColor = CustomColors.BackGroundColor
        self.setupLevelNode()
        self.setupSignature()
        self.setupMenuButton()
        self.setupTitle()
        self.touchSensitive = false
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "test"), object: nil, queue: OperationQueue.main, using: {(NSNotification)->() in
            let appPurhcaseViewController = InAppPurchasesViewController()
            self.view?.superview?.window?.rootViewController!.present(appPurhcaseViewController, animated: true, completion: nil)
            self.displayedInApp = false
        })

    }
    
    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "test"), object: nil)
    }

    func launchPurhcases(){
            let notif = Notification(name: Notification.Name(rawValue: "test"), object: nil)
            NotificationCenter.default.post(notif)

        if displayedInApp == false {
            self.appPurchases = InAppPurchasesViewController()
            self.appPurchases?.validateProductIdentifiers()
            displayedInApp = true
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchSensitive{
            for touch in touches {
                startTouch = touch.location(in: self)
                startTouchTime = Date()
                startPosition = horizontalSlidingNode.position
                horizontalSlidingNode.removeAllActions()
                let node = self.atPoint(touch.location(in: self))
                if let levelName = node.name {
                    switch levelName {
                    case "Menu":
                        self.backToMenu()
                    default:
                        if !Game.Purchased {
                            if Int(levelName)! > Game.LightMax {
                                print("BUY FULL VERSION")
                                self.launchPurhcases()
                                break
                            }
                        }
                        if Game.Locked[Int(levelName)!] == false {
                            if Game.FirstGame {
                                self.startDemo()
                                print("check demo")
                            }else {
                                self.startLevel(Int(levelName)!)
                            }
                        }else {
                            SKMotion.shake(node, duration: 0.5)
                        }
                        break
                    }
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchSensitive{
            for touch in touches {
                let time = -startTouchTime.timeIntervalSinceNow
                let xDistance = touch.location(in: self).x - startTouch.x
                _ = xDistance/CGFloat(time)
                let velocity = CGVector(dx: 0, dy: 0)
                SKMotion.easeAndBounceWithBounds(self.horizontalSlidingNode, velocity: velocity, margin: margin, easingOffshoot: offshoot, scene: self)
            }
        }
    }
    //Async wait
    fileprivate func startLevel(_ level:Int){
        Game.PlayCount = Game.PlayCount + 1
        Game.Save()
        DispatchQueue.main.async{
            let action = SKAction.rotate(byAngle: CGFloat(M_PI*2), duration: 0.5)
            let repeatedAction = SKAction.repeatForever(action)
            self.horizontalSlidingNode.run(repeatedAction)
            self.touchSensitive = false
            DispatchQueue.global(qos:DispatchQoS.QoSClass.userInteractive).async { // 1
                let radius = Int(self.frame.width/2 - 15)
                let graphGenerationBlock = Levels.Level[level]
                print(level)
                let score = Scores.Level[level]
                let graphs = graphGenerationBlock(radius)
                DispatchQueue.main.async { // 2
                    let scaling = SKAction.scale(to: 0, duration: 0.5)
                    let fading = SKAction.fadeAlpha(to: 0, duration: 0.5)
                    let block = {()->() in
                        var lev = level
                        if level == 11 {
                            lev = level - 1
                        }
                        let scene = GameScene(size: self.size, graphs: graphs, level:level, score: score, graphGenerationBlock: Levels.Level[lev+1])
                        let skView = self.view
                        skView?.ignoresSiblingOrder = true
                        skView?.presentScene(scene)
                    }
                    self.horizontalSlidingNode.run(scaling, completion: block)
                    self.horizontalSlidingNode.run(fading)
                }
            }
        }
    }
    
    //Async wait
    fileprivate func startDemo(){
        let level = -1
        DispatchQueue.main.async{
            let action = SKAction.rotate(byAngle: CGFloat(M_PI*2), duration: 0.5)
            let repeatedAction = SKAction.repeatForever(action)
            self.horizontalSlidingNode.run(repeatedAction)
            self.touchSensitive = false
            DispatchQueue.global(qos:DispatchQoS.QoSClass.userInteractive).async { // 1
                let radius = Int(self.frame.width/2 - 15)
                let graphGenerationBlock = Levels.Demo
                let score = Scores.Level[level+1]
                let graphs = graphGenerationBlock(radius)
                DispatchQueue.main.async { // 2
                    let scaling = SKAction.scale(to: 0, duration: 0.5)
                    let fading = SKAction.fadeAlpha(to: 0, duration: 0.5)
                    let block = {()->() in
                        let scene = DemoScene(size: self.size, graphs: graphs, level:-1, score: score, graphGenerationBlock: Levels.Level[level+1])
                        let skView = self.view
                        skView?.ignoresSiblingOrder = true
                        skView?.presentScene(scene)
                    }
                    self.horizontalSlidingNode.run(scaling, completion: block)
                    self.horizontalSlidingNode.run(fading)
                }
            }
        }
    }

    fileprivate func setupTitle(){
        let title = SKSpriteNode(imageNamed: "Title")
        title.size = CGSize(width: (4/3*100), height: 100)
        title.position = CGPoint(x: 0, y: 0)
        title.position = CGPoint(x: self.frame.midX, y: self.topMargin - 40)
        addChild(title)
    }
    fileprivate func setupSignature(){
        let signature = SKNode()
        let yOffset:CGFloat = 30
        let name = SKLabelNode(text: "JF Design 2016 © All Rights Reserved")
        name.fontColor = CustomColors.Signature
        name.fontName = CustomFonts.Signature
        name.fontSize = 9
        let welcomeHipster = SKSpriteNode(imageNamed: "HipsterTitle")
        welcomeHipster.size = CGSize(width: 40, height: 40)
        welcomeHipster.position = CGPoint(x: 0, y: 0)
        let smokeSprite = SKEmitterNode(fileNamed: "SmokeParticle.sks")!
        smokeSprite.position = CGPoint(x: 10.4, y: -5.92)
        welcomeHipster.addChild(smokeSprite)
        name.position = CGPoint(x: 0, y: 0)
        welcomeHipster.position = CGPoint(x: 0, y: yOffset)
        signature.addChild(name)
        signature.addChild(welcomeHipster)
        signature.position = CGPoint(x: self.frame.width/2 , y: self.bottomMargin)
        addChild(signature)
    }
    fileprivate func setupLevelNode(){
        let levelNumber:CGFloat = CGFloat(Levels.Level.count)
        let xDistance:CGFloat = 20
        let yDistance:CGFloat = 20
        let width:CGFloat = 70
        let height:CGFloat = 70
        let xMax:CGFloat = 4 // round(self.frame.width/xSpace)
        let yNumber = levelNumber/xMax
        let xSpace = xDistance + width
        let ySpace = yDistance + height
        let xInitialSpace = (xSpace*(1-CGFloat(xMax)))/2 // Offsets space
        let yInitialSpace = (ySpace*(-1+CGFloat(yNumber)))/2 // Offsets space
        let atlas = SKTextureAtlas(named: Keys.LevelAtlas)
        for i in 0 ..< Int(levelNumber){
            let increment = CGFloat(i)
            let iX = increment.truncatingRemainder(dividingBy: xMax)
            let iY = floor(increment / xMax)
            let texture = atlas.textureNamed(Keys.LevelAtlasTextures[i])
            let locked = SKSpriteNode(imageNamed: "Locked")
            locked.name = String(i)
            locked.size = CGSize(width: 70, height: 70)
            locked.zRotation = CGFloat(M_PI/4)
            locked.zPosition = 100
            locked.position = CGPoint(x: xInitialSpace+xSpace*iX,y: yInitialSpace-ySpace*iY)
            let level = SKSpriteNode(texture: texture)
            level.name = String(i)
            level.size = CGSize(width: width, height: height)
            level.position = CGPoint(x: xInitialSpace+xSpace*iX,y: yInitialSpace-ySpace*iY)
            let completed = SKSpriteNode(imageNamed: "Completed")
            completed.size = CGSize(width: 50, height: 50)
            completed.name = String(i)
            completed.zRotation = 0 //CGFloat(M_PI/4)
            completed.zPosition = 100
            completed.position = CGPoint(x: xInitialSpace+xSpace*iX,y: yInitialSpace-ySpace*iY-40)
            if let score = Scores.SavedScores[i] {
                
                if let hatNumber = score.hats{
                    for i in 0 ..< 3{
                        let hatEmpty = SKSpriteNode(imageNamed: "HatEmpty")
                        hatEmpty.size = CGSize(width: 20,height: 20)
                        hatEmpty.anchorPoint = CGPoint(x: 0.5, y: 0.4)
                        let xDistance:CGFloat = 20
                        let xLocalOffset = xDistance*(CGFloat(i)-1)
                        hatEmpty.position = CGPoint(x: xInitialSpace+xSpace*iX+xLocalOffset,y: yInitialSpace-ySpace*iY - 30)
                        hatEmpty.zPosition = 1
                        self.horizontalSlidingNode.addChild(hatEmpty)
                    }
                    for i in 0 ..< Int(hatNumber){
                        let hat = SKSpriteNode(imageNamed: "Hat")
                        hat.anchorPoint = CGPoint(x: 0.5, y: 0.4)
                        hat.alpha = 1
                        hat.size = CGSize(width: 20,height: 20)
                        let xDistance:CGFloat = 20
                        let xLocalOffset = xDistance*(CGFloat(i)-1)
                        hat.zPosition = 1
                        hat.position = CGPoint(x: xInitialSpace+xSpace*iX+xLocalOffset,y: yInitialSpace-ySpace*iY - 30)
                        self.horizontalSlidingNode.addChild(hat)
                    }
                }
            }
            if Game.Locked[i] {
                self.horizontalSlidingNode.addChild(locked)
            }
            if Game.Completed[i]{
                self.horizontalSlidingNode.addChild(completed)
            }
            if i>Game.LightMax && !Game.Purchased{
                level.alpha = 0.5
                locked.alpha = 0.5
            }
            self.horizontalSlidingNode.addChild(level)
        }
        horizontalSlidingNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        horizontalSlidingNode.alpha = 0
        horizontalSlidingNode.xScale = 30
        horizontalSlidingNode.yScale = 30
        self.addChild(horizontalSlidingNode)
        let effectDuration:TimeInterval = 1
        let scaling = SKAction.scale(to: 1, duration: effectDuration)
        let fading = SKAction.fadeAlpha(to: 1, duration: effectDuration)
        let timingFunction =  {(time:Float)->Float in
            return Float(sin(Double(time) * M_PI*0.5))
        }
        fading.timingFunction = timingFunction
        scaling.timingFunction = timingFunction
        self.horizontalSlidingNode.run(scaling)
        self.horizontalSlidingNode.run(fading, completion: {()->() in self.touchSensitive = true})
    }
    func setupMenuButton(){
        let menuButton = SKSpriteNode(imageNamed: "Menu")
        menuButton.size = CGSize(width: 70, height: 70)
        menuButton.name = "Menu"
        menuButton.zPosition = 11
        menuButton.position = CGPoint(x: referencePosition.x, y: referencePosition.y + 10)
        addChild(menuButton)
    }
    func backToMenu(){
        let scene = MenuScene(size: self.size)
        let skView = self.view
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)
    }
    
    
}
