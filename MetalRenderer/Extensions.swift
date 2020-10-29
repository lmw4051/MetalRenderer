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
    vertexDescriptor.attributes[1].offset = 0
    vertexDescriptor.attributes[1].bufferIndex = 0
    
    vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
    
    
    return vertexDescriptor
  }
}
