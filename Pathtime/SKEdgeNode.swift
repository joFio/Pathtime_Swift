//
//  SKEdgeNode.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 25/11/15.
//  Copyright © 2015 Jonathan Fiorentini. All rights reserved.
//

import Foundation
import SpriteKit

class SKEdgeNode:SKShapeNode {
    
    let startPoint:CGPoint
    let endPoint:CGPoint
    let number:Int
    let uuid:UUID
    let vertexA:SKVertexNode
    let vertexB:SKVertexNode
    var visited:Bool
    var highlight:SKShapeNode

    let precision:CGFloat // Selection precision    
    init(startPoint:CGPoint,endPoint:CGPoint,number:Int,vertexA:SKVertexNode,vertexB:SKVertexNode){
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.number = number
        self.vertexA = vertexA
        self.vertexB = vertexB
        self.uuid = UUID()
        self.visited = false
        self.highlight = SKShapeNode()
        self.precision = 0.9
        super.init()
        self.setupEdge()
        self.setupHighlight()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectEdgeAndGetVertex(_ vertex:SKVertexNode, atPoint point:CGPoint)->SKVertexNode?{
        if !visited{
            let percentage = self.getPercentageSelectedFromVertex(vertex, atPoint: point)
            let points = self.getStartEndPointsReverse(vertex)
            self.highlight.path = self.getPath(percentage, number: self.number, startPoint: points.0, endPoint: points.1, reverse: points.2)
            self.highlight.strokeColor = CustomColors.EdgeColorPartialHighlight
            self.highlight.lineWidth = 4
            if percentage > precision {
                self.highlight.strokeColor = CustomColors.EdgeColorHighlight
                self.highlight.path = self.getPath(1, number: self.number, startPoint: points.0, endPoint: points.1, reverse: points.2)
                self.visited = true
                self.highlight.lineWidth = 2
                return getNextVertexFromVertex(vertex)
            }
            return nil
        }
        return nil
    }
    
    
    func selectEdgeFromVertex(_ vertex:SKVertexNode, duration:TimeInterval){
        if !visited{
            let points = self.getStartEndPointsReverse(vertex)
            self.highlight.path = self.getPath(1, number: self.number, startPoint: points.1, endPoint: points.0, reverse: points.2)
            self.highlight.strokeColor = CustomColors.EdgeColorPartialHighlight
            self.highlight.lineWidth = 4
            self.highlight.alpha = 1
            self.visited = true
            print(self.visited)
            let timingFunction =  {(time:Float)->Float in
                return Float(sin(Double(time) * M_PI*0.5))
            }
            let actionBlock = {(node:SKNode, val:CGFloat)->() in
                if let edge = node as? SKEdgeNode {
                    let percent = val/CGFloat(duration)
                    edge.highlight.path = edge.getPath(percent, number: edge.number, startPoint: points.0, endPoint: points.1, reverse: points.2)
                }
            }
            let custom = SKAction.customAction(withDuration: duration, actionBlock: actionBlock)
            custom.timingFunction = timingFunction
            self.run(custom)
        }
    }
    fileprivate func setupHighlight(){
        self.highlight = SKShapeNode()
        self.highlight.lineWidth = 2
        self.addChild(self.highlight)
    }
    
    func getNextVertexFromVertex2(_ vertex:SKVertexNode)->SKVertexNode{
        if vertex.uuid == self.vertexA.uuid {
            return self.vertexB
        } else  {
            return self.vertexA
        }
    }
    
    
    func getNextVertexFromVertex(_ vertex:SKVertexNode)->SKVertexNode?{
        if vertex.uuid == self.vertexA.uuid {
            return self.vertexB
        } else  if vertex.uuid == self.vertexB.uuid {
            return self.vertexA
        }
        else {
        
            return nil
        }
    }
    
    func getAngle(_ vertex:SKVertexNode, atPoint point:CGPoint)->CGFloat {
        let points = self.getStartEndPointsReverse(vertex)
        let originPoint = points.0
        let targetPoint = points.1
        let a = Operations.vectorBetweenPoints(originPoint, and: point)
        let b = Operations.vectorBetweenPoints(originPoint, and: targetPoint)
        let AMagnitude = Operations.magnitude(a)
        let BMagnitude = Operations.magnitude(b)
        let dotProduct = Operations.dotProduct(a, vector2: b)
        let targetCos  = (dotProduct)/(AMagnitude*BMagnitude)
        return acos(targetCos)
    }
    
    fileprivate func getPercentageSelectedFromVertex(_ vertex:SKVertexNode, atPoint point:CGPoint)->CGFloat{
        let points = self.getStartEndPointsReverse(vertex)
        let originPoint = points.0
        let targetPoint = points.1
        let a = Operations.vectorBetweenPoints(originPoint, and: point)
        let b = Operations.vectorBetweenPoints(originPoint, and: targetPoint)
        let AMagnitude = Operations.magnitude(a)
        let BMagnitude = Operations.magnitude(b)
        let dotProduct = Operations.dotProduct(a, vector2: b)
        let targetCos  = (dotProduct)/(AMagnitude*BMagnitude)
        let projMagnitude = targetCos*AMagnitude
        
        var percentage = projMagnitude/BMagnitude
        percentage = percentage > 1 ? 1 : percentage<0 ? 0 : percentage    
        return percentage
    }
    
    fileprivate func getStartEndPointsReverse(_ vertex:SKVertexNode)->(CGPoint,CGPoint,Bool){
        if vertex.uuid == self.vertexA.uuid {
            return (self.startPoint,self.endPoint, false)
        } else {
            return (self.endPoint,self.startPoint, true)
        }
    }
    
    func getPath(_ percent:CGFloat,number:Int,startPoint:CGPoint,endPoint:CGPoint, reverse:Bool)->(CGPath){
        let ref = CGMutablePath()
        let vector = Operations.vectorBetweenPoints(startPoint, and: endPoint)
        let magnitude = Operations.magnitude(vector) // sqrt(pow(dx,2) + pow(dy,2))
        if number>0{
            let multiplier = CGFloat(1 + Double(number)*0.5)
            let radius:CGFloat = (magnitude/2)*multiplier
            let targetCos = (magnitude/2)/radius
            var alpha  = (CGFloat(M_PI/2) - CGFloat(acos(targetCos)))*2
            alpha = alpha > CGFloat(M_PI) ? alpha - CGFloat(M_PI) : alpha
            let targetSin = sqrt(1-pow(targetCos,2))
            let distanceToCenter = targetSin*radius
            var rev:CGFloat = 1
            if reverse{
                rev = -1
            }
            let unitVector = Operations.unitVector(vector)
            let normalVector = Operations.normalVector(unitVector)
            let x = startPoint.x + 0.5*vector.dx + rev*normalVector.dx*distanceToCenter
            let y = startPoint.y + 0.5*vector.dy + rev*normalVector.dy*distanceToCenter
            let offset = CGFloat(atan2(vector.dy, vector.dx))
            let start = offset + rev*(-CGFloat(M_PI/2) - alpha/2)
            let end = offset + rev*(-CGFloat(M_PI/2)  - alpha/2 + percent*alpha)
            
            ref.addArc(center: CGPoint(x: x,y: y), radius: radius,startAngle: start, endAngle:  end, clockwise: reverse)
        }
        else {
            let x = startPoint.x + percent*vector.dx
            let y = startPoint.y + percent*vector.dy
            ref.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            ref.addLine(to: CGPoint( x:x, y:y))
        }
        return ref
    }
    
    fileprivate func setupEdge(){
        self.path = self.getPath(1, number: self.number, startPoint: self.startPoint, endPoint: self.endPoint, reverse: false)
        self.strokeColor = CustomColors.EdgeColor
        self.name = self.name
        self.lineWidth = 1
        self.fillColor = UIColor.clear
    }
}
