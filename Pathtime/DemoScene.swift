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

class DemoScene: SKScene {
    var skGraphs:[SKGraph]
    var nextSKGraphs:[SKGraph]
    var skScore:SKLabelNode
    var skTime:SKLabelNode
    var skGraphCounter:SKLabelNode
    var score:GameScore
    var level:Int
    var levelSprite:SKSpriteNode    
    fileprivate var skInstructionNodes:[SKNode]
    fileprivate var instructionNumber:Int
    fileprivate var tapTime:Bool
    fileprivate var nextVertexNodeToBeSelected:SKVertexNode?
    fileprivate  var gestureRecognizer:UITapGestureRecognizer
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
        self.skInstructionNodes = [SKNode]()
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
        self.instructionNumber = 0
        self.tapTime = false
        self.gestureRecognizer = UITapGestureRecognizer()
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
    
    fileprivate func next(){
        DispatchQueue.main.async{
             DispatchQueue.global(qos:DispatchQoS.QoSClass.userInitiated).async { // 1
                let radius = Int(self.frame.width/2 - 15)
                let graphGenerationBlock = Levels.Level[self.score.level + 1]
                let score = Scores.Level[self.score.level+1]
                let graphs = graphGenerationBlock(radius)
                DispatchQueue.main.async { // 2
                    let block = {()->() in
                        let scene = GameScene(size: self.size, graphs: graphs, level:self.score.level+1, score: score, graphGenerationBlock: Levels.Level[self.score.level+2])
                        let skView = self.view
                        skView?.ignoresSiblingOrder = true
                        skView?.presentScene(scene)
                    }
                    block()
                }
            }
        }
    }
    func getNextVertexToBeSelected(_ first:Bool)->SKVertexNode?{
        if first {
            return self.skGraph.vertexNodeMap.filter { (element) -> Bool in element.vertex.connections.count % 2 == 1}.first!
        }
        
        let nextVertex =  self.skGraph.edgeNodeMap.filter({(skEdgeNode) in (skEdgeNode.vertexA.vertex.uuid == self.selectedVertexNode!.vertex.uuid || skEdgeNode.vertexB.vertex.uuid == self.selectedVertexNode!.vertex.uuid ) && skEdgeNode.visited == false}).first?.getNextVertexFromVertex(self.selectedVertexNode!)
        print("Check")
        
        return nextVertex
    }
    var instructionNodes:[SKNode] = [SKNode]()
    func displayInstructions(){
        let idx = self.instructionNumber
        let instructions = ["Tap Here","To Connect Each Edge","", ""]
        print("running")
        let nextVertexNodeToBeSelected =  self.nextVertexNodeToBeSelected
        if idx < instructions.count - 1 {
            if idx > 0 {
                instructionNodes[idx-1].removeFromParent()
            }
            let skLabel = SKLabelNode(text: instructions[idx])
            skLabel.fontColor  = CustomColors.VertexColorHighlight
            skLabel.fontSize = 13
            skLabel.fontName = CustomFonts.Main
            let yOffset:CGFloat = 10
            if let position = nextVertexNodeToBeSelected?.position {
                var x = position.x + self.skGraph.position.x
                let y =  position.y + self.skGraph.position.y
                let distance:CGFloat = 100
                let space:CGFloat = 50
                if (x + distance) > self.frame.width {
                    x = x - space
                } else if (x - distance) < 0 {
                    x = x + space
                }
                skLabel.position = CGPoint(x: x,y: y + yOffset)
            }
            instructionNodes.append(skLabel)
            self.addChild(skLabel)
            skLabel.zPosition = 10000
        }else {
            if idx == instructions.count - 1  {
                instructionNodes[idx-1].removeFromParent()
            }
        }
        self.tapTime = false
        
//        if self.instructionNumber == 3 {
//            self.tapTime = true
//        }
        self.instructionNumber += 1
    
        
        print("CHECK *")
        self.blinkVertex(nextVertexNodeToBeSelected)
        print("CHECK *+")
    }
    override func didMove(to view: SKView) {
        self.topMargin = self.frame.height - 40
        self.bottomMargin =  40
        self.leftMargin = 30
        self.rightMargin = self.frame.width - 30
        self.setupScore()
        self.setupLevel()
        self.setupGraph(self.skGraphs[0])
        self.setupButtons()
        self.setupTime()
        self.setupGraphCounter()
        self.setupInstructions()
        self.addObservers()
        self.runInstructionNode(0..<4)
        self.nextVertexNodeToBeSelected = self.getNextVertexToBeSelected(true)
        self.displayInstructions()
        
        
        self.skGraph.vertexNodeMap.filter({(skVertexNode) in skVertexNode.vertex.visited == false}).forEach({(element) in print("NEW ONE false"); print(element.vertex.uuid.uuidString)})
        self.skGraph.vertexNodeMap.filter({(skVertexNode) in skVertexNode.vertex.visited == true}).forEach({(element) in print("NEW ONE true"); print(element.vertex.uuid.uuidString)})
        
        self.backgroundColor = CustomColors.BackGroundColor
        
//        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DemoScene.resetAll))
//        gestureRecognizer.numberOfTapsRequired = 2
//        self.view?.addGestureRecognizer(gestureRecognizer)
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
    fileprivate func runInstructionNode(_ range:Range<Int>){
        let r = [Int](range.lowerBound..<range.upperBound)
        let fadeTime:TimeInterval = 1
        let waitingTime:TimeInterval = 3
        _ = fadeTime + waitingTime
        let fadeOut = SKAction.fadeOut(withDuration: fadeTime)
        let fadeIn = SKAction.fadeIn(withDuration: fadeTime)
        let node = SKNode()
        for i in r {
            let newInstruction = self.skInstructionNodes[i]
            node.addChild(newInstruction)
        }
        self.addChild(node)
        node.run(SKAction.sequence([fadeIn,SKAction.wait(forDuration: waitingTime),fadeOut]))
        
    }
    fileprivate func setupInstructions(){
        let yOffset:CGFloat = 160
        let instructionText = ["Welcome To Pathtime!","Color each segment of the graph by tapping on the vertices.","Be careful! You may cross a line segment only once!","Choose your path wisely"]
        for i in 0...instructionText.count-1 {
            let labels =  instructionText[i]
            let ySpacing:CGFloat = 40
            let instructions = SKNode()
            for _ in 0...0 {
                let text = labels
                let instruction = SKLabelNode(text: text)
                instruction.fontSize = 15
                instruction.fontName = CustomFonts.Instruction
                instruction.fontColor = CustomColors.TextColor
                instruction.zPosition = 100
                instruction.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
                instruction.position = CGPoint(x: instructions.position.x,y: instructions.position.y-ySpacing*CGFloat(i))
                instructions.addChild(instruction)
            }
            instructions.alpha = 0
            instructions.position = CGPoint(x: self.frame.width/2, y: self.frame.height-yOffset)
            skInstructionNodes.append(instructions)
        }
    }
    fileprivate func setupGraph(_ skGraph:SKGraph){
        let yOffset:CGFloat = 20
        self.skGraph = skGraph
        self.skGraph.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2+yOffset)
        self.addChild(self.skGraph)
        self.skGraph.alpha = 0
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.3)
        self.skGraph.run(fadeIn)
        self.updateGraphCount()
    }
    fileprivate func setupLevel(){
        let level = SKSpriteNode(imageNamed: "Demo")
        level.zPosition = 100
        level.size = CGSize(width: 50, height: 50)
        level.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        addChild(level)
        let wait = SKAction.wait(forDuration: 1)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait,fadeOut,remove])
        level.run(sequence, completion: {()->() in self.repeatTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.ticker), userInfo: nil, repeats: true) })
        let levelSprite = SKSpriteNode(imageNamed: "Demo")
        levelSprite.size = CGSize(width: 50, height: 50)
        levelSprite.zPosition = 100
        levelSprite.position = CGPoint(x: self.frame.width/2,  y: self.topMargin)
        self.addChild(levelSprite)
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
        self.skTime.text = ""
    }
    func updateGraphCount(){
        let counter = self.graphCounter + 1
        self.skGraphCounter.text = "\(counter)/\(self.skGraphs.count)"
    }
    func ticker(){
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
    //Touch Handlers
    fileprivate func gameTouchHandler(_ touch:UITouch){
        switch touch.phase {
        case UITouchPhase.began:
            let location = touch.location(in: self)
            if let sKVertexNode = atPoint(location) as? SKVertexNode {
                print(sKVertexNode.vertex.uuid.uuidString)
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
    fileprivate func blinkVertex(_ sKVertexNode:SKVertexNode?){
        if let sKVertexNode = sKVertexNode {
        let scale:CGFloat = 2
        let expand = SKAction.scale(to: scale, duration: 0.5)
        let shrink = SKAction.scale(to: 1, duration: 0.5)
        let timingFunction =  {(time:Float)->Float in
            return Float(sin(Double(time) * M_PI*0.5))
        }
        expand.timingFunction = timingFunction
        shrink.timingFunction = timingFunction
        let sequence = SKAction.sequence([expand, shrink])
        let repeatSequence = SKAction.repeatForever(sequence)
        sKVertexNode.run(repeatSequence)
        }
    }
    fileprivate func selectNewVertex(_ sKVertexNode:SKVertexNode){
        if tapTime {
            return
        }
        if let uuid = self.nextVertexNodeToBeSelected?.vertex.uuid.uuidString {
            if uuid == sKVertexNode.vertex.uuid.uuidString {
                sKVertexNode.removeAllActions()
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
                    self.nextVertexNodeToBeSelected = self.getNextVertexToBeSelected(false)
                    print("dasdsad")
                    
                    self.displayInstructions()
                    
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
                                            }
                                        )
                                        self.selectedVertexNode = sKVertexNode
                                        self.nextVertexNodeToBeSelected = self.getNextVertexToBeSelected(false)
                                        print("dasdsad2")
                                        self.displayInstructions()
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
                self.selectedVertexNode = sKVertexNode
                self.nextVertexNodeToBeSelected = self.getNextVertexToBeSelected(false)
                self.displayInstructions()
            }
        }
        
    }
    fileprivate func nextGraph(){
        self.graphCounter = self.graphCounter + 1
        self.setupGraph(self.skGraphs[self.graphCounter])
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
        self.next()
        self.removeObservers()
        Game.FirstGame = false
        Game.Save()
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
        if tapTime {
            self.view?.removeGestureRecognizer(gestureRecognizer)
            self.displayInstructions()
        }
        for edge in self.skGraph.edgeNodeMap {
            self.resetEdge(edge)
        }
        for vertex in self.skGraph.vertexNodeMap {
            self.resetVertex(vertex)
        }
        self.selectedVertexNode = nil
        self.selectedEdgeNode = nil
        self.nextVertexNodeToBeSelected?.removeAllActions()
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
