// =====================================================================
// drawer.js — mobile nav off-canvas drawer.
// Toggle via [data-nav-toggle] (hamburger, X button, overlay); ESC closes;
// link click closes; resize past 720px auto-closes. Vanilla JS, no deps.
// =====================================================================

(function () {
  'use strict';

  var nav = document.getElementById('primary-nav');
  if (!nav) return;
  var overlay = document.querySelector('.nav-overlay');
  var toggles = Array.prototype.slice.call(
    document.querySelectorAll('[data-nav-toggle]')
  );

  function isOpen() {
    return nav.classList.contains('is-open');
  }

  function focusables() {
    return nav.querySelectorAll(
      'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
    );
  }

  function setOpen(open) {
    if (open) {
      nav.classList.add('is-open');
      if (overlay) overlay.classList.add('is-open');
      document.body.classList.add('nav-open');
      toggles.forEach(function (el) {
        el.setAttribute('aria-expanded', 'true');
      });
      // focus first interactive element inside drawer
      var f = focusables()[0];
      if (f) f.focus();
    } else {
      nav.classList.remove('is-open');
      if (overlay) overlay.classList.remove('is-open');
      document.body.classList.remove('nav-open');
      toggles.forEach(function (el) {
        el.setAttribute('aria-expanded', 'false');
      });
      // return focus to the hamburger (or any visible toggle)
      var hb = toggles.find(function (el) {
        return el.classList.contains('nav-toggle');
      });
      if (hb) hb.focus();
    }
  }

  // Initial state: closed
  setOpen(false);

  toggles.forEach(function (el) {
    el.addEventListener('click', function (e) {
      e.preventDefault();
      setOpen(!isOpen());
    });
  });

  // Close when any nav link is activated
  nav.querySelectorAll('a').forEach(function (a) {
    a.addEventListener('click', function () {
      if (isOpen()) setOpen(false);
    });
  });

  // ESC closes
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && isOpen()) {
      setOpen(false);
    }
  });

  // Click outside (overlay handled by toggle listener; this guards
  // against overlay missing on some pages)
  document.addEventListener('click', function (e) {
    if (!isOpen()) return;
    if (nav.contains(e.target)) return;
    if (toggles.some(function (el) { return el.contains(e.target); })) return;
    setOpen(false);
  });

  // Auto-close when resized past the mobile breakpoint
  var resizeTimer = null;
  window.addEventListener('resize', function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(function () {
      if (window.innerWidth > 720 && isOpen()) setOpen(false);
    }, 120);
  });
})();