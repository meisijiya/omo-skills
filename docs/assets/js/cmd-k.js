/* Cmd-K command palette — vanilla JS, no globals.
 * Loads Fuse.js from CDN; fetches /assets/js/search-index.json;
 * toggles on Cmd/Ctrl+K or [data-cmd-k-open], closes on overlay / Esc / [data-cmd-k-close].
 * Keyboard nav: ArrowUp / ArrowDown / Enter / Esc.
 */
(function () {
  'use strict';

  var FUSE_CDN = 'https://cdn.jsdelivr.net/npm/fuse.js@7.0.0/dist/fuse.min.js';
  var SEARCH_INDEX_URL = '/omo-skills/assets/js/search-index.json';
  var DEBOUNCE_MS = 150;
  var MAX_RESULTS = 12;

  var fuse = null, activeIndex = -1, lastTrigger = null, root = null;

  // ---------- bootstrap ----------
  function init() {
    root = document.getElementById('cmd-k');
    if (!root) return;
    loadScript(FUSE_CDN)
      .then(function () { return fetch(SEARCH_INDEX_URL).then(function (r) { return r.json(); }); })
      .then(function (data) {
        fuse = new Fuse(data, {
          keys: ['title', 'keywords', 'desc'],
          threshold: 0.4,
          ignoreLocation: true,
          includeScore: true,
        });
        bindTriggers();
        bindPanel();
      })
      .catch(function (err) {
        root.dataset.fuseError = err && err.source === 'fuse' ? 'true' : '';
        root.dataset.indexError = err && err.source === 'index' ? 'true' : '';
        render('');
      });
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src; s.async = true;
      s.onload = resolve;
      s.onerror = function () { reject({ source: 'fuse' }); };
      document.head.appendChild(s);
    });
  }

  // ---------- triggers ----------
  function bindTriggers() {
    document.querySelectorAll('[data-cmd-k-open]').forEach(function (el) {
      el.addEventListener('click', function (e) { e.preventDefault(); open(el); });
    });
    document.querySelectorAll('[data-cmd-k-close]').forEach(function (el) {
      el.addEventListener('click', function (e) { e.preventDefault(); close(); });
    });
    document.addEventListener('keydown', function (e) {
      var modK = (e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k';
      if (modK) {
        e.preventDefault();
        isOpen() ? close() : open();
      } else if (e.key === 'Escape' && isOpen()) {
        e.preventDefault();
        close();
      }
    });
  }

  // ---------- panel / input ----------
  function bindPanel() {
    var input = document.getElementById('cmd-k-input');
    var list = document.getElementById('cmd-k-results');
    if (!input || !list) return;

    input.addEventListener('input', debounce(function () { render(input.value); }, DEBOUNCE_MS));

    input.addEventListener('keydown', function (e) {
      var items = list.querySelectorAll('.cmd-k-result');
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (!items.length) return;
        activeIndex = Math.min(items.length - 1, activeIndex + 1);
        updateActive(items);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (!items.length) return;
        activeIndex = Math.max(0, activeIndex - 1);
        updateActive(items);
      } else if (e.key === 'Enter' && activeIndex >= 0 && items[activeIndex]) {
        e.preventDefault();
        items[activeIndex].click();
      }
    });

    list.addEventListener('click', function (e) {
      if (e.target.closest('.cmd-k-result')) close();
    });
  }

  // ---------- render ----------
  function render(query) {
    var list = document.getElementById('cmd-k-results');
    if (!list) return;
    list.innerHTML = '';
    activeIndex = -1;

    var root = document.getElementById('cmd-k');
    if (root && root.dataset.fuseError === 'true') return setEmpty(list, '搜索引擎加载失败 · 搜索暂不可用');
    if (root && root.dataset.indexError === 'true') return setEmpty(list, '搜索索引加载失败 · 搜索暂不可用');
    if (!fuse) return setEmpty(list, '搜索初始化中…');

    var q = (query || '').trim();
    if (!q) return setEmpty(list, '输入关键字开始搜索');

    var results = fuse.search(q, { limit: MAX_RESULTS });
    if (!results.length) return setEmpty(list, '无匹配项 · 按 Esc 关闭');

    var html = '';
    results.forEach(function (r, i) {
      var item = r.item;
      html += '<li role="option"><a href="' + escapeHtml(item.url)
        + '" class="cmd-k-result" data-i="' + i + '">'
        + '<span class="cmd-k-result-type mono muted">' + escapeHtml(item.type) + '</span>'
        + '<span class="cmd-k-result-title">' + escapeHtml(item.title) + '</span>'
        + '</a></li>';
    });
    list.innerHTML = html;
  }

  function setEmpty(list, msg) {
    list.innerHTML = '<li class="cmd-k-empty muted">' + msg + '</li>';
  }

  function updateActive(items) {
    items.forEach(function (el, i) {
      var on = i === activeIndex;
      el.classList.toggle('active', on);
      if (on) el.setAttribute('aria-selected', 'true'); else el.removeAttribute('aria-selected');
    });
    if (activeIndex >= 0 && items[activeIndex].scrollIntoView) {
      items[activeIndex].scrollIntoView({ block: 'nearest' });
    }
  }

  // ---------- open / close ----------
  function open(trigger) {
    var root = document.getElementById('cmd-k');
    if (!root) return;
    lastTrigger = trigger || document.activeElement;
    root.classList.add('visible');
    root.setAttribute('aria-hidden', 'false');
    var input = document.getElementById('cmd-k-input');
    if (input) {
      render(input.value);
      setTimeout(function () { input.focus(); input.select(); }, 30);
    }
  }

  function close() {
    var root = document.getElementById('cmd-k');
    if (!root) return;
    root.classList.remove('visible');
    root.setAttribute('aria-hidden', 'true');
    var input = document.getElementById('cmd-k-input');
    if (input) input.value = '';
    render('');
    if (lastTrigger && typeof lastTrigger.focus === 'function') lastTrigger.focus();
  }

  function isOpen() {
    var root = document.getElementById('cmd-k');
    return !!(root && root.classList.contains('visible'));
  }

  // ---------- utils ----------
  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function debounce(fn, ms) {
    var t = null;
    return function () {
      var args = arguments, ctx = this;
      clearTimeout(t);
      t = setTimeout(function () { fn.apply(ctx, args); }, ms);
    };
  }

  // ---------- go ----------
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
