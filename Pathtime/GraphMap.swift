//
//  GraphVertexMapper.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 25/11/15.
//  Copyright © 2015 Jonathan Fiorentini. All rights reserved.
// 
// This file contains helper classes that set the Graph in an Eucledian Space

import Foundation
import SpriteKit

class GraphMap {
    static func getSKVertexNodeMap(_ graph:Graph,radius:Int)->([SKVertexNode],[SKEdgeNode]){
        let skVertexNodeMap = getGraphNodeMap(graph,radius: radius)
        let graphEdgeMap = getGraphEdgeMap(skVertexNodeMap)
        var skEdgeNodeMap = [SKEdgeNode]()
        for mapEdge in graphEdgeMap {
            if mapEdge.startPoint != mapEdge.endPoint{
            let skedgeNode = SKEdgeNode(startPoint: mapEdge.startPoint, endPoint: mapEdge.endPoint,number: mapEdge.number, vertexA: mapEdge.vertexA, vertexB: mapEdge.vertexB)
                skedgeNode.zPosition = 0
                skEdgeNodeMap.append(skedgeNode)
            }
        }
        return (skVertexNodeMap,skEdgeNodeMap)
    }
    static fileprivate func getGraphEdgeMap(_ nodeMap:[SKVertexNode])->[SKEdgeNode]{
        var arrayOfConnections = [SKEdgeNode]()
        let vertexNodeMap = nodeMap
        for node in vertexNodeMap {
            let connectedNodes = vertexNodeMap.filter({(element) in element.vertex.connections.contains{(element2) in element2.uuid == node.vertex.uuid}})
            for i in 0 ..< connectedNodes.count {
                let connections = connectedNodes[i].vertex.connections.filter({(element) in element.uuid == node.vertex.uuid})
                for j in 0..<connections.count{
                    let mapEdge = SKEdgeNode(startPoint: node.position, endPoint: connectedNodes[i].position,number: j,vertexA: node, vertexB: connectedNodes[i])
                    arrayOfConnections.append(mapEdge)
                }
            }
        }
        let edgeMap = removeLoops(removeDuplicate(arrayOfConnections))
        return edgeMap
    }
    static fileprivate func getGraphNodeMap(_ graph:Graph,radius:Int)->[SKVertexNode]{
        var nodeMap = [SKVertexNode]()
        let counter = graph.vertices.count
        let rad = CGFloat((2*M_PI)/Double(counter))
        let offset = counter%2==1 ? CGFloat(M_PI/2) : CGFloat(0)
        let radius:CGFloat = CGFloat(radius)
        let center = CGPoint(x: 0, y: 0)
        for i in 0 ..< counter{
            let alpha = CGFloat(i)*rad + offset
            let x = center.x + cos(alpha)*radius
            let y = center.y + sin(alpha)*radius
            let mapNode = SKVertexNode(point: CGPoint(x: x, y: y), vertex: graph.vertices[i])
            mapNode.zPosition = 1
            nodeMap.append(mapNode)
        }
        return nodeMap
    }
    static fileprivate func removeLoops(_ skEdgeNodes:[SKEdgeNode])->[SKEdgeNode]{
        var tmp = [SKEdgeNode]()
        for skEdgeNode in skEdgeNodes {
            if skEdgeNode.endPoint == skEdgeNode.startPoint {
            }
            else {
                tmp.append(skEdgeNode)
            }
        }
        return tmp
    }
    static fileprivate func removeDuplicate(_ skEdgeNodes:[SKEdgeNode])->[SKEdgeNode]{
        var tmp = [SKEdgeNode]()
        for skEdgeNode in skEdgeNodes {
            if tmp.contains(where: {(element) in element.startPoint == skEdgeNode.endPoint && element.endPoint == skEdgeNode.startPoint && element.number == skEdgeNode.number}) {
            }
            else {
                tmp.append(skEdgeNode)
            }
        }
        return tmp
    }
}

