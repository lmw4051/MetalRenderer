//
//  ViewController.swift
//  MetalRenderer
//
//  Created by David on 2020/10/29.
//  Copyright © 2020 David. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
  @IBOutlet var metalView: MTKView!
  var renderer: Renderer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    renderer = Renderer(view: metalView)
    metalView.device = Renderer.device
    metalView.delegate = renderer
    metalView.clearColor = MTLClearColor(red: 1.0,
                                         green: 1.0,
                                         blue: 0.8,
                                         alpha: 1.0)
    
    let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:)))
    metalView.addGestureRecognizer(pinch)
    
    let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(sender:)))
    metalView.addGestureRecognizer(pan)
  }
  
  @objc func pinchAction(sender: UIPinchGestureRecognizer) {
    renderer?.camera.zoom(delta: Float(sender.velocity))    
  }
  
  @objc func panAction(sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: sender.view)
    let delta = SIMD2<Float>(Float(translation.x),
                             Float(translation.y))
    
    renderer?.camera.rotate(delta: delta)
  }
}
