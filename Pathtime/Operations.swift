//
//  Operations.swift
//  EulerianPathDraft3
//
//  Created by Jonathan on 6/12/15.
//  Copyright © 2015 Jonathan Fiorentini. All rights reserved.
//

import Foundation
import UIKit

class Operations {
    static func magnitude(_ vector:CGVector)->CGFloat{
        let dx = vector.dx
        let dy = vector.dy
        let result = sqrt(pow(dx, 2)+pow(dy,2))
        return result
    }
    static func unitVector(_ vector:CGVector)->CGVector{
        let magnitude = Operations.magnitude(vector)
        return CGVector(dx: vector.dx/magnitude, dy: vector.dy/magnitude)
    }
    static func normalVector(_ vector:CGVector)->CGVector{
        return CGVector(dx: -vector.dy, dy: vector.dx)
    
    }
    static func distanceFromPoint(_ point1:CGPoint, to point2:CGPoint)->CGFloat{
        let vector = Operations.vectorBetweenPoints(point1, and: point2)
        return Operations.magnitude(vector)
    }
    static func dotProduct(_ vector1:CGVector,vector2:CGVector)->CGFloat {
        let x = vector1.dx * vector2.dx
        let y = vector1.dy * vector2.dy
        return x + y
    }
    static func vectorBetweenPoints(_ point1:CGPoint, and point2:CGPoint)->CGVector {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return CGVector(dx: dx, dy: dy)
    }
}
