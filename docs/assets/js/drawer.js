// =====================================================================
// drawer.js — mobile nav off-canvas drawer.
//
// Architecture: the drawer is a separate <div id="nav-drawer"> outside
// the header (escapes the backdrop-filter containing block). On load we
// clone the inline <ul.nav-list> from #primary-nav into #nav-drawer-list,
// and mirror aria-expanded across all [data-nav-toggle] buttons.
// Vanilla JS IIFE, no deps.
// =====================================================================

(function () {
  'use strict';

  var drawer = document.getElementById('nav-drawer');
  var drawerList = document.getElementById('nav-drawer-list');
  var inlineNav = document.getElementById('primary-nav');
  var inlineList = inlineNav ? inlineNav.querySelector('.nav-list') : null;
  var overlay = document.querySelector('.nav-overlay');
  var toggles = Array.prototype.slice.call(
    document.querySelectorAll('[data-nav-toggle]')
  );

  if (!drawer || !drawerList) return;

  // Clone nav-list into drawer so we don't duplicate HTML in markup
  if (inlineList) {
    drawerList.innerHTML = inlineList.innerHTML;
  }

  function isOpen() {
    return drawer.classList.contains('is-open');
  }

  function focusables() {
    return drawer.querySelectorAll(
      'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
    );
  }

  function setOpen(open) {
    if (open) {
      drawer.classList.add('is-open');
      if (overlay) overlay.classList.add('is-open');
      document.body.classList.add('nav-open');
      toggles.forEach(function (el) {
        el.setAttribute('aria-expanded', 'true');
      });
      var f = focusables()[0];
      if (f) f.focus();
    } else {
      drawer.classList.remove('is-open');
      if (overlay) overlay.classList.remove('is-open');
      document.body.classList.remove('nav-open');
      toggles.forEach(function (el) {
        el.setAttribute('aria-expanded', 'false');
      });
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

  // Close when any drawer link is activated
  drawer.querySelectorAll('a').forEach(function (a) {
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

  // Click outside drawer
  document.addEventListener('click', function (e) {
    if (!isOpen()) return;
    if (drawer.contains(e.target)) return;
    if (toggles.some(function (el) { return el.contains(e.target); })) return;
    if (overlay && overlay.contains(e.target)) return;
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