//
//  Levels.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 1/3/16.
//  Copyright © 2016 Jonathan Fiorentini. All rights reserved.
//

import Foundation

class Levels {
    
    static var Level:[(Int)->[SKGraph]] {
        get {
            return [Levels.level1, Levels.level2,Levels.level3,Levels.level4,Levels.level5,Levels.level6,Levels.level7,Levels.level8,Levels.level9,Levels.level10,Levels.level11,Levels.level12]
        }
    }
    
    static var Demo = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 4, odd: true),
            ]
        return graphs
    }

   fileprivate static var level1 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 5, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 6, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 7, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 8, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 9, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 10, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 11, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 4, connectionNumber: 12, odd: true),
        ]
        return graphs
    }
    fileprivate static var level2 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 5, connectionNumber: 5, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 5, connectionNumber: 6, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 5, connectionNumber: 7, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 5, connectionNumber: 8, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 5, connectionNumber: 9, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 5, connectionNumber: 10, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 5, connectionNumber: 11, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 5, connectionNumber: 12, odd: true),
        ]
        return graphs
    }
    fileprivate static var level3 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 12, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 12, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 13, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 14, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 11, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 12, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 13, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 6, connectionNumber: 14, odd: true),
        ]
        return graphs
    }
    fileprivate static var level4 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 7, connectionNumber: 12, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 7, connectionNumber: 13, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 7, connectionNumber: 14, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 7, connectionNumber: 15, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 7, connectionNumber: 16, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 7, connectionNumber: 17, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 7, connectionNumber: 18, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 7, connectionNumber: 18, odd: true),
        ]
        return graphs
    }
    fileprivate static var level5 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 8, connectionNumber: 12, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 8, connectionNumber: 13, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 8, connectionNumber: 14, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 8, connectionNumber: 15, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 8, connectionNumber: 16, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 8, connectionNumber: 17, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 8, connectionNumber: 18, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 8, connectionNumber: 18, odd: true),
        ]
        return graphs
    }
    fileprivate static var level6 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 10, connectionNumber: 15, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 10, connectionNumber: 16, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 10, connectionNumber: 17, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 10, connectionNumber: 18, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 10, connectionNumber: 19, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 10, connectionNumber: 20, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 10, connectionNumber: 21, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 10, connectionNumber: 22, odd: true),
        ]
        return graphs
    }
    fileprivate static var level7 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 11, connectionNumber: 15, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 11, connectionNumber: 16, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 11, connectionNumber: 17, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 11, connectionNumber: 18, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 11, connectionNumber: 19, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 11, connectionNumber: 20, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 11, connectionNumber: 21, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 11, connectionNumber: 22, odd: true),
        ]
        return graphs
    }
    fileprivate static var level8 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 12, connectionNumber: 15, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 12, connectionNumber: 16, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 12, connectionNumber: 17, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 12, connectionNumber: 18, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 12, connectionNumber: 19, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 12, connectionNumber: 20, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 12, connectionNumber: 21, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 12, connectionNumber: 22, odd: true),
        ]
        return graphs
    }
    
    fileprivate static var level9 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 13, connectionNumber: 15, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 13, connectionNumber: 16, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 13, connectionNumber: 17, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 13, connectionNumber: 18, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 13, connectionNumber: 19, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 13, connectionNumber: 20, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 13, connectionNumber: 21, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 13, connectionNumber: 22, odd: true),
        ]
        return graphs
    }
    fileprivate static var level10 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 14, connectionNumber: 16, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 14, connectionNumber: 17, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 14, connectionNumber: 18, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 14, connectionNumber: 19, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 14, connectionNumber: 20, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 14, connectionNumber: 21, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 14, connectionNumber: 22, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 23, odd: true),
        ]
        return graphs
    }
    fileprivate static var level11 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 18, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 19, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 20, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 21, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 22, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 23, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 24, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 15, connectionNumber: 25, odd: true),
        ]
        return graphs
    }
    fileprivate static var level12 = {(radius:Int)->[SKGraph] in
        var graphs = [
            SKGraph.generateGraph(radius, vertexNumber: 16, connectionNumber: 19, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 16, connectionNumber: 20, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 16, connectionNumber: 21, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 16, connectionNumber: 22, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 16, connectionNumber: 23, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 16, connectionNumber: 24, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 16, connectionNumber: 25, odd: true),
            SKGraph.generateGraph(radius, vertexNumber: 16, connectionNumber: 26, odd: true),
        ]
        return graphs
    }
   
    
}
