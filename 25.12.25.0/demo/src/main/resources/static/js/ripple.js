(() => {
  const c = document.createElement('canvas');
  c.id = 'rippleCanvas';
  c.style.position = 'fixed';
  c.style.top = '0';
  c.style.left = '0';
  c.style.width = '100%';
  c.style.height = '100%';
  c.style.zIndex = '0';
  c.style.pointerEvents = 'none';
  document.body.appendChild(c);
  const ctx = c.getContext('2d');
  let w = 0, h = 0, ripples = [], last = 0;
  const maxRipples = 100;
  function resize() {
    const dpr = window.devicePixelRatio || 1;
    w = c.clientWidth;
    h = c.clientHeight;
    c.width = Math.floor(w * dpr);
    c.height = Math.floor(h * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }
  function addRipple(x, y) {
    if (ripples.length > maxRipples) ripples.shift();
    riplesPush(x, y);
  }
  function riplesPush(x, y) {
    ripples.push({ x, y, r: 0, a: 0.6, t: 0 });
  }
  function randomRipple() {
    const x = Math.random() * w;
    const y = Math.random() * h;
    riplesPush(x, y);
  }
  function draw() {
    ctx.clearRect(0, 0, w, h);
    for (let i = 0; i < ripples.length; i++) {
      const rp = ripples[i];
      rp.t += 0.016;
      rp.r += 0.6 + rp.t * 0.4;
      rp.a -= 0.004 + rp.t * 0.002;
      if (rp.a <= 0 || rp.r > Math.max(w, h)) {
        ripples.splice(i, 1);
        i--;
        continue;
      }
      const rings = 3;
      for (let k = 0; k < rings; k++) {
        const rr = rp.r + k * 8;
        const aa = Math.max(rp.a - k * 0.08, 0);
        ctx.beginPath();
        ctx.arc(rp.x, rp.y, rr, 0, Math.PI * 2);
        ctx.strokeStyle = `rgba(108,92,231,${aa})`;
        ctx.lineWidth = 1.5;
        ctx.stroke();
      }
    }
  }
  function loop(ts) {
    if (!last) last = ts;
    const dt = ts - last;
    if (dt > 1200) {
      randomRipple();
      last = ts;
    }
    draw();
    requestAnimationFrame(loop);
  }
  window.addEventListener('resize', resize);
  window.addEventListener('pointerdown', e => addRipple(e.clientX, e.clientY));
  resize();
  requestAnimationFrame(loop);
})(); 
