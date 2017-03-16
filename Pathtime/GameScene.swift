//
//  GameScene.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 30/10/15.
//  Copyright (c) 2015 Jonathan Fiorentini. All rights reserved.
//
// Emitter on the touch object

import SpriteKit
import Foundation
import AudioToolbox
import AVFoundation

class GameScene: SKScene {
    var skGraphs:[SKGraph]
    var nextSKGraphs:[SKGraph]
    var skScore:SKLabelNode
    var skTime:SKLabelNode
    var skGraphCounter:SKLabelNode
    var score:GameScore
    var level:Int
    var levelSprite:SKSpriteNode
    
    fileprivate var startTime:Date
    fileprivate var skGraph:SKGraph!
    fileprivate var selectedVertexNode:SKVertexNode?
    fileprivate var selectedEdgeNode:SKEdgeNode?
    fileprivate var graphCounter = 0
    fileprivate var gameInteraction = GameInteraction.normal
    fileprivate var repeatTimer:Timer
    fileprivate var graphGenerationBlock:(Int)->[SKGraph]
    fileprivate var topMargin:CGFloat
    fileprivate var bottomMargin:CGFloat
    fileprivate var leftMargin:CGFloat
    fileprivate var rightMargin:CGFloat
    init(size:CGSize, graphs:[SKGraph], level:Int, score:GameScore, graphGenerationBlock:@escaping (Int)->[SKGraph]) {
        self.skScore = SKLabelNode()
        self.skGraphCounter = SKLabelNode()
        self.skTime = SKLabelNode()
        self.startTime = Date()
        self.repeatTimer = Timer()
        self.nextSKGraphs = [SKGraph]()
        self.levelSprite = SKSpriteNode()
        self.topMargin = CGFloat()
        self.bottomMargin = CGFloat()
        self.leftMargin = CGFloat()
        self.rightMargin = CGFloat()
        self.score = score
        self.skGraphs = graphs
        self.level = level
        self.graphGenerationBlock = graphGenerationBlock
        super.init(size: size)
        self.score.level = level
        self.score.totalGraphs = graphs.count
        self.prepareNextGraphsWithBlock(graphGenerationBlock)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchHandlerManager(touch, gameMode: gameInteraction)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchHandlerManager(touch,gameMode: gameInteraction)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchHandlerManager(touch,gameMode: gameInteraction)
        }
    }
    func displayInstructions(){
        let instructions = "Double Tap On the Screen to Start Over"
        let skLabel = SKLabelNode(text:instructions)
        skLabel.fontColor  = CustomColors.VertexColorHighlight
        skLabel.fontSize = 13
        skLabel.fontName = CustomFonts.Main
        skLabel.position = CGPoint(x: self.frame.width/2, y: 120)
        self.addChild(skLabel)
        skLabel.alpha = 0
        let actionSequence = SKAction.sequence([SKAction.fadeIn(withDuration: 0.3),SKAction.wait(forDuration: 3),SKAction.fadeOut(withDuration: 0.3)])
        skLabel.run(actionSequence)
    }

    
    override func didMove(to view: SKView) {
        self.topMargin = self.frame.height - 40
        self.bottomMargin =  40
        self.leftMargin = 30
        self.rightMargin = self.frame.width - 30
        self.setupScore()
        self.setupLevel()
        self.setupGraph(self.skGraphs[0], delay: 1.2)
        self.setupButtons()
        self.setupTime()
        self.setupGraphCounter()
        self.addObservers()
        self.backgroundColor = CustomColors.BackGroundColor
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameScene.resetAll))
        gestureRecognizer.numberOfTapsRequired = 2
        self.view?.addGestureRecognizer(gestureRecognizer)
    }
    fileprivate func addObservers() {
        let block = {(notification:Notification)->() in
            if (notification.object as? GameScore) != nil {
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notifications.GameScore), object: nil, queue: OperationQueue.main, using: block)
    }
    fileprivate func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.GameScore), object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //    Setups
    fileprivate func setupGraph(_ skGraph:SKGraph, delay:Double){
        let yOffset:CGFloat = 20
        self.skGraph = skGraph
        self.skGraph.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2+yOffset)
        self.addChild(self.skGraph)
        self.skGraph.alpha = 0
        let wait = SKAction.wait(forDuration: delay)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.3)
        let sequence = SKAction.sequence([wait,fadeIn])
        self.skGraph.run(sequence, completion: {()->() in  self.startTime = Date();
        })
        self.updateGraphCount()
        if self.graphCounter < 3 {
            self.displayInstructions()
        }

    }
    fileprivate func setupLevel(){
        let atlas = SKTextureAtlas(named: Keys.LevelAtlas)
        let index = self.level
        let texture = atlas.textureNamed(Keys.LevelAtlasTextures[index])
        let level = SKSpriteNode(texture: texture)
        level.zPosition = 100
        level.size = CGSize(width: 50, height: 50)
        level.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        addChild(level)
        let wait = SKAction.wait(forDuration: 1)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait,fadeOut,remove])
        level.run(sequence, completion: {()->() in self.repeatTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.ticker), userInfo: nil, repeats: true) })
        let levelSprite = SKSpriteNode(texture: texture)
        let levelTextLabel = SKSpriteNode(imageNamed: "Level")
        levelSprite.size = CGSize(width: 30, height: 30)
        levelTextLabel.size = CGSize(width: 50, height: 50)
        levelSprite.zPosition = 100
        let xDistance:CGFloat = 10
        let xOffset = (xDistance + levelSprite.frame.width/2)/2
        levelTextLabel.position = CGPoint(x: self.frame.width/2-xOffset, y: self.topMargin)
        levelSprite.position = CGPoint(x: levelTextLabel.position.x + levelTextLabel.frame.width/2 + xDistance,  y: self.topMargin)
        self.addChild(levelSprite)
        self.addChild(levelTextLabel)
    }
    fileprivate func setupScore(){
        self.skScore = SKLabelNode()
        self.skScore.fontSize = 15
        self.skScore.fontName = CustomFonts.Main
        self.skScore.fontColor = CustomColors.TextColor
        self.skScore.zPosition = 100
        self.skScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        self.skScore.position = CGPoint(x: self.frame.width/2, y: self.bottomMargin + 40)
        self.updateScore()
        self.addChild(self.skScore)
    }
    fileprivate func setupGraphCounter(){
        self.skGraphCounter = SKLabelNode()
        self.skGraphCounter.fontSize = 20
        self.skGraphCounter.fontName = CustomFonts.Main
        self.skGraphCounter.fontColor = CustomColors.TextColor
        self.skGraphCounter.zPosition = 100
        self.skGraphCounter.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        self.skGraphCounter.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        self.skGraphCounter.position = CGPoint(x: self.leftMargin, y: self.topMargin)
        self.updateGraphCount()
        self.addChild(self.skGraphCounter)
    }
    fileprivate func setupTime(){
        self.skTime = SKLabelNode()
        self.updateTimer()
        self.skTime.fontSize = 20
        self.skTime.fontName = CustomFonts.Main
        self.skTime.fontColor = CustomColors.TextColor
        self.skTime.zPosition = 100
        self.skTime.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        self.skTime.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        self.skTime.position = CGPoint(x: self.rightMargin, y: self.topMargin)
        self.addChild(self.skTime)
    }
    fileprivate func setupButtons(){
        let size = CGSize(width: 70, height: 70)
        let exit = SKSpriteNode(imageNamed: "Exit")
        exit.size = size
        exit.name = "Exit"
        exit.position = CGPoint(x: self.frame.width/2 , y: self.bottomMargin + 20)
        self.addChild(exit)
    }
    fileprivate func prepareNextGraphsWithBlock(_ block:@escaping (Int)->[SKGraph]){
       DispatchQueue.global(qos:DispatchQoS.QoSClass.background).async { // 1
            let radius = Int(self.frame.width/2 - 15)
            self.nextSKGraphs = block(radius)
        }
    }
    func updateScore(){
        self.skScore.text = "Points: \(self.score.currentPoints)"
    }
    func updateTimer(){
        let mins = Int(self.score.remainingPlayingTime) / 60
        let secs = Int(self.score.remainingPlayingTime) % 60
        var time = ""
        if secs < 10 {
            time = "\(mins):0\(secs)"
        }else {
            time = "\(mins):\(secs)"
        }
        self.skTime.text = time
    }
    
    func updateGraphCount(){
        let counter = self.graphCounter + 1
        self.skGraphCounter.text = "\(counter)/\(self.skGraphs.count)"
    }
    func ticker(){
        self.score.tick()
        self.updateTimer()
        if self.score.remainingPlayingTime < 10 {
            let scale:CGFloat = 2
            let expand = SKAction.scale(to: scale, duration: 0.3)
            let shrink = SKAction.scale(to: 1, duration: 0.3)
            let timingFunction =  {(time:Float)->Float in
                return Float(sin(Double(time) * M_PI*0.5))
            }
            expand.timingFunction = timingFunction
            shrink.timingFunction = timingFunction
            let sequence = SKAction.sequence([expand, shrink])
            self.skTime.fontColor = CustomColors.TimerSoonFinished
            self.skTime.run(sequence)
        }
        else {
            self.skTime.fontColor = CustomColors.TextColor
            
        }
        if self.score.remainingPlayingTime == 0 {
            self.isGameOver()
        }
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
    
    //    Touch Handlers
    fileprivate func gameTouchHandler(_ touch:UITouch){
        switch touch.phase {
        case UITouchPhase.began:
            let location = touch.location(in: self)
            if let sKVertexNode = atPoint(location) as? SKVertexNode {
                self.selectNewVertex(sKVertexNode)
            }
            else if let enhancedTouch = atPoint(location) as? SKShapeNode {
                if let sKVertexNode = enhancedTouch.parent as? SKVertexNode {
                    self.selectNewVertex(sKVertexNode)
                }
            }
            if let node = atPoint(location).name {
                if node == "Exit" {
                    let scene = MenuScene(size: self.size)
                    let skView = self.view
                    skView?.ignoresSiblingOrder = true
                    skView?.presentScene(scene)
                }
            }
            
            break
        default:
            break
        }
    }
    
    //    Rules and Logic
    fileprivate func touchHandlerManager(_ touch:UITouch, gameMode:GameInteraction){
        switch gameMode {
            
        default:
            self.gameTouchHandler(touch)
        }
    }
    fileprivate func highlightVertex(_ sKVertexNode:SKVertexNode){
        sKVertexNode.fillColor = CustomColors.VertexColorHighlight
    }
    fileprivate func unhighlightVertex(_ sKVertexNode:SKVertexNode?){
        if let sKVertexNode = sKVertexNode {
            
            sKVertexNode.fillColor = CustomColors.VertexColor
        }
    }
    fileprivate func selectNewVertex(_ sKVertexNode:SKVertexNode){
        let scale:CGFloat = 2
        let expand = SKAction.scale(to: scale, duration: 0.3)
        let shrink = SKAction.scale(to: 1, duration: 0.3)
        let timingFunction =  {(time:Float)->Float in
            return Float(sin(Double(time) * M_PI*0.5))
        }
        expand.timingFunction = timingFunction
        shrink.timingFunction = timingFunction
        let sequence = SKAction.sequence([expand, shrink])
        sKVertexNode.run(sequence)
        if self.selectedVertexNode == nil {
            unhighlightVertex(self.selectedVertexNode)
            self.selectedVertexNode = sKVertexNode
            self.highlightVertex(sKVertexNode)
            return
        }
        if let previouslySelectedVertexNode = self.selectedVertexNode{
            let newlySelectedVertexNode = sKVertexNode
            if  newlySelectedVertexNode.vertex.connections.contains(where: {(element) in element.uuid == previouslySelectedVertexNode.vertex.uuid}) {
                for edge in self.skGraph.edgeNodeMap {
                    if !edge.visited{
                        if let otherVertexNode = edge.getNextVertexFromVertex(newlySelectedVertexNode) {
                            if otherVertexNode.vertex.uuid == previouslySelectedVertexNode.vertex.uuid{
                                let duration = 0.5
                                edge.selectEdgeFromVertex(previouslySelectedVertexNode, duration: duration)
                                unhighlightVertex(self.selectedVertexNode)
                                self.highlightVertex(sKVertexNode)
                                let wait = SKAction.wait(forDuration: duration)
                                let state = self.checkState(self.skGraph, vertex: newlySelectedVertexNode)
                                
                                self.selectedVertexNode!.run(wait, completion: {()->() in
                                    if state == 1 {
                                        self.didSolve()
                                    }else if state == -1 {
                                        self.didNotSolve()
                                    }
                                    
                                })
                                self.selectedVertexNode = sKVertexNode
                                
                                break
                            }
                        }
                    }
                }
            }
            
        }
    }
    fileprivate func nextGraph(){
        self.graphCounter = self.graphCounter + 1
        self.setupGraph(self.skGraphs[self.graphCounter], delay: 0)
    }
    fileprivate func isGameOver(){
        self.skGraph.removeFromParent()
        self.repeatTimer.invalidate()
        let scene = StatScene(size: self.size, score: self.score)
        let skView = self.view
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)
    }
    fileprivate static func getScoreBoardWith(_ score:GameScore)->SKNode {
        let statBoard = SKSpriteNode(imageNamed: "appTest")
        let label = SKLabelNode(text: "StatBoard")
        label.fontColor = CustomColors.TextColor
        label.zPosition = 10
        statBoard.size = CGSize(width: 200, height: 400)
        statBoard.addChild(label)
        statBoard.alpha = 0
        let fadeInTime:TimeInterval = 0.5
        let fadeInBoard = SKAction.fadeAlpha(to: 0.7, duration: fadeInTime)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: fadeInTime)
        statBoard.run(fadeInBoard)
        label.run(fadeIn)
        return statBoard
    }
    fileprivate func didWin(){
        self.skGraph.removeFromParent()
        self.repeatTimer.invalidate()
        let scene = StatScene(size: self.size, score: self.score)
        let skView = self.view
        skView?.ignoresSiblingOrder = true
        skView?.presentScene(scene)
        self.removeObservers()
    }
    
    fileprivate func didSolve(){
        self.selectedVertexNode = nil
        self.selectedEdgeNode = nil
        let interval = -self.startTime.timeIntervalSinceNow
        self.startTime = Date()
        print("Solving time: \(interval)")
        self.score.solve(interval)
        self.updateScore()
        self.updateGraphCount()
        let fadeOutTime:TimeInterval = 1
        let shrink = SKAction.scale(to: 0, duration: fadeOutTime)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: fadeOutTime)
        let spin = SKAction.rotate(byAngle: CGFloat(M_PI)*4, duration:fadeOutTime)
        let wait = SKAction.wait(forDuration: fadeOutTime)
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, removeFromParent])
        var completionBlock = {()->Void in self.nextGraph() }
        if self.graphCounter == self.skGraphs.count - 1 {
            completionBlock = {()->Void in self.didWin() }
            
        }
        self.skGraph.run(spin)
        self.skGraph.run(fadeOut)
        self.skGraph.run(shrink)
        self.skGraph.run(sequence, completion: completionBlock)
    }
    
    fileprivate func didNotSolve(){
        SKMotion.shake(self.skGraph, duration:0.5)
        let wait = SKAction.wait(forDuration: 0.5)
        self.skGraph.run(wait, completion: {()->() in self.resetAll()})
    }
  
    
    fileprivate func resetEdge(_ skEdgeNode:SKEdgeNode){
        skEdgeNode.visited = false
        skEdgeNode.highlight.alpha =  0
        skEdgeNode.highlight.path = nil
        
    }
    fileprivate func resetVertex(_ skVertexNode:SKVertexNode){
        skVertexNode.fillColor = CustomColors.VertexColor
    }
    func resetAll(){        
        for edge in self.skGraph.edgeNodeMap {
            self.resetEdge(edge)
        }
        for vertex in self.skGraph.vertexNodeMap {
            self.resetVertex(vertex)
        }
        self.selectedVertexNode = nil
        self.selectedEdgeNode = nil
    }
    fileprivate func checkState(_ skGraph:SKGraph, vertex:SKVertexNode)->Int{
        if self.getPotentialEdges(skGraph, vertex: vertex).count == 0 {
            let edgeCount = skGraph.edgeNodeMap.count
            let visitedEdgeCount = skGraph.edgeNodeMap.filter({(element) in element.visited == true}).count
            if edgeCount == visitedEdgeCount {
                return 1
            }else {
                return -1
            }
        } else {
            return 0
        }
    }
    fileprivate func canSelectEdge(_ skEdgeNode:SKEdgeNode, skGraph:SKGraph, vertex:SKVertexNode)->Bool{
        let potentialEdges = self.getPotentialEdges(skGraph,vertex: vertex)
        if potentialEdges.contains(where: {(element) in element.uuid == skEdgeNode.uuid}){
            return true
        }
        return false
    }
    fileprivate func getPotentialEdges(_ sKGraph:SKGraph,vertex:SKVertexNode)->[SKEdgeNode]{
        let unvisitedEdges = sKGraph.edgeNodeMap.filter({(element) in element.visited == false})
        let potentialEdges = unvisitedEdges.filter({(element) in element.vertexA.uuid.uuidString == vertex.uuid.uuidString ||  element.vertexB.uuid.uuidString == vertex.uuid.uuidString })
        return potentialEdges
    }
}
