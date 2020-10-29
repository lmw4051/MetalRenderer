//
//  Shaders.metal
//  MetalRenderer
//
//  Created by David on 2020/10/29.
//  Copyright © 2020 David. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/*
constant float3 color[6] = {
  float3(1, 0, 0),
  float3(0, 1, 0),
  float3(0, 0, 1),
  float3(0, 0, 1),
  float3(0, 1, 0),
  float3(1, 0, 1)
};
*/

struct VertexOut {
  float4 position [[position]];
  float3 color;
};

vertex VertexOut vertex_main(device const float4 *positionBuffer [[buffer(0)]],
                             device const float3 *colorBuffer [[buffer(1)]],
                             constant float &timer [[buffer(2)]],
                             uint vertexId [[vertex_id]]) {
  VertexOut out {
    .position = positionBuffer[vertexId],
    .color = colorBuffer[vertexId]    
  };
  out.position.x += timer;
  return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
  return float4(in.color, 1);
}
