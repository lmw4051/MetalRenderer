//
//  Renderer.swift
//  MetalRenderer
//
//  Created by David on 2020/10/29.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import MetalKit

struct Vertex {
  let position: SIMD3<Float>
  let color: SIMD3<Float>
}

class Renderer: NSObject {
  static var device: MTLDevice!
  let commandQueue: MTLCommandQueue
  static var library: MTLLibrary!
  let pipelineState: MTLRenderPipelineState
  
  let train: Model
  
  init(view: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("Unable to connect to GPU")
    }
    Renderer.device = device
    self.commandQueue = commandQueue
    Renderer.library = device.makeDefaultLibrary()
    pipelineState = Renderer.createPipelineState()      
    
    train = Model(name: "train")
    
    super.init()
  }
  
  static func createPipelineState() -> MTLRenderPipelineState {
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
    pipelineStateDescriptor.vertexFunction = vertexFunction
    pipelineStateDescriptor.fragmentFunction = fragmentFunction
    pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
    
    return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
  }
}

extension Renderer : MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    
  }
  
  func draw(in view: MTKView) {
    guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let drawable = view.currentDrawable,
      let descriptor = view.currentRenderPassDescriptor,
      let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
        return
    }
    commandEncoder.setRenderPipelineState(pipelineState)
    
    for mtkMesh in train.mtkMeshes {
      for vertexBuffer in mtkMesh.vertexBuffers {
        commandEncoder.setVertexBuffer(vertexBuffer.buffer,
                                       offset: 0, index: 0)
        
        var color = 0
        
        for submesh in mtkMesh.submeshes {
          commandEncoder.setVertexBytes(&color, length: MemoryLayout<Int>.stride, index: 11)
          // draw call
          commandEncoder.drawIndexedPrimitives(type: .triangle,
                                               indexCount: submesh.indexCount,
                                               indexType: submesh.indexType,
                                               indexBuffer: submesh.indexBuffer.buffer,
                                               indexBufferOffset: submesh.indexBuffer.offset)
          
          color += 1
        }
      }
    }
    
    
    
    
    
    commandEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
