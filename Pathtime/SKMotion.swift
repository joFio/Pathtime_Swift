//
//  SKMotion.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 2/2/16.
//  Copyright © 2016 Jonathan Fiorentini. All rights reserved.
//

import Foundation
import SpriteKit

class SKMotion {
    static func shake(_ node:SKNode, duration:Float) {
        let amplitudeX:CGFloat = 20;
        let amplitudeY:CGFloat = 0;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = amplitudeX
            let moveY = amplitudeY
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        let actionSeq = SKAction.sequence(actionsArray);
        node.run(actionSeq);
    }
    
    static func easeAndBounceWithBounds(_ easingNode:SKNode,velocity:CGVector,  margin:CGFloat, easingOffshoot:CGFloat, scene:SKScene){
        let frame = easingNode.calculateAccumulatedFrame()
        let leftBound = -margin - frame.width/2 + scene.frame.width
        let rightBound = margin + frame.width/2
        
        let lowerBound = -margin - frame.height/2 + scene.frame.height
        let  upperBound = margin + frame.height/2
        
        let xVelocity = velocity.dx
        let yVelocity = velocity.dy
        
        let easingDuration:Double = 2
        let xEasingDistance = xVelocity*CGFloat(easingDuration)
        let yEasingDistance = yVelocity*CGFloat(easingDuration)
        
        let distanceToLeftBound = leftBound - easingNode.position.x
        let distanceToRightBound = rightBound - easingNode.position.x
        
        let distanceToUpperBound = upperBound - easingNode.position.y
        let distanceToLowerBound = lowerBound - easingNode.position.y
        
        let timingFunction =  {(time:Float)->Float in
            return Float(sin(Double(time) * M_PI*0.5))
        }
        
        if xVelocity != 0
        {
            var actionSequence = SKAction()
            
            if (distanceToLeftBound>0) {
                let easeForward = SKAction.moveBy(x: distanceToLeftBound, y: 0, duration: easingDuration)
                easeForward.timingFunction = timingFunction
                actionSequence = SKAction.sequence([easeForward])
            }
            else if(distanceToRightBound<0) {
                let easeForward = SKAction.moveBy(x: distanceToRightBound, y: 0, duration: easingDuration)
                easeForward.timingFunction = timingFunction
                actionSequence = SKAction.sequence([easeForward])
                
            }
            else{
                if xEasingDistance > 0 {
                    if xEasingDistance > distanceToRightBound{
                        let duration = Double((distanceToRightBound + easingOffshoot)/xVelocity)
                        let easeForward = SKAction.moveBy(x: distanceToRightBound+easingOffshoot, y: 0, duration: duration)
                        easeForward.timingFunction = timingFunction
                        let bounceEffect = SKAction.moveBy(x: -easingOffshoot, y: 0, duration: 1)
                        bounceEffect.timingFunction = timingFunction
                        actionSequence = SKAction.sequence([easeForward,bounceEffect])
                    }else{
                        let easeForward = SKAction.moveBy(x: xEasingDistance, y: 0, duration: easingDuration)
                        easeForward.timingFunction = timingFunction
                        actionSequence = SKAction.sequence([easeForward])
                    }
                }else {
                    if xEasingDistance < distanceToLeftBound{
                        let duration = Double((distanceToLeftBound - easingOffshoot)/xVelocity)
                        let easeForward = SKAction.moveBy(x: distanceToLeftBound-easingOffshoot, y: 0, duration: duration)
                        easeForward.timingFunction = timingFunction
                        let bounceEffect = SKAction.moveBy(x: easingOffshoot, y: 0, duration: 1)
                        bounceEffect.timingFunction = timingFunction
                        actionSequence = SKAction.sequence([easeForward,bounceEffect])
                    }else{
                        let easeForward = SKAction.moveBy(x: xEasingDistance, y: 0, duration: easingDuration)
                        easeForward.timingFunction = timingFunction
                        actionSequence = SKAction.sequence([easeForward])
                    }
                }
            }
            easingNode.run(actionSequence)
        }
        if yVelocity != 0 {
            var actionSequence2 = SKAction()
            if (distanceToLowerBound>0) {
                let easeForward = SKAction.moveBy(x: 0, y: distanceToLowerBound, duration: easingDuration)
                easeForward.timingFunction = timingFunction
                actionSequence2 = SKAction.sequence([easeForward])
            }
            else if(distanceToUpperBound<0) {
                let easeForward = SKAction.moveBy(x: 0, y: distanceToUpperBound, duration: easingDuration)
                easeForward.timingFunction = timingFunction
                actionSequence2 = SKAction.sequence([easeForward])
            }
            else{
                if yEasingDistance > 0 {
                    if yEasingDistance > distanceToUpperBound{
                        let duration = Double((distanceToUpperBound + easingOffshoot)/yVelocity)
                        let easeForward = SKAction.moveBy(x: 0, y: distanceToUpperBound+easingOffshoot, duration: duration)
                        easeForward.timingFunction = timingFunction
                        let bounceEffect = SKAction.moveBy(x: 0, y: -easingOffshoot, duration: 1)
                        bounceEffect.timingFunction = timingFunction
                        actionSequence2 = SKAction.sequence([easeForward,bounceEffect])
                    }else{
                        let easeForward = SKAction.moveBy(x: 0, y: yEasingDistance, duration: easingDuration)
                        easeForward.timingFunction = timingFunction
                        actionSequence2 = SKAction.sequence([easeForward])
                    }
                }else {
                    if yEasingDistance < distanceToUpperBound{
                        let duration = Double((distanceToLowerBound - easingOffshoot)/yVelocity)
                        let easeForward = SKAction.moveBy(x: 0, y: distanceToLowerBound-easingOffshoot, duration: duration)
                        easeForward.timingFunction = timingFunction
                        let bounceEffect = SKAction.moveBy(x: 0, y: easingOffshoot, duration: 1)
                        bounceEffect.timingFunction = timingFunction
                        actionSequence2 = SKAction.sequence([easeForward,bounceEffect])
                    }else{
                        let easeForward = SKAction.moveBy(x: 0, y: easingOffshoot, duration: easingDuration)
                        easeForward.timingFunction = timingFunction
                        actionSequence2 = SKAction.sequence([easeForward])
                    }
                }
            }
            
            easingNode.run(actionSequence2)
        }
    }
    
    
}
