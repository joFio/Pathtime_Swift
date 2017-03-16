//
//  SKBonusNode.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 13/2/16.
//  Copyright © 2016 Jonathan Fiorentini. All rights reserved.
//

import Foundation
import SpriteKit

class SKBonusNode: SKSpriteNode {
    
    var bonusType:GameInteraction
    init(bonusType:GameInteraction){
        self.bonusType = bonusType
        let color = UIColor()
        switch bonusType {
        case GameInteraction.removeVertex:
            let texture = SKTexture(imageNamed: "BonusVertex")
            let size = texture.size()
            super.init(texture: texture, color: color, size: size)
        case GameInteraction.removeEdge:
            let texture = SKTexture(imageNamed: "BonusEdge")
            let size = texture.size()
            super.init(texture: texture, color: color, size: size)
        default:
            let texture = SKTexture(imageNamed: "BonusEdge")
            let size = texture.size()
            super.init(texture: texture, color: color, size: size)

        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
