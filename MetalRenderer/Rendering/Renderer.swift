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
  let depthStencilState: MTLDepthStencilState
  
  weak var scene: Scene?
    
  init(view: MTKView) {
    guard let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("Unable to connect to GPU")
    }
    Renderer.device = device
    self.commandQueue = commandQueue
    Renderer.library = device.makeDefaultLibrary()
    pipelineState = Renderer.createPipelineState()
    depthStencilState = Renderer.createDepthState()
    
    view.depthStencilPixelFormat = .depth32Float        
    
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
    pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
    return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
  }
  
  static func createDepthState() -> MTLDepthStencilState {
    let depthDescriptor = MTLDepthStencilDescriptor()
    depthDescriptor.depthCompareFunction = .less
    depthDescriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
  }    
}

extension Renderer : MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    scene?.sceneSizeWillChange(to: size)
  }
  
  func draw(in view: MTKView) {
    guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let drawable = view.currentDrawable,
      let descriptor = view.currentRenderPassDescriptor,
      let scene = scene else {
        return
    }
    
    let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
    commandEncoder.setRenderPipelineState(pipelineState)
    commandEncoder.setDepthStencilState(depthStencilState)
    
    let deltaTime = 1 / Float(view.preferredFramesPerSecond)
    scene.update(deltaTime: deltaTime)
        
    for renderable in scene.renderables {
      commandEncoder.pushDebugGroup(renderable.name)
      renderable.render(commandEncoder: commandEncoder,
                        uniforms: scene.uniforms,
                        fragmentUniforms: scene.fragmentUniforms)
      commandEncoder.popDebugGroup()
    }
    
    commandEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
