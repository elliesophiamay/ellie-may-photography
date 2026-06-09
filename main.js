/* ═══════════════════════════════════════════════════════
   ELLIE MAY PHOTOGRAPHY — JavaScript
═══════════════════════════════════════════════════════ */

document.addEventListener('DOMContentLoaded', () => {

  // ─── NAV: scroll state ──────────────────────────────
  const header = document.getElementById('top');
  const navHeader = document.querySelector('.nav-header');

  const updateNav = () => {
    if (window.scrollY > 40) {
      navHeader.classList.add('scrolled');
    } else {
      navHeader.classList.remove('scrolled');
    }
  };
  window.addEventListener('scroll', updateNav, { passive: true });
  updateNav();

  // ─── NAV: mobile toggle ─────────────────────────────
  const navToggle = document.getElementById('nav-toggle');
  const navLinks  = document.getElementById('nav-links');

  navToggle.addEventListener('click', () => {
    const isOpen = navLinks.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', isOpen);
  });

  // Close nav on link click
  navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('open');
    });
  });

  // ─── NAV: active link on scroll ─────────────────────
  const sections = document.querySelectorAll('section[id]');
  const navLinksAll = document.querySelectorAll('.nav-link');

  const highlightNav = () => {
    const scrollY = window.scrollY + 120;
    sections.forEach(section => {
      const top    = section.offsetTop;
      const bottom = top + section.offsetHeight;
      const id     = section.getAttribute('id');
      if (scrollY >= top && scrollY < bottom) {
        navLinksAll.forEach(l => l.classList.remove('active'));
        const active = document.querySelector(`.nav-link[href="#${id}"]`);
        if (active) active.classList.add('active');
      }
    });
  };
  window.addEventListener('scroll', highlightNav, { passive: true });

  // ─── HERO: subtle zoom ──────────────────────────────
  const hero = document.querySelector('.hero');
  if (hero) {
    setTimeout(() => hero.classList.add('loaded'), 100);
  }

  // ─── TESTIMONIALS slider ────────────────────────────
  const slides = document.querySelectorAll('.testimonial-slide');
  const dots   = document.querySelectorAll('.t-dot');
  let current  = 0;
  let autoTimer;

  const goTo = (idx) => {
    slides[current].classList.remove('active');
    dots[current].classList.remove('active');
    current = (idx + slides.length) % slides.length;
    slides[current].classList.add('active');
    dots[current].classList.add('active');
  };

  const startAuto = () => {
    autoTimer = setInterval(() => goTo(current + 1), 6000);
  };
  const stopAuto = () => clearInterval(autoTimer);

  document.getElementById('t-next').addEventListener('click', () => {
    stopAuto(); goTo(current + 1); startAuto();
  });
  document.getElementById('t-prev').addEventListener('click', () => {
    stopAuto(); goTo(current - 1); startAuto();
  });

  dots.forEach((dot, i) => {
    dot.addEventListener('click', () => {
      stopAuto(); goTo(i); startAuto();
    });
  });

  startAuto();

  // ─── SCROLL REVEAL ──────────────────────────────────
  const revealEls = document.querySelectorAll(
    '.about-grid, .package-card, .gallery-item, .contact-grid, .section-header'
  );

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        entry.target.style.animationDelay = `${i * 0.08}s`;
        entry.target.classList.add('revealed');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -60px 0px' });

  revealEls.forEach(el => {
    el.classList.add('will-reveal');
    observer.observe(el);
  });

  // ─── CONTACT FORM ─── native fetch → Formspree ──────────
  const contactForm   = document.getElementById('contact-form');
  const successPanel  = document.querySelector('[data-fs-success]');
  const errorPanel    = document.querySelector('[data-fs-error]');
  const submitBtn     = document.getElementById('submit-btn');

  if (contactForm) {
    contactForm.addEventListener('submit', async (e) => {
      e.preventDefault();

      // Reset any previous error
      errorPanel.textContent = '';
      submitBtn.disabled = true;
      submitBtn.textContent = 'Sending…';

      try {
        const data = new FormData(contactForm);
        const response = await fetch('https://formspree.io/f/mnjydbkz', {
          method: 'POST',
          body: data,
          headers: { Accept: 'application/json' }
        });

        if (response.ok) {
          // Show success, hide form
          contactForm.style.display = 'none';
          successPanel.style.display = 'flex';
        } else {
          const json = await response.json();
          const msg  = (json.errors || []).map(err => err.message).join(', ')
                       || 'Something went wrong. Please try again or email hello@elliemayphotos.com';
          errorPanel.textContent = msg;
          submitBtn.disabled = false;
          submitBtn.textContent = 'Send Message';
        }
      } catch {
        errorPanel.textContent = 'Network error — please check your connection and try again.';
        submitBtn.disabled = false;
        submitBtn.textContent = 'Send Message';
      }
    });
  }

  // ─── GALLERY: parallax on mouse ─────────────────────
  const galleryItems = document.querySelectorAll('.gallery-item');
  galleryItems.forEach(item => {
    item.addEventListener('mousemove', (e) => {
      const rect = item.getBoundingClientRect();
      const x = ((e.clientX - rect.left) / rect.width  - 0.5) * 10;
      const y = ((e.clientY - rect.top)  / rect.height - 0.5) * 10;
      item.querySelector('img').style.transform = `scale(1.06) translate(${x * 0.4}px, ${y * 0.4}px)`;
    });
    item.addEventListener('mouseleave', () => {
      item.querySelector('img').style.transform = '';
    });
  });

});

/* ─── REVEAL ANIMATION ────────────────────────────────── */
const style = document.createElement('style');
style.textContent = `
  .will-reveal {
    opacity: 0;
    transform: translateY(32px);
    transition: opacity 0.7s cubic-bezier(0.4,0,0.2,1),
                transform 0.7s cubic-bezier(0.4,0,0.2,1);
  }
  .will-reveal.revealed {
    opacity: 1;
    transform: none;
  }
`;
document.head.appendChild(style);
