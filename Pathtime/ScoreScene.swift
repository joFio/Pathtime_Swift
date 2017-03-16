//
//  GameScene.swift
//  FunApp2
//
//  Created by Jonathan on 28/12/14.
//  Copyright (c) 2014 Jonathan Fiorentini. All rights reserved.
//

import SpriteKit
import GameKit
class ScoreScene: SKScene{
    
    var referencePosition:CGPoint // Position of the first menu object
    var container:SKNode
    fileprivate var topMargin:CGFloat
    fileprivate var bottomMargin:CGFloat
    fileprivate var leftMargin:CGFloat
    fileprivate var rightMargin:CGFloat    
    override init(size: CGSize) {
        self.container = SKNode()
        self.referencePosition = CGPoint()
        self.topMargin = CGFloat()
        self.bottomMargin = CGFloat()
        self.leftMargin = CGFloat()
        self.rightMargin = CGFloat()
        super.init(size: size)
    }
    override func didMove(to view: SKView) {
        self.backgroundColor = CustomColors.BackGroundColor
        referencePosition = CGPoint(x: self.frame.midX, y: self.frame.midY+self.frame.height*2/8)
        self.topMargin = self.frame.height - 40
        self.bottomMargin =  40
        self.leftMargin = 30
        self.rightMargin = self.frame.width - 30
        self.setupScores()
        self.setupMenuButton()
        self.setupResetButton()
        self.setupSignature()
        self.setupTitle()
    }
    fileprivate func setupScores(){
        let scores = Scores.SavedScores
        let keys = scores.keys
        let sortedKeys = keys.sorted(by: { $0.0 < $0.1})

        let scoreString:SKLabelNode = SKLabelNode(text:"Scores")
        scoreString.position = CGPoint(x: referencePosition.x, y: referencePosition.y - 70)
        scoreString.fontSize = 13
        scoreString.fontName = CustomFonts.Main
        scoreString.fontColor = CustomColors.TextColor
        container = SKNode()
        addChild(scoreString)
        
        let atlas = SKTextureAtlas(named: Keys.LevelAtlas)
        
        var totalHats = 0
        for i:Int in 0 ..< sortedKeys.count {
            let texture = atlas.textureNamed(Keys.LevelAtlasTextures[i])
            let level = SKSpriteNode(texture: texture)
            level.size = CGSize(width: 30, height: 30)

            print("sortedKEYSSDFLJKHsakldhjlaksdjkaldhsajdhkjlsahdlksadkhja")
            print(sortedKeys[i])

            let xOffset:CGFloat = 0
            let xInset:CGFloat = 10
         

            let yPosition = referencePosition.y - 105 - 30*CGFloat(i)
            level.position = CGPoint(x: self.frame.width/2-xOffset-90, y: yPosition)
            level.anchorPoint = CGPoint(x: 0,y: 0.3)

            var earnedPoints = ""
            if let score = Scores.SavedScores[i] {
                if let points = score.earnedPoints{
                    earnedPoints = String(points)
                }
                if let hatNumber = score.hats{
                    totalHats = totalHats + hatNumber
                    for i in 0 ..< 3{
                        let hatEmpty = SKSpriteNode(imageNamed: "HatEmpty")
                        hatEmpty.size = CGSize(width: 30,height: 30)
                        hatEmpty.anchorPoint = CGPoint(x: 0, y: 0.4)
                        let xDistance:CGFloat = 30
                        let xLocalOffset = xDistance*(CGFloat(i))
                        hatEmpty.position = CGPoint(x: self.frame.width/2+xOffset+xLocalOffset+xInset, y: yPosition)
                        hatEmpty.zPosition = 100

                        container.addChild(hatEmpty)
                    }
                    for i in 0 ..< Int(hatNumber){
                        let hat = SKSpriteNode(imageNamed: "Hat")
                        hat.anchorPoint = CGPoint(x: 0, y: 0.4)
                        hat.alpha = 1
                        hat.size = CGSize(width: 30,height: 30)
                        let xDistance:CGFloat = 30
                        let xLocalOffset = xDistance*(CGFloat(i))
                        hat.zPosition = 1000
                        hat.position = CGPoint(x: self.frame.width/2+xOffset+xLocalOffset+xInset, y: yPosition)
                        container.addChild(hat)
                    }
                }
            }
            let scorePoints:SKLabelNode = SKLabelNode(text: earnedPoints)
            scorePoints.position = CGPoint(x: self.frame.width/2+xOffset-xInset, y: yPosition)
            scorePoints.fontColor = CustomColors.TextColor
            scorePoints.fontSize = 13
            scorePoints.fontName = CustomFonts.Main
            scorePoints.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            container.addChild(level)
            container.addChild(scorePoints)
            if i == sortedKeys.count-1 {
                let totalHatsLabel = SKLabelNode(text: "\(totalHats)x")
                let localXOffset:CGFloat = 2
                let localYOffset:CGFloat = 50
                totalHatsLabel.position = CGPoint(x: self.frame.width/2-localXOffset, y: referencePosition.y - localYOffset)
                totalHatsLabel.fontColor = CustomColors.TextColor
                totalHatsLabel.fontSize = 13
                totalHatsLabel.fontName = CustomFonts.Main
                totalHatsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
                let hat = SKSpriteNode(imageNamed: "Hat")
                hat.anchorPoint = CGPoint(x: 0, y: 0.35)
                hat.alpha = 1
                hat.size = CGSize(width: 30,height: 30)
                hat.position = CGPoint(x: self.frame.width/2+localXOffset, y: referencePosition.y - localYOffset)

                container.addChild(totalHatsLabel)
                container.addChild(hat)
            }
        }
        self.reportAchivements(totalHats)
        addChild(container)
    }
    
    func reportAchivements(_ hats:Int){
    
        //Achievement logic
        var achievements = [GKAchievement]()
        
        if hats>=5 {
            let achievement = GKAchievement(identifier: "hats5")
            achievement.percentComplete = 100
            achievements.append(achievement)
        }
        
        if hats>=10 {
            let achievement = GKAchievement(identifier: "hats10")
            achievement.percentComplete = 100
            achievements.append(achievement)
        }
        
        if hats>=15 {
            let achievement = GKAchievement(identifier: "hats15")
            achievement.percentComplete = 100
            achievements.append(achievement)
        }
        
        GKAchievement.report(achievements, withCompletionHandler: nil)
        

    
        
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
    fileprivate func setupResetButton(){
        let resetButton = SKLabelNode (text: "Reset Scores")
        resetButton.fontName = CustomFonts.Main
        resetButton.fontSize = 13
        resetButton.name = "Reset"
        resetButton.zPosition = 10
        resetButton.fontColor = CustomColors.TextColor
        resetButton.position = CGPoint(x: referencePosition.x, y: referencePosition.y - 375)
        addChild(resetButton)
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch:AnyObject in touches {
            let node = self.atPoint(touch.location(in: self))
            if let levelName = node.name {
                switch levelName {
                case "Reset":
                    self.resetScores()
                case "Menu":
                    self.backToMenu()
                default:
                    break
                }
            }
            
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }            
}
