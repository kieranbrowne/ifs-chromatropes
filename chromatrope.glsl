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

float line( in vec2 p, in vec2 a, in vec2 b )
{
  vec2 pa = p-a, ba = b-a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h );
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
  // colour = mix(colour,vec3(1.), smoothstep(.98,1.,abs(circle(pt, vec2(0.), 0.9))));

  //pt *= rot;
  // inner = vec3(0.0);
  // vec3 outer = vec3(0.0);

  // colour = mix(colour,vec3(1.), vec3(smoothstep(0.90,1.800,-3.92+sin(ngon(pt, vec2(0.0,.0),6)*90.)*2.8)));
  // colour = mix(colour,vec3(1.), vec3(smoothstep(0.00,-1.800,-.2+cos(ngon(pt*rot, vec2(0.0,.0),3)*90.)*2.8)));

  // colour = mix(colour,vec3(1.), smoothstep(.005,.01,ngon(pt, vec2(0.0,0.3), 18)));
  // colour = mix(colour,vec3(.0), smoothstep(.015,.01,ngon(pt, vec2(0.0,0.4), 18)));
  // colour = mix(colour,vec3(.0), smoothstep(.02,.01,ngon(pt, vec2(0.0,0.55), 18)));


  // flashes
  // placed out of phase slightly, these can create interesting animated patterns
  for (int i=0; i< 8; i++) {
    pt = kal(rotate(6.28/9.56)*mat2(1.0,0.,0.,1.0)*pt,18);
  }
  colour = mix(colour,vec3(1.), smoothstep(.02,.03,ngon(pt, vec2(0.0,0.7), 12)));

  pt = uv;
  for (int i=0; i< 8; i++) {
    pt = kal(rotate(6.28/6.35)*mat2(1.0,0.,0.,1.0)*pt,12);
  }
  colour = mix(colour, vec3(smoothstep(.02,.03,ngon(pt, vec2(0.0,0.6), 12))),
               smoothstep(.7,.6, length(uv))
               );

  pt = uv;
  for (int i=0; i< 8; i++) {
    pt = kal(rotate(6.28/6.65)*mat2(1.0,0.,0.,1.0)*pt,12);
  }
  colour = mix(colour, vec3(smoothstep(.02,.03,ngon(pt, vec2(0.0,0.5), 12))),
               smoothstep(.6,.5, length(uv))
               );

  // firework thing
  // pt *= rot;
  // for (int i=0; i< 9; i++) {
  //   pt = kal(rotate(6.28/2.7)*mat2(1.0,0.,0.,1.0)*pt,8);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03,line(pt,vec2(-.0,-.305), vec2(-.3,-.91))));

  // fishy thing
  // pt *= rot;
  // for (int i=0; i< 2; i++) {
  //   pt = kal(rotate(6.28/2.8)*mat2(1.0,0.,0.,1.0)*pt,8);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03,line(pt,vec2(-.2,-.305)*rot, vec2(-.0,-.71))));


  // star thing
  //pt *= rot;
  // for (int i=0; i< 8; i++) {
  //   pt = kal(rotate(6.28/3.0)*mat2(1.0,0.,0.,1.0)*pt,8);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03,line(pt,vec2(-.14,-.0), vec2(-.0,-.8))));

  // line flash
  // for (int i=0; i< 8; i++) {
  //   pt = kal(rotate(6.28/9.)*mat2(1.0,0.,0.,1.0)*pt,9);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03,line(pt,vec2(-.01,-.6), vec2(-0.01,-.8))));

  // inward
  // pt *= rot;
  // for (int i=0; i< 8; i++) {
  //   pt = kal(rotate(6.28/9.)*mat2(1.0,0.,0.,1.0)*pt,9);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03,line(pt,vec2(-.01,-.6), vec2(-0.01,-.8))));

  // star flash
  // pt *= rot;
  // for (int i=0; i< 8; i++) {
  //   pt = kal(rotate(6.28/16.)*mat2(1.0,0.,0.,1.0)*pt,16);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03, abs(pt.x/pt.y)));

  // lead outward
  // pt *= rot;
  // for (int i=0; i< 8; i++) {
  //   pt = kal(rotate(6.28/9.)*mat2(1.0,0.,0.,1.0)*pt,9);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03, abs(pt.x)));

  // box
  // pt *= rot;
  // for (int i=0; i< 8; i++) {
  //   pt = kal(rotate(6.28/2.)*mat2(1.0,0.,0.,1.0)*pt,3)+vec2(0.1,0.9);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03, abs(.1- mod(ngon(pt, vec2(0.0,0.0),5),.15))));


  // warp thing
  // pt *= rot;
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03, abs(mod(ngon(pt, vec2(0.3,0.0),4), .1))));

  // warp thing
  // pt *= rot*2*rot/rot;
  // pt *= rot;
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03, abs(mod(ngon(pt, vec2(0.2,0.2),0), .1))));

  // pt = uv;
  // pt *= rot;
  // for (int i=0; i< 3; i++) {
  //   pt = kal(rotate(6.28/4.)*mat2(1.0,0.,0.,1.0)*pt,6)+vec2(.29,.2);
  // }
  // inner = mix(inner,vec3(1.), vec3(smoothstep(0.00,-1.900,1.6+cos(ngon(pt, vec2(1.0,.0),5)*90.)*3.8)));

  // pt = uv;
  // pt *= rot;
  // for (int i=0; i< 8; i++) {
  //   pt = kal(rotate(6.28/2.)*mat2(1.0,0.,0.,1.0)*pt,29)+vec2(.9,.2);
  // }

  // outer = mix(outer,vec3(1.), vec3(smoothstep(0.00,-1.900,1.6+cos(ngon(pt, vec2(0.0,.0),1)*30.)*6.8)));

  // colour = mix(colour, vec3(1.), smoothstep(0.5,.55, circle(uv,vec2(0.),.6)));
  // colour = mix(inner, colour, smoothstep(0.6,.55, circle(uv,vec2(0.),.6)));


  // colour = mix(colour, vec3(1.), smoothstep(0.85,.9, circle(uv,vec2(0.),.6)));
  // colour = mix(outer, colour, smoothstep(0.95,.9, circle(uv,vec2(0.),.6)));

  // fishy thing
  // pt *= rot;
  // for (int i=0; i < 2; i++) {
  //   pt = kal(rotate(6.28/.14)*mat2(1.0,0.,0.,1.0)*pt,21);
  // }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03,line(pt,vec2(-.2,-.305)*rot, vec2(-.0,-.71))));

  // colour = mix(colour, vec3(smoothstep(-.2,.6,-sin(ngon(uv, vec2(0.,0.),4) * 138.))), smoothstep(.51,.5,length(uv)));
  // colour = mix(colour, vec3(1.), smoothstep(.23,.22,length(uv)));


  pt = uv;
  //pt *= rot;
  for (int i=0; i< 1; i++) {
    pt = kal(rotate(6.28/1)*mat2(1.0,0.,0.,1.0)*pt,16);
  }
  // colour = mix(colour,vec3(1.), smoothstep(.02,.03,line(pt,vec2(-.0,-.305), vec2(-.3,-.91))));
  colour = mix(colour, vec3(smoothstep(.005,.017,line(pt,vec2(-.03,-.0), vec2(-.03,-.91)))), smoothstep(.41,.4,length(uv)));

  pt = uv;
  pt *= rot;
  for (int i=0; i< 1; i++) {
    pt = kal(rotate(6.28/3.145)*mat2(1.0,0.,0.,1.0)*pt,70);
  }
  colour = mix(colour, vec3(smoothstep(0.00,.022,line(pt,vec2(.0,-1.), vec2(.0,1.)))), smoothstep(.73,.75,length(uv)));

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
  // light = occlude(light,color(uv*rotate( iGlobalTime/4.4), rotate(-length(uv*1.0) )));
  //colour = min(colour, );
  // slide 2
  light = occlude(light,color(uv*rotate(-iGlobalTime/4.4), rotate(length(uv*1.0))));
  //colour = min(colour, color(uv*rot(-iGlobalTime/4.)));


  light = mix(light,vec3(0.0), smoothstep(.98,1.,abs(circle(uv, vec2(0.), 0.9))));

  gl_FragColor = vec4(light, 1.);

}
