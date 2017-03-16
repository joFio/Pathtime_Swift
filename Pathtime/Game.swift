//
//  Game.swift
//  Pathtime
//
//  Created by Jonathan on 16/3/16.
//  Copyright © 2016 Jonathan Fiorentini. All rights reserved.
//

import Foundation

class Game {
    static var FirstGame = true
    static var PlayCount = 0
    static var AppReviewDialogCountLimit = 3
    
    static var AppReviewDialogShown = false
    static var Purchased = false
    static var LightMax = 0
    static var Locked = [false,true,true,true,true,true,true,true,true,true,true,true]
    static var Completed = [false,false,false,false,false,false,false,false,false,false,false,false]
    
    static let PurchasedProducts = "PathtimeProducts"
    static let ProductIdentifiers = ["PathtimeAllLevelAccess"]
    
    static func updateInAppPurchasesAuthorizations(){
        if let purchasedProducts = UserDefaults.standard.array(forKey: Game.PurchasedProducts) as? [String] {
            if purchasedProducts.contains(where: {(element) in element == Game.ProductIdentifiers[0]}){
                Game.Purchased = true
                Game.Save()
            }
        }
    }
    static func Sync(){
        if let locked = UserDefaults.standard.object(forKey: Keys.LevelLocked) as? [Bool] {
            Game.Locked = locked
        }
        if let completed = UserDefaults.standard.object(forKey: Keys.LevelCompleted) as? [Bool] {
            Game.Completed = completed
        }
        if let purchased = UserDefaults.standard.object(forKey: Keys.Purchased) as? Bool {
            Game.Purchased = purchased
        }
        if let firstGame = UserDefaults.standard.object(forKey: Keys.FirstGame) as? Bool {
            Game.FirstGame = firstGame
        }
        if let playCount = UserDefaults.standard.object(forKey: Keys.PlayCount) as? Int {
            Game.PlayCount = playCount
        }
    }
    static func Save(){
        UserDefaults.standard.set(Game.Completed, forKey: Keys.LevelCompleted)
        UserDefaults.standard.set(Game.Locked, forKey: Keys.LevelLocked)
        UserDefaults.standard.set(Game.Purchased, forKey: Keys.Purchased)
        UserDefaults.standard.set(Game.FirstGame, forKey: Keys.FirstGame)
        UserDefaults.standard.set(Game.PlayCount, forKey: Keys.PlayCount)
        UserDefaults.standard.set(Game.AppReviewDialogShown, forKey: Keys.AppReviewDialogShown)

    }
    static func ResetAdmin(){
        UserDefaults.standard.set([false,false,false,false,false,false,false,false,false,false,false,false], forKey: Keys.LevelCompleted)
        UserDefaults.standard.set([false,true,true,true,true,true,true,true,true,true,true,true], forKey: Keys.LevelLocked)
        UserDefaults.standard.set(false, forKey: Keys.Purchased)
        UserDefaults.standard.set(true, forKey: Keys.FirstGame)
        UserDefaults.standard.set(0, forKey: Keys.PlayCount)
        UserDefaults.standard.set(Game.AppReviewDialogShown, forKey: Keys.AppReviewDialogShown)

    }
    static func Reset(){
        UserDefaults.standard.set([false,false,false,false,false,false,false,false,false,false,false,false], forKey: Keys.LevelCompleted)
        UserDefaults.standard.set([false,true,true,true,true,true,true,true,true,true,true,true], forKey: Keys.LevelLocked)

    }
}
