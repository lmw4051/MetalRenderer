//
//  Renderable.swift
//  MetalRenderer
//
//  Created by David on 2020/10/30.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation
import MetalKit

protocol Renderable {
  var name: String { get }
  func render(commandEncoder: MTLRenderCommandEncoder,
              uniforms vertex: Uniforms)
}
