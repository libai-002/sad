(function () {
  var c = document.createElement('canvas');
  c.id = 'sunraysCanvas';
  c.style.position = 'fixed';
  c.style.top = '0';
  c.style.left = '0';
  c.style.width = '100%';
  c.style.height = '100%';
  c.style.zIndex = '-1';
  c.style.pointerEvents = 'none';
  if (document.body.firstChild) {
    document.body.insertBefore(c, document.body.firstChild);
  } else {
    document.body.appendChild(c);
  }
  var ctx = c.getContext('2d');
  var w = 0, h = 0, dpr = 1;
  var rays = [];
  var rayCount = 24;
  var baseHue = Math.floor(Math.random() * 360);
  var origin = { x: 0, y: 0 };
  var t = 0;
  function resize() {
    dpr = window.devicePixelRatio || 1;
    w = c.clientWidth;
    h = c.clientHeight;
    c.width = Math.floor(w * dpr);
    c.height = Math.floor(h * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    origin.x = -w * 0.25;
    origin.y = h * 0.2;
    initRays();
  }
  function initRays() {
    rays = [];
    for (var i = 0; i < rayCount; i++) {
      var angle = i * (Math.PI * 2 / rayCount) * 0.35 + Math.random() * 0.08;
      var width = 8 + Math.random() * 18;
      var hue = (baseHue + i * 9 + Math.random() * 20) % 360;
      var speed = 0.2 + Math.random() * 0.6;
      rays.push({ a: angle, w: width, h: hue, s: speed, o: Math.random() * 0.6 + 0.15 });
    }
  }
  function draw() {
    ctx.clearRect(0, 0, w, h);
    ctx.globalCompositeOperation = 'lighter';
    t += 0.016;
    for (var i = 0; i < rays.length; i++) {
      var r = rays[i];
      var len = Math.max(w, h) * 1.6;
      var jitter = Math.sin(t * r.s + i) * 0.12;
      var angle = r.a + jitter;
      var dx = Math.cos(angle) * len;
      var dy = Math.sin(angle) * len;
      var gx = origin.x + dx * 0.2;
      var gy = origin.y + dy * 0.2;
      var grad = ctx.createLinearGradient(origin.x, origin.y, origin.x + dx, origin.y + dy);
      var c1 = 'hsla(' + ((r.h + t * 40) % 360) + ',70%,70%,' + r.o + ')';
      var c2 = 'hsla(' + ((r.h + t * 40 + 40) % 360) + ',70%,50%,0)';
      grad.addColorStop(0, c1);
      grad.addColorStop(1, c2);
      ctx.strokeStyle = grad;
      ctx.lineWidth = r.w;
      ctx.beginPath();
      ctx.moveTo(origin.x, origin.y);
      ctx.lineTo(origin.x + dx, origin.y + dy);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(gx, gy);
      ctx.lineTo(origin.x + dx * 0.9, origin.y + dy * 0.9);
      ctx.stroke();
    }
    ctx.globalCompositeOperation = 'source-over';
  }
  function loop() {
    draw();
    requestAnimationFrame(loop);
  }
  window.addEventListener('resize', resize);
  resize();
  loop();
})(); 
