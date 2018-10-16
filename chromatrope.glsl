uniform vec3 iRGB;
uniform float framecount;
// uniform vec2 iResolution;
// uniform float iGlobalTime;

float rand(vec2 c){
	return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Some useful functions
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; } vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

//
// Description : GLSL 2D simplex noise function
//      Author : Ian McEwan, Ashima Arts
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License :
//  Copyright (C) 2011 Ashima Arts. All rights reserved.
//  Distributed under the MIT License. See LICENSE file.
//  https://github.com/ashima/webgl-noise
//
float snoise(vec2 v) {

    // Precompute values for skewed triangular grid
    const vec4 C = vec4(0.211324865405187,
                        // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,
                        // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,
                        // -1.0 + 2.0 * C.x
                        0.024390243902439);
                        // 1.0 / 41.0

    // First corner (x0)
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    // Other two corners (x1, x2)
    vec2 i1 = vec2(0.0);
    i1 = (x0.x > x0.y)? vec2(1.0, 0.0):vec2(0.0, 1.0);
    vec2 x1 = x0.xy + C.xx - i1;
    vec2 x2 = x0.xy + C.zz;

    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289(i);
    vec3 p = permute(
            permute( i.y + vec3(0.0, i1.y, 1.0))
                + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(
                        dot(x0,x0),
                        dot(x1,x1),
                        dot(x2,x2)
                        ), 0.0);

    m = m*m ;
    m = m*m ;

    // Gradients:
    //  41 pts uniformly over a line, mapped onto a diamond
    //  The ring size 17*17 = 289 is close to a multiple
    //      of 41 (41*7 = 287)

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

    // Compute final noise value at P
    vec3 g = vec3(0.0);
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * vec2(x1.x,x2.x) + h.yz * vec2(x1.y,x2.y);
    return 130.0 * dot(m, g);
}

// mat2 rotate(float theta) {
//   return mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
// }


float circle(vec2 uv, vec2 pos, float r) {
  return length((uv+pos)/r);
}

float ngon(vec2 uv, vec2 pos, int n) {
  uv += pos;
  float a = atan(uv.x,uv.y)+3.145;
  float r = 6.28/float(n);
  return cos(floor(.5+a/r)*r-a)*length(uv);
}


vec2 fold(vec2 p, float ang){
  vec2 n=vec2(cos(-ang),sin(-ang));
  p-=2.*min(0.,dot(p,n))*n;
  return p;
}

mat2 rotate(float theta) {
  return mat2(cos(theta), -sin(theta),sin(theta),cos(theta));
}

vec2 kal(vec2 uv, float n) {
  for(float i=n; i> 0.; i--) {
    uv=uv *rotate(3.145/n);
    uv = fold(uv, 3.145);
  }
  return uv;
}

vec3 color(vec2 pt, mat2 rot) {
  // think in terms of subtractive (cmy) colour
  // Adjust the angle of the fold here
  //pt+=.1;
  //pt = fold(pt, 0.);
  //pt*=1.4;

  // no occlusion by default
  vec3 colour = vec3(0.);
  vec3 inner = vec3(0.);

  colour = mix(colour,vec3(1.), smoothstep(.98,1.,abs(circle(pt, vec2(0.), 0.9))));

  // colour = mix(colour,vec3(.9,0.4,.0), vec3(smoothstep(1.84,.000,.8+sin(ngon(kal(rotate(2.)*pt, 3.), vec2(0.1,0.2), 3)*290.)*.83)));
  // colour = mix(colour,vec3(.9,0.0,.0), vec3(smoothstep(1.84,.000,.8+sin(ngon(pt, vec2(0.3,0.0), 9)*90.)*1.2)));
  // colour = mix(colour,vec3(.9,0.2,.3), vec3(smoothstep(0.00,1.800,.8+sin(ngon(kal(pt,4), vec2(0.3,0.9), 4)*90.)*1.2)));
  colour = mix(colour,vec3(.9,.9,.9), vec3(smoothstep(0.00,1.800,.8+sin(ngon(kal(kal(rot*pt+vec2(.0,.0),7)+vec2(0.0,0.0),3), vec2(1.0,0.0), 9)*70.)*1.3)));
  colour = mix(colour,vec3(.9,0.9,.9), vec3(smoothstep(0.00,1.800,.8+cos(ngon(kal(kal(rot*pt+vec2(.0,.0),7)+vec2(0.0,0.0),3), vec2(1.0,0.0),9)*70.)*1.3)));
  // colour = mix(colour,vec3(.0,0.9,.3), vec3(smoothstep(1.84,.000,.8+sin(ngon(pt, vec2(1.9,0.0), 7)*90.)*1.2)));
  // colour = mix(colour,vec3(.4,0.0,.8), vec3(smoothstep(.000,1.84,.0+cos(ngon(pt, vec2(0.0,0.9), 6)*90.)*1.2)));
  // colour = mix(colour,vec3(.3,.9,.2), smoothstep(0.91,0.90,circle(kal(pt, 11.), vec2(0.3), .3)));
  // colour = mix(colour,vec3(.2,0.5,.9), vec3(smoothstep(.000,1.84,.8+sin(ngon(kal(rotate(2.)*pt, 3.), vec2(0.0,0.2), 3)*120.)*.80)));
  // colour = mix(colour,vec3(.0,.2,.6), smoothstep(0.36,0.35,abs(.1-circle(kal(pt, 8.), vec2(0.7,0.8), .9))));
  // inner = mix(inner,vec3(.9,0.3,.0), vec3(smoothstep(.000,1.84,-.3+sin(ngon(kal(rotate(1.9)*(kal(rotate(2.)*pt, 4.)+vec2(.3,.2)),5.), vec2(0.9,.3), 13)*50.)*2.2)));
  // inner = mix(inner,vec3(.0,0.3,.9), vec3(smoothstep(.000,1.84,-.9+cos(ngon(kal(rotate(1.9)*(kal(rotate(2.)*pt, 4.)+vec2(.3,.2)),5.), vec2(0.9,.3), 13)*50.)*2.2)));
  // inner = mix(inner,vec3(.8,0.9,.9), vec3(smoothstep(.000,1.84,-.9+cos(3.14+ngon(kal(rotate(1.9)*(kal(rotate(2.)*pt, 4.)+vec2(.3,.2)),5.), vec2(0.9,.3), 13)*50.)*2.2)));
  // inner = mix(inner,vec3(.2,0.8,.8), vec3(smoothstep(.000,1.84,-.9+cos(ngon(pt, vec2(0.,.3), 4)*200.)*2.0)));
  // inner = mix(inner,vec3(1.,.0,1.), smoothstep(0.06,0.05,abs(.81-circle(kal(pt, 17.), vec2(0.2,0.3), .2))));
  //vec3 colour= vec3(0.5);


  // colour = mix(colour, vec3(.9), smoothstep(.46,.51,length(pt)));
  // colour = mix(colour, inner, smoothstep(.5,.52,length(pt)));
  // colour = mix(colour, vec3(1.0), smoothstep(.01,.00,abs(.88-length(pt))));
  // colour = mix(colour, mix(colour,vec3(1.0),smoothstep(-2.,-1.2,19.*sin(atan(pt.x,pt.y)*100. -length(pt)*00.))), step(.88,abs(length(pt))));

  return colour;
}

vec3 inverse(vec3 c) {
  return vec3(1.) - c;
}

vec3 occlude(vec3 light, vec3 slide) {
  return light - slide;
}

void main(void) {

  vec2 uv = gl_FragCoord.xy / iResolution.xy*2. - 1.; // 0 <> 1
  uv.x *= iResolution.x/iResolution.y;


  // projected light
  vec3 light = vec3(1.);
  // slide 1
  light = occlude(light,color(uv*rotate( iGlobalTime/4.4), rotate(length(uv) )));
  //colour = min(colour, );
  // slide 2
  light = occlude(light,color(uv*rotate(-iGlobalTime/4.4), rotate(-length(uv))));
  //colour = min(colour, color(uv*rot(-iGlobalTime/4.)));


  light = mix(light,vec3(0.07,.0,.082), smoothstep(.98,1.,abs(circle(uv, vec2(0.), 0.9))));

  gl_FragColor = vec4(light, 1.);

}
