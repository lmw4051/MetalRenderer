//
//  Shaders.metal
//  MetalRenderer
//
//  Created by David on 2020/10/29.
//  Copyright © 2020 David. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main() {
  return float4(0, 0, 0, 1);
}

fragment float4 fragment_main() {
  return float4(0, 0, 1, 1);
}
