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

    // todo: still need this in swift?
    private func gaussian_fmod(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        if y == 0 {
            return x
        } else {
            return x - y * floor(x / y)
        }
    }
    
    public func colorOfPoint(withLongitude lo: CGFloat, latitude la: CGFloat) -> ColorInfo {
        /*
             Need to reduce la:[0;pi], lo:[0; 2*pi].
             Use own fmod-function because of incorrect behavior of fmodf (from math.h) with negative x-parameter.
             */
        let red_lo = gaussian_fmod(lo, 2 * .pi)
        let red_la = gaussian_fmod(la, .pi)

        // 1. check this casting
        let i = Int(sphereProvider.imageSize.width / (2 * CGFloat.pi) * red_lo)
        let j = Int(sphereProvider.imageSize.height / CGFloat.pi * red_la)

        let color = pixels[j][i]

        return color
    }
}
