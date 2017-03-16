//
//  Score.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 3/3/16.
//  Copyright © 2016 Jonathan Fiorentini. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

class Scores{
    
    static var Level:[GameScore] {
        get {
            return [GameScore(startPlayingTime: 40, totalGraphs: 10, parTime: 7),
                    GameScore(startPlayingTime: 40, totalGraphs: 10, parTime: 7),
                    GameScore(startPlayingTime: 40, totalGraphs: 10, parTime: 8),
                    GameScore(startPlayingTime: 40, totalGraphs: 10, parTime: 8),
                    GameScore(startPlayingTime: 45, totalGraphs: 10, parTime: 10),
                    GameScore(startPlayingTime: 45, totalGraphs: 10, parTime: 10),
                    GameScore(startPlayingTime: 45, totalGraphs: 10, parTime: 11),
                    GameScore(startPlayingTime: 45, totalGraphs: 10, parTime: 11),
                    GameScore(startPlayingTime: 50, totalGraphs: 10, parTime: 13),
                    GameScore(startPlayingTime: 50, totalGraphs: 10, parTime: 13),
                    GameScore(startPlayingTime: 50, totalGraphs: 10, parTime: 14),
                    GameScore(startPlayingTime: 50, totalGraphs: 10, parTime: 14)]
        }
    }
    static var Reward = ["GraphCountPoints":4, "GraphUnderParPoints": 5, "ParTimePoints":13 , "Finished":15]
    
    static var SavedScores:[Int:GameScore] = [Int:GameScore]()
        
    static func Sync(){
        if let data = UserDefaults.standard.object(forKey: Keys.Scores) as? Data {
            if let scores = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Int:GameScore]
            {
                Scores.SavedScores = scores
            }
        }
    }
    static func SaveNewScore(_ newScore:GameScore){
        let level = newScore.level
        if Scores.SavedScores[level]?.earnedPoints < newScore.earnedPoints {
            Scores.SavedScores[level] = newScore
        }
        let scores = NSKeyedArchiver.archivedData(withRootObject: Scores.SavedScores) as Data
        UserDefaults.standard.set(scores, forKey: Keys.Scores)
    }
    static func Reset(){
        Scores.SavedScores = [Int:GameScore]()
        UserDefaults.standard.set(Scores.SavedScores, forKey: Keys.Scores)
        Game.Reset()
    }
}
