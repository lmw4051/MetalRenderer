//
//  Instance.swift
//  MetalRenderer
//
//  Created by David on 2020/11/1.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import MetalKit

class Instance: Model {
  var transforms: [Transform]
  var instanceCount: Int
  var instanceBuffer: MTLBuffer
  
  init(name: String, instanceCount: Int = 1) {
    transforms = [Transform](repeatElement(Transform(), count: instanceCount))
    self.instanceCount = instanceCount
    instanceBuffer = Renderer.device.makeBuffer(length: instanceCount * MemoryLayout<Instances>.stride, options: [])!
    super.init(name: name)
  }
  
  override func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
    var pointer = instanceBuffer.contents().bindMemory(to: Instances.self,
                                                       capacity: instanceCount)
    
    for transform in transforms {
      pointer.pointee.modelMatrix = transform.matrix
      pointer = pointer.advanced(by: 1)
    }
    
    commandEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: 20)
    commandEncoder.setRenderPipelineState(submesh.instancedPipelineState)
    
    let mtkSubmesh = submesh.mtkSubmesh
              
    commandEncoder.drawIndexedPrimitives(type: .triangle,
                                         indexCount: mtkSubmesh.indexCount,
                                         indexType: mtkSubmesh.indexType,
                                         indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                         indexBufferOffset: mtkSubmesh.indexBuffer.offset,
                                         instanceCount: instanceCount)
  }
}
