{
  "name":"normalMapShader",
  "attributes": [
    {
      "semantic":"POSITION",
      "symbol":"vPosition"
    },
    {
      "semantic":"NORMAL",
      "symbol":"vNormal"
    },
    {
      "semantic":"TEXCOORD",
      "symbol":"vTexCoord"
    }
  ],
  "vertexShader": {
    "name":"normalMapVertex",
    "source":"attribute vec3 vPosition;attribute vec2 vTexCoord0;attribute vec3 vNormal;uniform mat4 uModelViewMatrix,uModelViewProjectionMatrix,uNormalMatrix;varying vec3 position;varying vec2 texCoord;varying vec3 normal;void main(){vec4 v=vec4(vPosition,1.);position=vec3(uModelViewMatrix*v);texCoord=vTexCoord0;normal=normalize(mat3(uNormalMatrix)*vNormal);gl_Position=uModelViewProjectionMatrix*v;}"
  },
  "fragmentShader": {
    "name":"normalMapFragment",
    "source":"precision mediump float;uniform sampler2D uDiffuse,uNormal,uSpecular;varying vec3 position;varying vec2 texCoord;varying vec3 normal;vec3 v=vec3(-1.,-1.,-1.),t=vec3(.4,.4,.4),u=vec3(.2,.2,.2);float n=16.;vec4 e(){vec3 d=normalize(normal),e=normalize(v),r=normalize(-position),z=reflect(-e,d);vec4 m=texture2D(uDiffuse,texCoord);vec3 p=m.xyz,o=texture2D(uSpecular,texCoord).xyz,l=t*(u+p*max(dot(e,d),0.)+o*pow(max(dot(z,r),0.),n));return vec4(l,m.w);}void main(){gl_FragColor=e();}"
  }
}