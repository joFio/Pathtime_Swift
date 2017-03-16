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

// User can unlock/buy new levels
// Menu Scene

class MenuScene: SKScene {
    var horizontalSlidingNode:SKNode
    var startTouch:CGPoint
    var startPosition:CGPoint
    var startTouchTime:Date
    var margin:CGFloat
    var offshoot:CGFloat
    fileprivate var topMargin:CGFloat
    fileprivate var bottomMargin:CGFloat
    fileprivate var leftMargin:CGFloat
    fileprivate var rightMargin:CGFloat

    override init(size:CGSize) {
        horizontalSlidingNode = SKNode()
        startTouch  = CGPoint()
        startPosition = CGPoint()
        startTouchTime = Date()
        margin = 30
        offshoot = 40
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
        self.topMargin = self.frame.height - 40
        self.bottomMargin =  40
        self.leftMargin = 30
        self.rightMargin = self.frame.width - 30
        self.setupLevelNode()
        self.setupSignature()
        self.setupTitle()
        self.backgroundColor = CustomColors.BackGroundColor

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            startTouch = touch.location(in: self)
            startTouchTime = Date()
            startPosition = horizontalSlidingNode.position
            horizontalSlidingNode.removeAllActions()
            let node = self.atPoint(touch.location(in: self))
            if let levelName = node.name {
                switch levelName {
                case "Play":
                    self.openLevel()
                    break
                case "Scores":
                    self.openScores()
                case "Buy":
                    let action = SKAction.rotate(byAngle: CGFloat(M_PI*2.0), duration: 0.5)
                    let repeatAction = SKAction.repeat(action, count: 4)
                    node.run(repeatAction)
                default:
                    break
                }
            }
        }
    }
    fileprivate func openLevel(){
        let scene = LevelScene(size: self.size)
        let skView = self.view
        skView?.ignoresSiblingOrder = true        
        skView?.presentScene(scene)
    }
    
    fileprivate func openScores(){
        let effectDuration:TimeInterval = 0.5
        let scaling = SKAction.scale(to: 30, duration: effectDuration)
        let fading = SKAction.fadeAlpha(to: 0, duration: effectDuration)
        let timingFunction =  {(time:Float)->Float in
            return Float(sin(Double(time) * M_PI*0.5))
        }
        fading.timingFunction = timingFunction
        scaling.timingFunction = timingFunction
        let completion = {()->() in
            let scene = ScoreScene(size: self.size)
            let skView = self.view
            skView?.ignoresSiblingOrder = true
            skView?.presentScene(scene)
        }
        completion()
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

    fileprivate func setupBackground(){
        let radius = Int(self.frame.width/2 - 15)
        let graph = SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 8, odd: true)
        graph.zPosition = -10
        graph.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        self.addChild(graph)
    }
    fileprivate func setupLevelNode(){
        var buttonNames = ["Play", "Scores"]
        let xDistance:CGFloat = 80
        let width:CGFloat = 50
        let xSpace = xDistance + width
        let xInitialSpace = (xSpace*(1-CGFloat(buttonNames.count)))/2 // Offsets space
        for i in 0..<buttonNames.count{
            let level = SKSpriteNode(imageNamed: buttonNames[i])
            level.name = buttonNames[i]
            level.name = buttonNames[i]
            let increment = CGFloat(i)
            level.size = CGSize(width: 100,height: 100)
            level.position = CGPoint(x: xInitialSpace+xSpace*increment,y: 0)
            self.horizontalSlidingNode.addChild(level)
        }
        horizontalSlidingNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        horizontalSlidingNode.alpha = 1 //0
        horizontalSlidingNode.xScale = 1// 50
        horizontalSlidingNode.yScale = 1// 50
        self.addChild(horizontalSlidingNode)
        let effectDuration:TimeInterval = 1
        let scaling = SKAction.scale(to: 1, duration: effectDuration)
        let fading = SKAction.fadeAlpha(to: 1, duration: effectDuration)
        let timingFunction =  {(time:Float)->Float in
            return Float(sin(Double(time) * M_PI*0.5))
        }
        fading.timingFunction = timingFunction
        scaling.timingFunction = timingFunction
    }
    
}
