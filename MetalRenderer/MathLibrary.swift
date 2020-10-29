//
//  MathLibrary.swift
//  MetalRenderer
//
//  Created by David on 2020/10/30.
//  Copyright © 2020 David. All rights reserved.
//

import simd

let π = Float.pi

func radians(fromDegrees degrees: Float) -> Float {
  return (degrees / 180) * π
}

func degrees(fromRadians radians: Float) -> Float {
  return (radians / π) * 180
}

extension float4x4 {
  
  // MARK: - Translate
  init(translation: SIMD3<Float>) {
    self = matrix_identity_float4x4
    columns.3.x = translation.x
    columns.3.y = translation.y
    columns.3.z = translation.z
  }
  
  // MARK: - Scale
  init(scaling: SIMD3<Float>) {
    self = matrix_identity_float4x4
    columns.0.x = scaling.x
    columns.1.y = scaling.y
    columns.2.z = scaling.z
  }
  
  init(scaling: Float) {
    self = float4x4(scaling: SIMD3<Float>(scaling, scaling, scaling))
  }
  
  // MARK: - Rotate
  init(rotationX angle: Float) {
    self = matrix_identity_float4x4
    columns.1.y = cos(angle)
    columns.1.z = sin(angle)
    columns.2.y = -sin(angle)
    columns.2.z = cos(angle)
  }
  
  init(rotationY angle: Float) {
    self = matrix_identity_float4x4
    columns.0.x = cos(angle)
    columns.0.z = -sin(angle)
    columns.2.x = sin(angle)
    columns.2.z = cos(angle)
  }
  
  init(rotationZ angle: Float) {
    self = matrix_identity_float4x4
    columns.0.x = cos(angle)
    columns.0.y = sin(angle)
    columns.1.x = -sin(angle)
    columns.1.y = cos(angle)
  }
  
  init(rotation angle: SIMD3<Float>) {
    let rotationX = float4x4(rotationX: angle.x)
    let rotationY = float4x4(rotationY: angle.y)
    let rotationZ = float4x4(rotationZ: angle.z)
    self = rotationX * rotationY * rotationZ
  }
  
  init(rotationYXZ angle: SIMD3<Float>) {
    let rotationX = float4x4(rotationX: angle.x)
    let rotationY = float4x4(rotationY: angle.y)
    let rotationZ = float4x4(rotationZ: angle.z)
    self = rotationY * rotationX * rotationZ
  }
  
  // MARK: - Identity
  static var identity: float4x4 {
    let matrix: float4x4 = matrix_identity_float4x4
    return matrix
  }
  
  // MARK: - Upper left 3x3
  var upperLeft: float3x3 {
    let x = columns.0.xyz
    let y = columns.1.xyz
    let z = columns.2.xyz
    return float3x3(columns: (x, y, z))
  }
  
  // MARK: - Left handed projection matrix
  init(projectionFov fov: Float, near: Float, far: Float, aspect: Float) {
    let y = 1 / tan(fov * 0.5)
    let x = y / aspect
    let z = far / (far - near)
    let X = SIMD4<Float>( x,  0,  0,  0)
    let Y = SIMD4<Float>( 0,  y,  0,  0)
    let Z = SIMD4<Float>( 0,  0,  z, 1)
    let W = SIMD4<Float>( 0,  0,  z * -near,  0)
    self.init()
    columns = (X, Y, Z, W)
  }

  
  // left-handed LookAt
  init(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) {
    let z = normalize(center - eye)
    let x = normalize(cross(up, z))
    let y = cross(z, x)
    let w = SIMD3<Float>(-dot(x, eye), -dot(y, eye), -dot(z, eye))
    let X = SIMD4<Float>(x.x, y.x, z.x, 0)
    let Y = SIMD4<Float>(x.y, y.y, z.y, 0)
    let Z = SIMD4<Float>(x.z, y.z, z.z, 0)
    let W = SIMD4<Float>(w.x, w.y, w.z, 1)
    self.init()
    columns = (X, Y, Z, W)
  }
}

extension SIMD4 {
  var xyz: SIMD3<Scalar> {
    get {
      return SIMD3<Scalar>(x, y, z)
    }
    set {
      x = newValue.x
      y = newValue.y
      z = newValue.z
    }
  }
}
