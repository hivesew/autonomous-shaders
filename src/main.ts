import './style.css';

async function main() {
  const canvas = document.getElementById('gl-canvas') as HTMLCanvasElement;
  const gl = canvas.getContext('webgl');
  if (!gl) {
    console.error('WebGL not supported!');
    return;
  }

  // Fetch external files
  const [vertexShaderSource, fragmentShaderSource, descriptionText] =
    await Promise.all([
      `attribute vec2 a_position; void main() { gl_Position = vec4(a_position, 0.0, 1.0); }`, // Vertex shader is static
      fetch('/shader.glsl').then((res) => res.text()),
      fetch('/description.txt').then((res) => res.text()),
    ]);

  document.getElementById('description')!.textContent = descriptionText;

  const createShader = (
    gl: WebGLRenderingContext,
    type: number,
    source: string
  ) => {
    const shader = gl.createShader(type)!;
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.error('Shader compile error:', gl.getShaderInfoLog(shader));
      gl.deleteShader(shader);
      return null;
    }
    return shader;
  };

  const vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource)!;
  const fragmentShader = createShader(
    gl,
    gl.FRAGMENT_SHADER,
    fragmentShaderSource
  )!;

  const program = gl.createProgram()!;
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    console.error('Program link error:', gl.getProgramInfoLog(program));
    return;
  }
  gl.useProgram(program);

  const positionBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  const positions = [-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1];
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

  const positionAttributeLocation = gl.getAttribLocation(program, 'a_position');
  gl.enableVertexAttribArray(positionAttributeLocation);
  gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

  const resolutionUniformLocation = gl.getUniformLocation(
    program,
    'u_resolution'
  );
  const timeUniformLocation = gl.getUniformLocation(program, 'u_time');

  const resize = () => {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
    gl.uniform2f(resolutionUniformLocation, gl.canvas.width, gl.canvas.height);
  };
  window.addEventListener('resize', resize, false);
  resize();

  const render = (time: number) => {
    time *= 0.001; // convert to seconds
    gl.uniform1f(timeUniformLocation, time);
    gl.drawArrays(gl.TRIANGLES, 0, 6);
    requestAnimationFrame(render);
  };
  requestAnimationFrame(render);
}

main();
