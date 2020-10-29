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
  
  let vertices: [Vertex] = [
    Vertex(position: SIMD3<Float>(-0.5, -0.2, 0), color: SIMD3<Float>(1, 0, 0)),
    Vertex(position: SIMD3<Float>(0.2, -0.2, 0), color: SIMD3<Float>(0, 1, 0)),
    Vertex(position: SIMD3<Float>(0, 0.5, 0), color: SIMD3<Float>(0, 0, 1)),
    Vertex(position: SIMD3<Float>(0.7, 0.7, 0), color: SIMD3<Float>(1, 0, 1))
  ]
  
  let indexArray: [UInt16] = [
    0, 1, 2,
    2, 1, 3
  ]
  
  let vertexBuffer: MTLBuffer
  let indexBuffer: MTLBuffer
  
  init(view: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("Unable to connect to GPU")
    }
    Renderer.device = device
    self.commandQueue = commandQueue
    Renderer.library = device.makeDefaultLibrary()
    pipelineState = Renderer.createPipelineState()
    
    let vertexLength = MemoryLayout<Vertex>.stride * vertices.count
    vertexBuffer = device.makeBuffer(bytes: vertices,
                                     length: vertexLength,
                                     options: [])!
    
    let indexLength = MemoryLayout<UInt16>.stride * indexArray.count
    indexBuffer = device.makeBuffer(bytes: indexArray, length: indexLength, options: [])!
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
    
    commandEncoder.setVertexBuffer(vertexBuffer,
                                   offset: 0, index: 0)
    
    // draw call
    commandEncoder.drawIndexedPrimitives(type: .triangle,
                                         indexCount: indexArray.count,
                                         indexType: .uint16,
                                         indexBuffer: indexBuffer,
                                         indexBufferOffset: 0)
    
    commandEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
