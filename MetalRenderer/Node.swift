//
//  Node.swift
//  MetalRenderer
//
//  Created by David on 2020/10/30.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation

class Node {
  var name = "Untitled"
  
  var position = SIMD3<Float>.init(repeating: 0)
  var rotation = SIMD3<Float>.init(repeating: 0)
  var scale: Float = 1
  
  var matrix: float4x4  {
    let translateMatrix = float4x4(translation: position)
    let rotationMatrix = float4x4(rotation: rotation)
    let scaleMatrix = float4x4(scaling: scale)
    return translateMatrix * scaleMatrix * rotationMatrix
  }

  var parent: Node?
  var children: [Node] = []

  var worldMatrix: float4x4 {
    if let parent = parent {
      return parent.worldMatrix * matrix
    }
    return matrix
  }
  
  final func add(childNode: Node) {
    children.append(childNode)
    childNode.parent = self
  }
  
  final func remove(childNode: Node) {
    for child in childNode.children {
      child.parent = self
      children.append(child)
    }
    childNode.children = []
    guard let index = (children.firstIndex {
      $0 === childNode
    }) else { return }
    children.remove(at: index)
  }
}
