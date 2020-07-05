//
//  Sphere.swift
//  Earth
//
//  Created by Anastasia Myropolska on 29.06.20.
//

import Foundation

struct Sphere {
    
    let sphereProvider = SphereProvider()
    private let pixels: [[ColorInfo]]
    
    init() {
        pixels = sphereProvider.pixelsFromMapImage()
    }

    /*
     The default behavior of truncatingRemainder is not suitable, as it returns negative result for
     negaitive numerator. We need always positive result, as in Gaussian mod.
    Eg.
     -8.truncatingRemainder(5) = -3
     gaussian_fmod(-8, 5) = 2
    */
    private func positiveRemainder(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        var result = x.truncatingRemainder(dividingBy: y)
        if result < 0 {
            result += y
        }
        return result
    }
    
    public func colorOfPoint(withLongitude lo: CGFloat, latitude la: CGFloat) -> ColorInfo {
        /*
             Need to reduce la:[0;pi], lo:[0; 2*pi].
             Use own remainder function because of unsuitable behavior of truncatingRemainder (from CGFloat) with negative x-parameter.
             */
        let reducedLo = positiveRemainder(lo, 2 * .pi)
        let reducedLa = positiveRemainder(la, .pi)

        // 1. check this casting
        let i = Int(sphereProvider.imageSize.width / (2 * CGFloat.pi) * reducedLo)
        let j = Int(sphereProvider.imageSize.height / CGFloat.pi * reducedLa)

        let color = pixels[j][i]

        return color
    }
}
