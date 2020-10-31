//
//  GameScene.swift
//  MetalRenderer
//
//  Created by David on 2020/10/30.
//  Copyright © 2020 David. All rights reserved.
//

import Foundation

class GameScene: Scene {
  let train = Model(name: "train")
  let trees = Instance(name: "treefir", instanceCount: 100)
  
  override func setupScene() {
    camera.target = [0, 0.8, 0]
    camera.distance = 20
    camera.rotation = [-0.4, -0.4, 0]
    
    add(node: train)
    add(node: trees)
    
    for i in 0..<100 {
      trees.transforms[i].position.x = Float(i) - 50
      trees.transforms[i].position.z = 2
    }
  }
}
