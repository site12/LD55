shader_type canvas_item;


uniform sampler2D normal_texture : source_color, hint_screen_texture, filter_nearest;
uniform float low_distortion: hint_range(1.0, 2.0) = 1.0;
uniform float distortion: hint_range(1.0, 10.0) = 1.0;
uniform float high_distortion: hint_range(1.0, 100.0) = 1.0;

// void vertex() {
// 	POSITION = vec4(VERTEX, 1.0);
// }

vec3 tex2D( sampler2D _tex, vec2 _p ){
  vec3 col = texture( _tex, _p ).xyz;
  if ( 0.5 < abs( _p.x - 0.5 ) ) {
    col = vec3( 0.1 );
  }
  return col;
}

float hash( vec2 _v ){
  return fract( sin( dot( _v, vec2( 89.44, 19.36 ) ) ) * 22189.22 );
}

float iHash( vec2 _v, vec2 _r ){
  float h00 = hash( vec2( floor( _v * _r + vec2( 0.0, 0.0 ) ) / _r ) );
  float h10 = hash( vec2( floor( _v * _r + vec2( 1.0, 0.0 ) ) / _r ) );
  float h01 = hash( vec2( floor( _v * _r + vec2( 0.0, 1.0 ) ) / _r ) );
  float h11 = hash( vec2( floor( _v * _r + vec2( 1.0, 1.0 ) ) / _r ) );
  vec2 ip = vec2( smoothstep( vec2( 0.0, 0.0 ), vec2( 1.0, 1.0 ), mod( _v*_r, 1. ) ) );
  return ( h00 * ( 1. - ip.x ) + h10 * ip.x ) * ( 1. - ip.y ) + ( h01 * ( 1. - ip.x ) + h11 * ip.x ) * ip.y;
}

float noise( vec2 _v ){
  float sum = 0.;
  for( int i=1; i<9; i++ )
  {
    sum += iHash( _v + vec2( float( i )), vec2( 2. * pow( 2., float( i ) ) ) ) /pow( 2., float( i ) );
  }
  return sum;
}

void fragment(){
  vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE);
  vec2 uvn = uv;
  vec3 col = vec3( 0.0 );

  // tape wave
  uvn.x += ( noise( vec2( uvn.y, TIME ) ) - 0.5 )* 0.005 * high_distortion;
  uvn.x += ( noise( vec2( uvn.y * 100.0, TIME * 10.0 ) ) - 0.5 ) * 0.01;

  // tape crease
  float tcRate = 0.3;
  float tcPhase = clamp( ( sin( uvn.y * 8.0 - TIME * PI * tcRate) - 0.92 ) * noise( vec2( TIME ) ), 0.0, 0.01 ) * 10.0;
  float tcNoise = max( noise( vec2( uvn.y * 100.0, TIME * 10.0 ) ) - 0.5, 0.0 );
  uvn.x = uvn.x - tcNoise * tcPhase;

  // switching noise
  float snPhase = smoothstep( 0.03, 0.0, uvn.y );
  uvn.y += snPhase * 0.3;
  uvn.x += snPhase * ( ( noise( vec2( uv.y * 100.0, TIME * 10.0 ) ) - 0.5 ) * 0.2 );
    
  col = tex2D( normal_texture, uvn );
  col *= 1.0 - tcPhase;
  col = mix(
    col,
    col.yzx,
    snPhase
  );

//   bloom
  for( float x = -4.0; x < 2.5; x += 1.0 ){
    col.xyz += vec3(
      tex2D( normal_texture, uvn + vec2( x - 0.0, 0.0 ) * 2E-3 * distortion).x,
      tex2D( normal_texture, uvn + vec2( x - 2.0, 0.0 ) * 2E-3 * distortion).y,
      tex2D( normal_texture, uvn + vec2( x - 4.0, 0.0 ) * 2E-3 * distortion).z
    ) * 0.1 * low_distortion;
  }
  col *= 0.6;

  // ac beat
  col *= 1.0 + clamp( noise( vec2( 0.0, uv.y + TIME * 0.2 ) ) * 0.6 - 0.25, 0.0, 0.1 );


  COLOR = vec4(col, 1.0);
}
