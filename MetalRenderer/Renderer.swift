//
//  Renderer.swift
//  MetalRenderer
//
//  Created by David on 2020/10/29.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import MetalKit

class Renderer: NSObject {
  static var device: MTLDevice!
  let commandQueue: MTLCommandQueue
  static var library: MTLLibrary!
  let pipelineState: MTLRenderPipelineState
  
  let positionArray: [SIMD4<Float>] = [
    SIMD4<Float>(-0.5, -0.2, 0, 1),
    SIMD4<Float>(0.2, -0.2, 0, 1),
    SIMD4<Float>(0, 0.5, 0, 1),
    SIMD4<Float>(0, 0.5, 0, 1),
    SIMD4<Float>(0.2, -0.2, 0, 1),
    SIMD4<Float>(0.7, 0.7, 0, 1)
  ]
  
  let colorArray: [SIMD3<Float>] = [
    SIMD3<Float>(1, 0, 0),
    SIMD3<Float>(0, 1, 0),
    SIMD3<Float>(0, 0, 1),
    SIMD3<Float>(0, 0, 1),
    SIMD3<Float>(0, 1, 0),
    SIMD3<Float>(1, 0, 1)
  ]
  
  let positionBuffer: MTLBuffer
  let colorBuffer: MTLBuffer
  
  var timer: Float = 0
  
  init(view: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("Unable to connect to GPU")
    }
    Renderer.device = device
    self.commandQueue = commandQueue
    Renderer.library = device.makeDefaultLibrary()
    pipelineState = Renderer.createPipelineState()
    
    let positionLength = MemoryLayout<SIMD4<Float>>.stride * positionArray.count
    positionBuffer = device.makeBuffer(bytes: positionArray, length: positionLength, options: [])!
    let colorLength = MemoryLayout<SIMD3<Float>>.stride * colorArray.count
    colorBuffer = device.makeBuffer(bytes: colorArray, length: colorLength, options: [])!
    super.init()
  }
  
  static func createPipelineState() -> MTLRenderPipelineState {
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
    let fragmentFunction = Renderer.library.makeFunction(name: "fragment_main")
    pipelineStateDescriptor.vertexFunction = vertexFunction
    pipelineStateDescriptor.fragmentFunction = fragmentFunction
    
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
    timer += 0.05
    var currentTime = sin(timer)
    commandEncoder.setVertexBytes(&currentTime,
                                  length: MemoryLayout<Float>.stride,
                                  index: 2)
    
    commandEncoder.setRenderPipelineState(pipelineState)
    commandEncoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
    commandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
    
    commandEncoder.drawPrimitives(type: .triangle,
                                  vertexStart: 0,
                                  vertexCount: 6)
    
    commandEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
