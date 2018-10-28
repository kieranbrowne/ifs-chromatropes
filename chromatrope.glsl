uniform vec3 iRGB;
uniform float framecount;
// uniform vec2 iResolution;
// uniform float iGlobalTime;



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

  vec2 uv = pt;
  colour = mix(colour,vec3(1.), smoothstep(.98,1.,abs(circle(pt, vec2(0.), 0.9))));

  pt *= rot;
  for (int i=0; i< 8; i++) {
    pt = kal(rotate(6.28/2.)*mat2(1.0,0.,0.,1.0)*pt,6)+vec2(.29,.2);
  }
  // pt *= rot;
  inner = vec3(0.0);
  vec3 outer = vec3(0.0);

  colour = mix(colour,vec3(1.), vec3(smoothstep(0.90,1.800,-3.92+sin(ngon(pt, vec2(0.0,.0),6)*90.)*2.8)));
  colour = mix(colour,vec3(1.), vec3(smoothstep(0.00,-1.800,-.2+cos(ngon(pt, vec2(0.0,.0),6)*90.)*2.8)));


  pt = uv;
  pt *= rot;
  for (int i=0; i< 3; i++) {
    pt = kal(rotate(6.28/4.)*mat2(1.0,0.,0.,1.0)*pt,6)+vec2(.29,.2);
  }
  inner = mix(inner,vec3(1.), vec3(smoothstep(0.00,-1.900,1.6+cos(ngon(pt, vec2(1.0,.0),5)*90.)*3.8)));

  pt = uv;
  pt *= rot;
  for (int i=0; i< 8; i++) {
    pt = kal(rotate(6.28/2.)*mat2(1.0,0.,0.,1.0)*pt,29)+vec2(.9,.2);
  }

  outer = mix(outer,vec3(1.), vec3(smoothstep(0.00,-1.900,1.6+cos(ngon(pt, vec2(0.0,.0),1)*30.)*6.8)));

  colour = mix(colour, vec3(1.), smoothstep(0.5,.55, circle(uv,vec2(0.),.6)));
  colour = mix(inner, colour, smoothstep(0.6,.55, circle(uv,vec2(0.),.6)));


  colour = mix(colour, vec3(1.), smoothstep(0.85,.9, circle(uv,vec2(0.),.6)));
  colour = mix(outer, colour, smoothstep(0.95,.9, circle(uv,vec2(0.),.6)));


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
  light = occlude(light,color(uv*rotate( iGlobalTime/5.4), rotate(-length(uv*.7) )));
  //colour = min(colour, );
  // slide 2
  light = occlude(light,color(uv*rotate(-iGlobalTime/5.4), rotate(length(uv*.7))));
  //colour = min(colour, color(uv*rot(-iGlobalTime/4.)));


  light = mix(light,vec3(0.07,.0,.082), smoothstep(.98,1.,abs(circle(uv, vec2(0.), 0.9))));

  gl_FragColor = vec4(light, 1.);

}
