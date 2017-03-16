//
//  Graph.swift
//  EulerianPathDraft
//
//  Created by Jonathan on 29/10/15.
//  Copyright © 2015 Jonathan Fiorentini. All rights reserved.
//

import Foundation

class Graph{
    var vertices:[Vertex]
    init(vertices:[Vertex], complexity:Int)
    {
        self.vertices = vertices
        self.connectVertices(complexity)
        self.getLoops()
    }
    
    func describe(){
        for vertex in vertices{
            print(vertex.description)
        }
    }
    fileprivate func connectVertices(_ complexity:Int)
    {
        var counter = 0
        repeat {
            counter = counter + 1
            Graph.resetConnections(self.vertices)
            let sortedVertices = vertices.sorted(by: { $0.degree < $1.degree })
            for vertex in sortedVertices {
                let check = vertex.didDirectLinkToVertices(vertices)
                if (!check) {
                    continue
                }
            }
        } while Graph.isEulerian(self.vertices) == 0 || self.isAutoConnected(complexity)
    }
    fileprivate func isAutoConnected(_ limit:Int)->Bool{
        for vertex in self.vertices {
            if Graph.getAutoConnections(vertex).count>limit{
                return true
            }
        }
        return false
    }
    
    
   
    fileprivate func getLoops(){
        for vertex in self.vertices {
            print(Graph.getLoopNumber(vertex))
        }
    }
    
    fileprivate static func getAutoConnections(_ vertex:Vertex)->[Vertex]{
        return vertex.connections.filter({(element) in element.uuid == vertex.uuid})
    }
    
    fileprivate static func getLoopNumber(_ vertex:Vertex)->Int{
        var temp = [Vertex]()
        var counter = 0
        for vertex in vertex.connections {
            if (temp.contains(where: {(element) in element.uuid == vertex.uuid })){
                counter = counter + 1
            }
            temp.append(vertex)
        }
        return counter
    }
    fileprivate static func DFSUtil(_ vertex:Vertex){
        vertex.visited = true
        for connection in vertex.connections {
            if (!connection.visited){
                DFSUtil(connection)
            }
        }
    }
    static func areConnected(_ vertices:[Vertex])->Bool{
        for vertex in vertices {
            vertex.visited = false
        }
        for i in 0 ..< vertices.count {
            if (vertices[i].degree != 0) {
                Graph.DFSUtil(vertices[i])
                break
            }
            if i == vertices.count-1 {
                return false
            }
        }
        
        for i in 0 ..< vertices.count {
            if(vertices[i].visited == false && vertices[i].degree>0){
                return false
            }
        }
        return true
    }

    fileprivate static func resetConnections(_ vertices:[Vertex]){
        for vertex in vertices {
            vertex.connections.removeAll()
            vertex.visited = false
        }
    }
    
    fileprivate static func isEulerian(_ vertices:[Vertex])->Int{
        if (!Graph.areConnected(vertices)){
            return 0
        }
        var counter = 0
        for vertex in vertices {
            if (vertex.connections.count % 2 == 1){
                counter = counter + 1
            }
        }
        if (counter == 2) {
            return 1
        }
        
        if (counter == 0) {
            return 2
        }
        return 0
    }
}
