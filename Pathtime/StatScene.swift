//
//  GameScene.swift
//  FunApp2
//
//  Created by Jonathan on 28/12/14.
//  Copyright (c) 2014 Jonathan Fiorentini. All rights reserved.
//

import SpriteKit
import GameKit
import StoreKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

class StatScene: SKScene, SKStoreProductViewControllerDelegate{
    
    var referencePosition:CGPoint // Position of the first menu object
    var container:SKNode
    fileprivate var topMargin:CGFloat
    fileprivate var bottomMargin:CGFloat
    fileprivate var leftMargin:CGFloat
    fileprivate var rightMargin:CGFloat
    
    var replayNode:SKSpriteNode
    var nextNode:SKSpriteNode
    
    var score:GameScore
    var completed:Bool?
    var displayedInApp = false

    var appPurchases:InAppPurchasesViewController?
    init(size:CGSize, score:GameScore){
        self.container = SKNode()
        self.replayNode = SKSpriteNode()
        self.nextNode = SKSpriteNode()
        self.referencePosition = CGPoint()
        self.topMargin = CGFloat()
        self.bottomMargin = CGFloat()
        self.leftMargin = CGFloat()
        self.rightMargin = CGFloat()
        self.score = score
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = CustomColors.BackGroundColor
        referencePosition = CGPoint(x: self.frame.midX, y: self.frame.midY+self.frame.height*2/8)
        self.topMargin = self.frame.height - 40
        self.bottomMargin =  40
        self.leftMargin = 30
        self.rightMargin = self.frame.width - 30
        self.setupMenuButton()
        self.setupSignature()
        self.setupTitle()
        self.setupNextAndReplay()
        self.setupScores()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "test"), object: nil, queue: OperationQueue.main, using: {(NSNotification)->() in
            let appPurhcaseViewController = InAppPurchasesViewController()
            self.view?.superview?.window?.rootViewController!.present(appPurhcaseViewController, animated: true, completion: nil)
            self.displayedInApp = false
        })
    }
  
    func launchPurhcases(){
        let action = SKAction.rotate(byAngle: CGFloat(M_PI*2), duration: 0.5)
        let repeatedAction = SKAction.repeat(action, count: 3)
        self.nextNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.nextNode.run(repeatedAction)

//        if displayedInApp == false {
//            self.appPurchases = InAppPurchasesViewController()
//            self.appPurchases?.validateProductIdentifiers()
//            displayedInApp = true
//        }
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch:AnyObject in touches {
            let node = self.atPoint(touch.location(in: self))
            if let levelName = node.name {
                switch levelName {
                case "Reset":
                    self.resetScores()
                case "Menu":
                    self.backToMenu()
                case "Next":
                    if  Game.Purchased {
                        if completed == true{
                            self.next()
                        }
                    } else {
                        self.launchPurhcases()
                    }
                case "Replay":
                    self.replay()
                default:
                    break
                }
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func next(){
        DispatchQueue.main.async{
            let action = SKAction.rotate(byAngle: CGFloat(M_PI*2), duration: 0.5)
            let repeatedAction = SKAction.repeatForever(action)
            self.nextNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.nextNode.run(repeatedAction)
            DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async { // 1
                let radius = Int(self.frame.width/2 - 15)
                let graphGenerationBlock = Levels.Level[self.score.level + 1]
                let score = Scores.Level[self.score.level+1]
                let graphs = graphGenerationBlock(radius)
                DispatchQueue.main.async { // 2
                    let scaling = SKAction.scale(to: 0, duration: 0.5)
                    let fading = SKAction.fadeAlpha(to: 0, duration: 0.5)
                    let block = {()->() in
                        let scene = GameScene(size: self.size, graphs: graphs, level:self.score.level+1, score: score, graphGenerationBlock: Levels.Level[self.score.level+2])
                        let skView = self.view
                        skView?.ignoresSiblingOrder = true
                        skView?.presentScene(scene)
                    }
                    self.nextNode.run(scaling, completion: block)
                    self.nextNode.run(fading)
                }
            }
        }
    }
    fileprivate func replay(){
        DispatchQueue.main.async{
            let action = SKAction.rotate(byAngle: CGFloat(M_PI*2), duration: 0.5)
            let repeatedAction = SKAction.repeatForever(action)
            self.replayNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.replayNode.run(repeatedAction)
             DispatchQueue.global(qos:DispatchQoS.QoSClass.userInteractive).async { // 1
                let radius = Int(self.frame.width/2 - 15)
                let graphGenerationBlock = Levels.Level[self.score.level]
                let score = Scores.Level[self.score.level]
                let graphs = graphGenerationBlock(radius)
                DispatchQueue.main.async { // 2
                    let scaling = SKAction.scale(to: 0, duration: 0.5)
                    let fading = SKAction.fadeAlpha(to: 0, duration: 0.5)
                    let block = {()->() in
                        let scene = GameScene(size: self.size, graphs: graphs, level:self.score.level, score: score, graphGenerationBlock: Levels.Level[self.score.level+1])
                        let skView = self.view
                        skView?.ignoresSiblingOrder = true
                        skView?.presentScene(scene)
                    }
                    self.replayNode.run(scaling, completion: block)
                    self.replayNode.run(fading)
                }
            }
        }
    }
    
    fileprivate func setupNextAndReplay(){
        let initialOffset:CGFloat = 300
        let size = CGSize(width: 70, height: 70)
        let yOffset:CGFloat = 80
        let xOffset:CGFloat = 80
        replayNode = SKSpriteNode(imageNamed: "Replay")
        replayNode.anchorPoint = CGPoint(x: 0,y: 0.5)
        replayNode.name = "Replay"
        replayNode.zPosition = 100
        replayNode.position = CGPoint(x: -initialOffset , y: self.bottomMargin + yOffset)
        replayNode.size = size
        let time = 0.5
        let timingFunction =  {(time:Float)->Float in
            return Float(sin(Double(time) * M_PI*0.5))
        }
        
        if Game.Purchased {
        
        nextNode = SKSpriteNode(imageNamed: "Next")
        }else {
        
            nextNode = SKSpriteNode(imageNamed: "Buy")
        }
        nextNode.anchorPoint = CGPoint(x: 1,y: 0.5)
        nextNode.name = "Next"
        nextNode.position = CGPoint(x: self.frame.width + initialOffset, y: self.bottomMargin + yOffset)
        nextNode.size = size
        
        let replayAction = SKAction.moveTo(x: self.frame.width/2-xOffset, duration: time)
        replayAction.timingFunction = timingFunction
        let nextAction = SKAction.moveTo(x: self.frame.width/2+xOffset, duration: time)
        nextAction.timingFunction = timingFunction
        replayNode.run(replayAction)
        nextNode.run(nextAction)
        
        self.addChild(replayNode)
        self.addChild(nextNode)
    }
    
    
    fileprivate func setupScores(){
        let rewardSolved = Scores.Reward["GraphCountPoints"]!
        let rewardSolvedUnder5 = Scores.Reward["GraphUnderParPoints"]!
        let rewardTotalTime = Scores.Reward["ParTimePoints"]!
        let rewardFinished = Scores.Reward["Finished"]!
        let parTime = self.score.parTime
        let totalGraphCount = self.score.totalGraphs
        let rewardParTotal = parTime*Double(totalGraphCount)
        
        let statsLabels = ["Level (Par Time: \(parTime)s)","# of Graphs Solved (x\(rewardSolved))", "# of Graphs Solved under \(parTime)s (x\(rewardSolvedUnder5)) ","Finished level (+\(rewardFinished))", "Finished level under \(rewardParTotal)s (+\(rewardTotalTime))" ,"Score"]
        let level = self.score.level + 1
        
        
        let graphCount = self.score.solvedGraphsCount
        let graphSolvedUnder5 = self.score.solvingTimes.filter({(element) in element < 5}).count
        
        let finished = totalGraphCount == graphCount
        let totalTime:Double = self.score.cumulatedPlayingTime
        var finishedLevelUnderPar = false
        if finished {
            finishedLevelUnderPar = totalTime <= Double(rewardParTotal)
        }
        let averageTimePerGraph:Double? = Double(graphCount) == 0 ? Double(MAXFLOAT) : totalTime/Double(graphCount)
        var points = graphCount*Scores.Reward["GraphCountPoints"]! + graphSolvedUnder5*Scores.Reward["GraphUnderParPoints"]!
            points = points + (averageTimePerGraph <= Double(parTime) ?  Scores.Reward["ParTimePoints"]! : 0) + (finished == true ? Scores.Reward["Finished"]! : 0)
        
        let totalPoints = self.score.totalGraphs*Scores.Reward["GraphCountPoints"]! + self.score.totalGraphs*Scores.Reward["GraphUnderParPoints"]! + Scores.Reward["ParTimePoints"]! +  Scores.Reward["Finished"]!
        let hatCount = round((Double(points)/Double(totalPoints))*3)
        let statsValues = [Double(level),Double(graphCount),Double(graphSolvedUnder5),Double(finished ? 1 : 0),Double(finishedLevelUnderPar ? 1 : 0), Double(points)] as [Double?]
        self.score.hats = Int(hatCount)
        self.score.earnedPoints = Int(points)
        container = SKNode()
        
        if hatCount > 1 {
            let completedLevel = self.score.level
            let newLevel = self.score.level + 1
            Game.Completed[completedLevel] = true
            Game.Locked[newLevel] = false
            completed = true
        } else {
            self.nextNode.alpha = 0.5
            completed = false
            
        }
        
        if !Game.Purchased {
        self.nextNode.alpha = 1
        }
        var xOffset:CGFloat = 150
        let xInset:CGFloat = 20
        let timingFunction =  {(time:Float)->Float in
            return Float(sin(Double(time) * M_PI*0.5))
        }
        
        let time = 0.3
        let waitDuration  = time*0.5
        for i:Int in 0 ..< statsLabels.count {
            let statName = statsLabels[i]
            var val = ""
            if let statVal = statsValues[i]{
                val = String(round(Double(statVal)*100)/100)
                if i !=  3 && i != 4 && i != 5 {
                    val = String(Int(statsValues[i]!))
                }
                if i == 3 {
                    if statVal == 1 {
                        val = "Yes"
                    }
                    else {
                        val = "No"
                    }
                }
                if i == 4 {
                    if statVal == 1 {
                        val = "Yes"
                    }
                    else {
                        val = "No"
                    }
                }
                if i == statsLabels.count-1 {
                    val = "\(String(Int(statsValues[i]!)))/\(totalPoints)"
                }
                if statVal == Double(MAXFLOAT) {
                    val = "nan"
                }
            }
            var yPosition = self.topMargin - 185 - 30*CGFloat(i)
            if i == statsLabels.count-1 {
                yPosition = self.topMargin - 30*CGFloat(CGFloat(statsLabels.count) + 1.5)-245
                xOffset = 40
            }
            let statSlideAction = SKAction.moveTo(x: self.frame.width/2-xOffset, duration: time)
            statSlideAction.timingFunction = timingFunction
            let valSlideAction = SKAction.moveTo(x: self.frame.width/2+xOffset-xInset, duration: time)
            valSlideAction.timingFunction = timingFunction
            
            let wait = SKAction.wait(forDuration: waitDuration*Double(i))
            let statSequence = SKAction.sequence([wait,statSlideAction])
            let valSequence = SKAction.sequence([wait,valSlideAction])
            
            let stat:SKLabelNode = SKLabelNode(text: statName)
            stat.run(statSequence)
            
            let value:SKLabelNode = SKLabelNode(text:val)
            value.run(valSequence)
            
            let initialOffset:CGFloat = 300
            stat.position = CGPoint(x: -initialOffset, y: yPosition) //CGPointMake(self.frame.width/2-xOffset, yPosition)
            stat.fontSize = 13
            stat.fontName = CustomFonts.Main
            stat.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            value.position = CGPoint(x: self.frame.width + initialOffset, y: yPosition) // CGPointMake(self.frame.width/2+xOffset-xInset, yPosition)
            value.fontSize = 13
            value.fontName = CustomFonts.Main
            value.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            value.fontSize = 13
            value.fontName = CustomFonts.Main
            value.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            if i % 2 == 0{
                stat.fontColor = CustomColors.TextColor
                value.fontColor = CustomColors.TextColor
            } else {
                stat.fontColor = CustomColors.TextColor2
                value.fontColor = CustomColors.TextColor2
            }
            container.addChild(stat)
            container.addChild(value)
        }
        for i in 0 ..< 3{
            let yPosition = self.topMargin - 30*CGFloat(statsLabels.count)-245
            let hat = SKSpriteNode(imageNamed: "HatEmpty")
            hat.size = CGSize(width: 60,height: 60)
            let xDistance:CGFloat = 60
            let xOffset = xDistance*(CGFloat(i)-1)
            hat.position = CGPoint(x: self.frame.width/2 + xOffset, y: yPosition)
            container.addChild(hat)
        }
        for i in 0 ..< Int(hatCount){
            let time = 0.3
            let firstWaitDuration = time*Double(statsLabels.count-2 )
            let waitDuration = time*0.5
            let firstWait = SKAction.wait(forDuration: firstWaitDuration)
            let wait = SKAction.wait(forDuration: waitDuration*Double(i))
            let yPosition = self.topMargin - 30*CGFloat(statsLabels.count)-245
            let hat = SKSpriteNode(imageNamed: "Hat")
            hat.alpha = 0
            hat.size = CGSize(width: 60,height: 60)
            let xDistance:CGFloat = 60
            let xOffset = xDistance*(CGFloat(i)-1)
            hat.position = CGPoint(x: self.frame.width/2 + xOffset, y: yPosition)
            let scale:CGFloat = 2
            let expand = SKAction.scale(to: scale, duration: time)
            let shrink = SKAction.scale(to: 1, duration: time)
            let fadeIn = SKAction.fadeAlpha(to: 1, duration: time)
            
            let timingFunction =  {(time:Float)->Float in
                return Float(sin(Double(time) * M_PI*0.5))
            }
            fadeIn.timingFunction = timingFunction
            expand.timingFunction = timingFunction
            shrink.timingFunction = timingFunction
            let sequence1 = SKAction.sequence([firstWait,wait,expand, shrink])
            let sequence2 = SKAction.sequence([firstWait,wait,fadeIn])
            hat.run(sequence1)
            hat.run(sequence2)
            container.addChild(hat)
        }
        addChild(container)
        if Game.AppReviewDialogShown == false {
            if Game.PlayCount >= Game.AppReviewDialogCountLimit {
                self.reviewPopup()
            }
        }
        Game.Save()
        Scores.SaveNewScore(self.score)
        self.reportScoreToGameCenter(self.score)
        
    }
    func reviewPopup(){
        let ratingAlert = UIAlertController(title: ReviewAlerts.Thanks, message: ReviewAlerts.ThanksMessage, preferredStyle: UIAlertControllerStyle.alert)
        let yesHandler = {(alert:UIAlertAction)->() in
            let ratingAlertYes = UIAlertController(title: ReviewAlerts.Positive, message: ReviewAlerts.PositiveMessage, preferredStyle: UIAlertControllerStyle.alert)
            let yes2Handler = {(alert:UIAlertAction)->() in
                Game.AppReviewDialogShown = true
                self.openStoreProductWithiTunesItemIdentifier("529479190")
            }
            let no2Handler = {(alert:UIAlertAction)->() in
                Game.AppReviewDialogShown = true
            }
            let yes2 = UIAlertAction(title: NSLocalizedString("Yes, Rate now", comment: ""), style: UIAlertActionStyle.default, handler:yes2Handler)
            let remindMeLater = UIAlertAction(title: NSLocalizedString("Remind me later", comment: ""), style: UIAlertActionStyle.default, handler: nil)
            let no2 = UIAlertAction(title: NSLocalizedString("Don't ask me again", comment: ""), style: UIAlertActionStyle.default, handler: no2Handler)
            ratingAlertYes.addAction(yes2)
            ratingAlertYes.addAction(remindMeLater)
            ratingAlertYes.addAction(no2)
            self.view?.superview?.window?.rootViewController!.present(ratingAlertYes, animated: true, completion: nil)
        }
        
        let noHandler = {(alert:UIAlertAction)->() in
            let ratingAlertNo = UIAlertController(title: ReviewAlerts.Negative, message: ReviewAlerts.NegativeMessage, preferredStyle: UIAlertControllerStyle.alert)
            let yes2Handler = {(alert:UIAlertAction)->() in
                Game.AppReviewDialogShown = true
                let url = URL(string: "mailto:hipnfungame@gmail.com")
                UIApplication.shared.openURL(url!)
                
            }
            let no2Handler = {(alert:UIAlertAction)->() in
                Game.AppReviewDialogShown = true
            }
            let yes2 = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler:yes2Handler)
            let remindMeLater = UIAlertAction(title: NSLocalizedString("Remind me later", comment: ""), style: UIAlertActionStyle.default, handler: nil)
            let no2 = UIAlertAction(title: NSLocalizedString("Don't ask me again", comment: ""), style: UIAlertActionStyle.default, handler: no2Handler)
            ratingAlertNo.addAction(yes2)
            ratingAlertNo.addAction(remindMeLater)
            ratingAlertNo.addAction(no2)
            self.view?.superview?.window?.rootViewController!.present(ratingAlertNo, animated: true, completion: nil)
        }
        
        let yes = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler:yesHandler)
        let no = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.default, handler: noHandler)
        ratingAlert.addAction(yes)
        ratingAlert.addAction(no)
        self.view?.superview?.window?.rootViewController!.present(ratingAlert, animated: true, completion: nil)
    }
    
    func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters) {(loaded, error) -> Void in
            if loaded {
                // Parent class of self is UIViewContorller
                self.view?.superview?.window?.rootViewController!.present(storeViewController, animated: true, completion: nil)
            }
        }
    }
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    // Usage
    
    func reportScoreToGameCenter(_ score:GameScore) {
        if GKCenter.GameCenterEnabled {
            print("reporting")
            let gkScoreHats = GKScore(leaderboardIdentifier: GKCenter.LeaderBordIdentifiers[0])
            gkScoreHats.value = Int64(score.hats!)
            let levelIndex = score.level + 1
            let gkEarnedPoints = GKScore(leaderboardIdentifier: GKCenter.LeaderBordIdentifiers[levelIndex])
            gkEarnedPoints.value = Int64(score.earnedPoints!)
            GKScore.report([gkScoreHats,gkEarnedPoints], withCompletionHandler: nil)
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
    fileprivate func setupMenuButton(){
        let menuButton = SKSpriteNode(imageNamed: "Menu")
        menuButton.size = CGSize(width: 70, height: 70)
        menuButton.name = "Menu"
        menuButton.zPosition = 11
        menuButton.position = CGPoint(x: self.frame.width/2,  y: self.topMargin - 115)
        addChild(menuButton)
    }
    fileprivate func setupSaveButton(){
        let saveScoreButton = SKLabelNode (text: "Save Score")
        saveScoreButton.fontName = CustomFonts.Main
        saveScoreButton.fontSize = 13
        saveScoreButton.name = "save"
        saveScoreButton.zPosition = 10
        saveScoreButton.fontColor = CustomColors.TextColor
        saveScoreButton.position = CGPoint(x: referencePosition.x, y: referencePosition.y - 375)
        addChild(saveScoreButton)
    }
    func backToMenu(){
        let scene = MenuScene(size: self.size)
        let skView = self.view
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)
    }
    func resetScores(){
        Scores.Reset()
        container.removeFromParent()
    }
}
