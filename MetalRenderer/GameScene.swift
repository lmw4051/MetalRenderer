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
  
  override func setupScene() {
    add(node: train)
    
    let tree = Model(name: "treefir")
    add(node: tree)
    tree.position.x = -2.0
  }
}
