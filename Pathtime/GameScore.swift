//
//  Score.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 3/2/16.
//  Copyright © 2016 Jonathan Fiorentini. All rights reserved.
//

import Foundation

class GameScore:NSObject,NSCoding{
    var level:Int
    var totalGraphs:Int
    var solvedGraphsCount:Int
    var solvingTimes:[Double]
    var remainingPlayingTime:Double
    var cumulatedPlayingTime:Double
    var additionalTime:Double = 10
    var earnedPoints:Int?
    var hats:Int?
    var currentPoints:Int = 0
    var parTime:Double
    override init (){
        self.remainingPlayingTime = 0
        self.solvingTimes = [Double]()
        self.solvedGraphsCount = 0
        self.level = 1
        self.totalGraphs = 0
        self.cumulatedPlayingTime = 0
        self.parTime = 0
    }
    init(startPlayingTime:Double, totalGraphs:Int, parTime:Double) {
        self.remainingPlayingTime = startPlayingTime
        self.totalGraphs = totalGraphs
        self.solvingTimes = [Double]()
        self.solvedGraphsCount = 0
        self.cumulatedPlayingTime = 0
        self.level = 1
        self.parTime = parTime
    }
    func solve(_ time:Double){
        self.solvingTimes.append(time)
        self.solvedGraphsCount = self.solvedGraphsCount + 1
        self.timeIncrement()
        self.currentPoints = self.currentPoints + Scores.Reward["GraphCountPoints"]!
    }
    func nextLevel(){
        level = level + 1
    }
    func tick(){
        remainingPlayingTime = remainingPlayingTime - 1
        self.cumulatedPlayingTime =  self.cumulatedPlayingTime + 1
    }
    fileprivate func timeIncrement(){
        remainingPlayingTime = remainingPlayingTime + additionalTime
    }
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self.level = aDecoder.decodeInteger(forKey: "level") as Int
        self.solvedGraphsCount = aDecoder.decodeInteger(forKey: "solvedGraphsCount") as Int
        self.earnedPoints = aDecoder.decodeInteger(forKey: "earnedPoints") as Int?
        self.hats = aDecoder.decodeInteger(forKey: "hats") as Int?
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode (self.level, forKey: "level")
        aCoder.encode(self.solvedGraphsCount, forKey: "solvedGraphsCount")
        if let points = self.earnedPoints {
            aCoder.encode(points, forKey: "earnedPoints")
        }
        if let hats = self.hats {
            aCoder.encode(hats, forKey: "hats")
        }
    }
}
