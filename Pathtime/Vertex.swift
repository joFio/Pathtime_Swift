//
//  Vertex.swift
//  EulerianPathDraft
//
//  Created by Jonathan on 29/10/15.
//  Copyright © 2015 Jonathan Fiorentini. All rights reserved.
//

import Foundation

class Vertex {
    
    let degree:Int
    var name:String
    var connections:[Vertex]
    let uuid:UUID
    var visited:Bool
    
    var description:String {
        var descr = ""
        for connection in connections {
            let connectionName = "\n \(connection.name)"
            descr = descr + connectionName
        }
        return "Name: \(self.name) \nDegree: \(self.degree) \nConnections: \(self.connections.count) \nConnectionNames: \(descr) "
    }
    
    init(degree:Int,name:String){
        self.degree = degree
        self.name = name
        self.connections = [Vertex]()
        self.uuid = UUID()
        self.visited = false
    }
    
    convenience init(degree:Int){
        self.init(degree: degree, name: UUID().uuidString)
    }
    
    func appendVertexToConnections(_ vertex:Vertex, first:Bool){
        self.connections.append(vertex)
        if first {
            vertex.appendVertexToConnections(self, first: false)
        }
    }
    
    func removeVertexFromConnections(_ vertex:Vertex, first:Bool){
        var index = -1
        for i in 0 ..< self.connections.count {
            if self.connections[i].uuid == vertex.uuid {
                index = i
                break
            }
        }
        
        if index != -1 {
            if first {
                self.connections[index].removeVertexFromConnections(self, first: false)
            }
            self.connections.remove(at: index)
        }
        
    }
    func didDirectLinkToVertices(_ vertices:[Vertex])->Bool{
        let sortedVertices = vertices.sorted(by: { $0.degree > $1.degree })
        var remainingConnections = max(degree - connections.count,0)
        while remainingConnections > 0 {
            var rand = Int(arc4random_uniform(UInt32(vertices.count)))
            var counter = 0
            if (remainingConnections == 1){
                while (sortedVertices[rand].uuid == self.uuid || !sortedVertices[rand].canAppend()){
                    rand = (rand + 1) % vertices.count
                    counter = counter + 1
                    if counter == sortedVertices.count {
                        return false
                    }
                }
            }
            else{
                while (!sortedVertices[rand].canAppend()){
                    rand = (rand + 1) % vertices.count
                    counter = counter + 1
                    if counter == sortedVertices.count {
                        return false
                    }
                }
            }
            self.connections.append(sortedVertices[rand])
            sortedVertices[rand].connections.append(self)
            remainingConnections = max(degree - connections.count, 0)
        }
        return true
    }
    
    fileprivate func canAppend()->Bool{
        if (degree>connections.count){
            return true
        }
        else {
            return false
        }
    }
}
