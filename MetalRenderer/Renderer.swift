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
  
  init(view: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("Unable to connect to GPU")
    }
    Renderer.device = device
    self.commandQueue = commandQueue
    Renderer.library = device.makeDefaultLibrary()
    pipelineState = Renderer.createPipelineState()
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
    commandEncoder.setRenderPipelineState(pipelineState)
    commandEncoder.drawPrimitives(type: .point,
                                  vertexStart: 0,
                                  vertexCount: 1)
    
    commandEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
