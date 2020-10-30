//
//  Extensions.swift
//  MetalRenderer
//
//  Created by David on 2020/10/29.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import MetalKit

extension MTLVertexDescriptor {
  static func defaultVertexDescriptor() -> MTLVertexDescriptor {
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float3
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
        
    vertexDescriptor.attributes[1].format = .float3
    vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
    vertexDescriptor.attributes[1].bufferIndex = 0
    
    vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride * 2
        
    return vertexDescriptor
  }
}

extension MDLVertexDescriptor {
  static func defaultVertexDescriptor() -> MDLVertexDescriptor {
    let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultVertexDescriptor())
    
    let attributePosition = vertexDescriptor.attributes[0] as! MDLVertexAttribute
    attributePosition.name = MDLVertexAttributePosition
    
    let attributeNormal = vertexDescriptor.attributes[1] as! MDLVertexAttribute
    attributeNormal.name = MDLVertexAttributeNormal
    return vertexDescriptor
  }
}
