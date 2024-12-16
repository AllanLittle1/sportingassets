const images = ['market.png', 'football.png'];

function setupAnimatedBackground() {
  const canvas = document.getElementById('animatedBackground');
  const ctx = canvas.getContext('2d');

  function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }

  window.addEventListener('resize', resizeCanvas);
  resizeCanvas();

  const sprites = [];
  const spriteCount = 15;

  const loadedImages = [];
  let loadedCount = 0;

  function loadImages() {
    images.forEach((src, index) => {
      const img = new Image();
      img.onload = () => {
        loadedCount++;
        if (loadedCount === images.length) {
          initSprites();
          animateSprites();
        }
      };
      img.src = src;
      loadedImages[index] = img;
    });
  }

  function initSprites() {
    for (let i = 0; i < spriteCount; i++) {
      sprites.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        image: loadedImages[Math.floor(Math.random() * loadedImages.length)],
        scale: Math.random() * 0.3 + 0.1,
        dx: (Math.random() - 0.5) * 1,
        dy: (Math.random() - 0.5) * 1,
        rotation: Math.random() * Math.PI * 2
      });
    }
  }

  function animateSprites() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    sprites.forEach((sprite) => {
      ctx.save();
      ctx.translate(sprite.x, sprite.y);
      ctx.rotate(sprite.rotation);
      ctx.globalAlpha = 0.7;
      ctx.drawImage(
        sprite.image, 
        -sprite.image.width * sprite.scale / 2, 
        -sprite.image.height * sprite.scale / 2, 
        sprite.image.width * sprite.scale, 
        sprite.image.height * sprite.scale
      );
      ctx.restore();

      sprite.x += sprite.dx;
      sprite.y += sprite.dy;
      sprite.rotation += 0.01;

      if (sprite.x < 0 || sprite.x > canvas.width) sprite.dx = -sprite.dx;
      if (sprite.y < 0 || sprite.y > canvas.height) sprite.dy = -sprite.dy;
    });

    requestAnimationFrame(animateSprites);
  }

  loadImages();
}

window.addEventListener('load', setupAnimatedBackground);