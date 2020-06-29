//
//  Sphere.swift
//  Earth
//
//  Created by Anastasia Myropolska on 29.06.20.
//

import Foundation

struct Sphere {
    
    let colorPoints: [[ColorInfo]] = SphereProvider.fillPixelsArray(dimX: 1363, dimY: 1000) // todo: remove hardcode
    
    init() {
        //var colors = [ColorInfo]()
        //SphereProvider.fillPixelsArray(&colors, dimX: 1363, dimY: 1000) // todo: remove hardcode
    }

    // todo: still need this in swift?
    private func gaussian_fmod(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        if y == 0 {
            return x
        } else {
            return x - y * floor(x / y)
        }
    }
    
    func colorOfPoint(withLongitude lo: CGFloat, latitude la: CGFloat) -> ColorInfo {
        /*
             Need to reduce la:[0;pi], lo:[0; 2*pi].
             Use own fmod-function because of incorrect behavior of fmodf (from math.h) with negative x-parameter.
             */
        let red_lo = gaussian_fmod(lo, 2 * .pi)
        let red_la = gaussian_fmod(la, .pi)

        // 1. check this casting 2. remove defines
        let i = Int(CGFloat(LONGITUDE_RESOLUTION) / (2 * .pi) * red_lo)
        let j = Int(CGFloat(LATITUDE_RESOLUTION) / .pi * red_la)

        let color = colorPoints[j][i]

        return color
    }
}
