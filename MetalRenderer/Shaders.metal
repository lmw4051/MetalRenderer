//
//  Shaders.metal
//  MetalRenderer
//
//  Created by David on 2020/10/29.
//  Copyright © 2020 David. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
  float4 position [[position]];
  float point_size [[point_size]];
  float3 color;
};

vertex VertexOut vertex_main() {
  VertexOut out {
    .position = float4(0, 0, 0, 1),
    .color = float3(0, 1, 0),
    .point_size = 60
  };
  return out;
}

fragment float4 fragment_main() {
  return float4(0, 0, 1, 1);
}
