//
//  Transform.swift
//  MetalRenderer
//
//  Created by David on 2020/10/30.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import simd

struct Transform {
  var position = SIMD3<Float>.init(repeating: 0)
  var rotation = SIMD3<Float>.init(repeating: 0)
  var scale: Float = 1
  
  var matrix: float4x4 {
    let translateMatrix = float4x4(translation: position)
    let rotationMatrix = float4x4(rotation: rotation)
    let scaleMatrix = float4x4(scaling: scale)
    return translateMatrix * scaleMatrix * rotationMatrix
  }
}
