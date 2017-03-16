//
//  CustomPoints.swift
//  EulerianPathDraft2
//
//  Created by Jonathan on 30/10/15.
//  Copyright © 2015 Jonathan Fiorentini. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class SKVertexNode:SKShapeNode {
    let optimalLocation:CGPoint
    let vertex:Vertex
    let uuid:UUID
    var vertexRadius:CGFloat
    
    init(point:CGPoint,vertex:Vertex){
        self.optimalLocation = point
        self.vertex = vertex
        self.uuid = UUID()
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            vertexRadius = 10
        }
        else {
            vertexRadius = 20
        }
        super.init()
        self.name = vertex.name
        self.setupVertex()
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupVertex() {
        self.position  = self.optimalLocation
        let path = CGMutablePath()
    
        path.addArc(center: CGPoint(x: 0,y: 0), radius: vertexRadius,startAngle: 0, endAngle:  CGFloat(M_PI*2), clockwise: false)
        self.path = path
        self.fillColor = CustomColors.VertexColor
        self.strokeColor = UIColor.clear
        
        let enhancedTouchHelp = SKShapeNode(circleOfRadius: vertexRadius*4)
        enhancedTouchHelp.strokeColor = UIColor.clear
        enhancedTouchHelp.fillColor = UIColor.clear
        enhancedTouchHelp.zPosition = 10
        self.addChild(enhancedTouchHelp)
    }
    
    
}
