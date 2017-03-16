//
//  GameViewController.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 30/10/15.
//  Copyright (c) 2015 Jonathan Fiorentini. All rights reserved.
//

import UIKit
import GameKit
import SpriteKit

class GameViewController: UIViewController,GKGameCenterControllerDelegate {
    var skView:SKView
    init(){
        self.skView = SKView()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Scores.Sync()
        Game.Sync()
        self.view.backgroundColor = CustomColors.BackGroundColor
        self.skView = SKView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(self.skView)
        let scene = MenuScene(size: skView.bounds.size)
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        self.skView.presentScene(scene)
      //  self.authenticateLocalPlayer()
    }
    override var shouldAutorotate : Bool {
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    var gameCenterViewController:GKGameCenterViewController = GKGameCenterViewController()
    
    func authenticateLocalPlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        print(localPlayer.isAuthenticated)
        print(localPlayer.displayName)
        let block = { (viewController : UIViewController?, error : Error?) -> Void in
            if viewController != nil
            {
                self.present(viewController!, animated:true, completion: nil)
                print("Enabled")
            }
            else
            {
                if localPlayer.isAuthenticated
                {
                    GKCenter.GameCenterEnabled = true
                    localPlayer.loadDefaultLeaderboardIdentifier
                        { (leaderboardIdentifier, error) -> Void in
                            if error != nil
                            {
                                print("error")
                            }
                            else
                            {
                                GKCenter.CurrentLeaderBoardIdentifier = leaderboardIdentifier!
                                print("\(GKCenter.CurrentLeaderBoardIdentifier)")
                            }
                    }
                    self.gameCenterViewController.gameCenterDelegate = self
                }
                else
                {
                    print("not able to authenticate fail")
                    GKCenter.GameCenterEnabled = false
                    if (error != nil)
                    {
                        print("\(error)")
                    }
                    else
                    {
                        print("error is nil")
                    }
                }
            }
        }
        localPlayer.authenticateHandler = block
    }
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
