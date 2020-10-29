//
//  Shaders.metal
//  MetalRenderer
//
//  Created by David on 2020/10/29.
//  Copyright © 2020 David. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant float4 position[3] = {
  float4(-0.5, -0.2, 0, 1),
  float4(0.2, -0.2, 0, 1),
  float4(0, 0.5, 0, 1),
};

constant float3 color[3] = {
  float3(1, 0, 0),
  float3(0, 1, 0),
  float3(0, 0, 1),
};

struct VertexOut {
  float4 position [[position]];
  float point_size [[point_size]];
  float3 color;
};

vertex VertexOut vertex_main(uint vertexId [[vertex_id]]) {
  VertexOut out {
    .position = position[vertexId],
    .color = color[vertexId],
    .point_size = 60
  };
  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
  return float4(in.color, 1);
}
