//
//  MApper.swift
//  EulerianPathDraft2
//
//  Created by Jonathan on 30/10/15.
//  Copyright © 2015 Jonathan Fiorentini. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class SKGraph:SKNode {
    var vertexNodeMap:[SKVertexNode]
    var edgeNodeMap:[SKEdgeNode]
    var completed:Bool
    let graph:Graph
    
    init(radius:Int,graph:Graph){
        self.graph = graph
        self.completed = false
        let graphMap = GraphMap.getSKVertexNodeMap(graph, radius: radius)
        self.vertexNodeMap = graphMap.0
        self.edgeNodeMap = graphMap.1
        super.init()
        self.setupVertices()
        self.setupEdges()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupVertices() {
        for node in self.vertexNodeMap {
            self.addChild(node)
        }
    }
    fileprivate func setupEdges(){
        for edgeNode in self.edgeNodeMap {
            self.addChild(edgeNode)
        }
    }
    func isEdgeRemovable(_ edge:SKEdgeNode)->Bool{
        var index = -1
        for i in 0 ..< self.edgeNodeMap.count {
            if self.edgeNodeMap[i].uuid == edge.uuid {
                index = i
                break
            }
        }
        if (edge.vertexA.vertex.connections.count % 2 + edge.vertexB.vertex.connections.count % 2) != 1 {
            return false
        }
        let vertexB = self.edgeNodeMap[index].vertexB.vertex
        self.edgeNodeMap[index].vertexA.vertex.removeVertexFromConnections(self.edgeNodeMap[index].vertexB.vertex, first: true)
        if !(Graph.areConnected(self.graph.vertices)) {
            self.edgeNodeMap[index].vertexA.vertex.appendVertexToConnections(vertexB, first: true)
            return false
        }
        self.edgeNodeMap[index].vertexA.vertex.appendVertexToConnections(vertexB, first: true)
        return true
    }
    func removeEdge(_ edge:SKEdgeNode, check:Bool) {
        var index = -1
        for i in 0 ..< self.edgeNodeMap.count {
            if self.edgeNodeMap[i].uuid == edge.uuid {
                index = i
                break
            }
        }
        if check {
            if !self.isEdgeRemovable(edge) {
                return
            }
            if self.edgeNodeMap[index].vertexA.vertex.connections.count == 0 {
                self.removeVertex(self.edgeNodeMap[index].vertexA, check: false)
            }
            if self.edgeNodeMap[index].vertexB.vertex.connections.count == 0 {
                self.removeVertex(self.edgeNodeMap[index].vertexB, check: false)
            }
        }
        self.edgeNodeMap[index].vertexA.vertex.removeVertexFromConnections(self.edgeNodeMap[index].vertexB.vertex, first: true)
        self.edgeNodeMap.remove(at: index)
        edge.removeFromParent()
    }
    
    func isVertexRemovable(_ vertex:SKVertexNode)->Bool{
        var index = -1
        for i in 0 ..< self.vertexNodeMap.count {
            if self.vertexNodeMap[i].uuid == vertex.uuid {
                index = i
                break
            }
        }
        if (vertex.vertex.connections.count % 2 != 0) {
            return false
        }
        var evenDelta = 0
        var oddDelta = 0
        evenDelta = -1
        for vertex in self.vertexNodeMap[index].vertex.connections {
            let connections = vertex.connections
            let relatedConnections = vertex.connections.filter({(element) in element.uuid == self.vertexNodeMap[index].vertex.uuid})
            let final = connections.count - relatedConnections.count
            if connections.count % 2 == 0{
                evenDelta = evenDelta - 1
            } else {
                oddDelta = oddDelta - 1
            }
            if final % 2 == 0 {
                evenDelta = evenDelta + 1
            } else {
                oddDelta = oddDelta + 1
            }
        }
        if oddDelta != 0 && oddDelta != -2 {
            return false
        }
        for connection in vertex.vertex.connections {
            connection.removeVertexFromConnections(vertex.vertex, first: true)
            if (!Graph.areConnected(self.graph.vertices)) {
                connection.appendVertexToConnections(vertex.vertex, first: true)
                return false
            }
            connection.appendVertexToConnections(vertex.vertex, first: true)
        }
        return true
    }
    func removeVertex(_ vertex:SKVertexNode, check:Bool){
        var index = -1
        for i in 0 ..< self.vertexNodeMap.count {
            if self.vertexNodeMap[i].uuid == vertex.uuid {
                index = i
                break
            }
        }
        if check{
            if !self.isVertexRemovable(vertex){
                return
            }
            for edge in self.edgeNodeMap.filter({(element) in element.vertexA.vertex.uuid == vertex.vertex.uuid || element.vertexB.vertex.uuid == vertex.vertex.uuid }) {
                self.removeEdge(edge, check: false)
            }
            vertex.removeFromParent()
            self.vertexNodeMap.remove(at: index)
            return
        }
        self.vertexNodeMap.remove(at: index)
        vertex.removeFromParent()
    }
    
    static func generateGraph(_ radius:Int,vertexNumber:Int,connectionNumber:Int, odd:Bool)->SKGraph{
        if vertexNumber > connectionNumber {
            fatalError("There are more vertices than connections")
        }
        var vertices = [Vertex]()
        let defaultNumber = 2*(connectionNumber/vertexNumber)
        var credit = 2*(connectionNumber%vertexNumber)
        var degrees = [Int](repeating: defaultNumber, count: vertexNumber)
        if odd{
            degrees[0] = degrees[0] - 1
            degrees[1] = degrees[1] + 1
        }
        for i in 0 ..< vertexNumber {
            if credit > 0 {
                degrees[i] = degrees[i] + 2
                credit = credit - 2
            }
        }
        for degree in degrees {
            let vertex = Vertex(degree:degree)
            vertices.append(vertex)
        }
        let graph = Graph(vertices: vertices, complexity: 0)
        return SKGraph(radius: radius, graph: graph)
    }
}
