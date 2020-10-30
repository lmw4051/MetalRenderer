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
  let depthStencilState: MTLDepthStencilState
  
  let train: Model
  let tree: Model
  let camera = Camera()
  
  var uniforms = Uniforms()
  
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
    
    train = Model(name: "train")
    train.transform.position = [0.4, 0, 0]
    train.transform.scale = 0.5
    
    tree = Model(name: "treefir")
    tree.transform.position = [-1, 0, 0.3]
    tree.transform.scale = 0.5
    
    camera.transform.position = [0, 0.5, -3]
    
    super.init()
  }
  static func createDepthState() -> MTLDepthStencilState {
    let depthDescriptor = MTLDepthStencilDescriptor()
    depthDescriptor.depthCompareFunction = .less
    depthDescriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
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
  
  func zoom(delta: Float) {
    let sensitivity: Float = 0.05
    let cameraVector = camera.transform.matrix.upperLeft.columns.2
    camera.transform.position += delta * sensitivity * cameraVector
  }
}

extension Renderer : MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    camera.aspect = Float(view.bounds.width / view.bounds.height)
  }
  
  func draw(in view: MTKView) {
    guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let drawable = view.currentDrawable,
      let descriptor = view.currentRenderPassDescriptor,
      let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
        return
    }
    commandEncoder.setRenderPipelineState(pipelineState)
    commandEncoder.setDepthStencilState(depthStencilState)
    
    uniforms.viewMatrix = camera.viewMatrix
    uniforms.projectionMatrix = camera.projectionMatrix
    
    let models = [tree, train]
    for model in models {
      uniforms.modelMatrix = model.transform.matrix
      commandEncoder.setVertexBytes(&uniforms,
                                    length: MemoryLayout<Uniforms>.stride,
                                    index: 21)
      
      for mtkMesh in model.mtkMeshes {
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
    }
    
    commandEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
