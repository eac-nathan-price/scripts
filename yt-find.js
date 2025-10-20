// ==UserScript==
// @name         YT Find
// @namespace    https://youtube.com/
// @version      4.0
// @description  Press Ctrl+Shift+F to search YouTube transcript, jump to results, and navigate with arrow buttons.
// @author       eac-nathan-price
// @match        https://www.youtube.com/watch*
// @grant        none
// ==/UserScript==

(function() {
  'use strict';

  let ui = null;
  let inputEl, prevBtn, nextBtn, closeBtn;
  let matches = [];
  let currentIndex = 0;
  let searching = false;

  const sleep = ms => new Promise(res => setTimeout(res, ms));

  document.addEventListener('keydown', (e) => {
    if (e.ctrlKey && e.shiftKey && e.key.toLowerCase() === 'f') {
      e.preventDefault();
      toggleUI();
    }
  });

  function toggleUI() {
    if (ui) {
      ui.remove();
      ui = null;
      return;
    }

    ui = document.createElement('div');
    Object.assign(ui.style, {
      position: 'fixed',
      top: '20px',
      left: '50%',
      transform: 'translateX(-50%)',
      zIndex: 999999,
      backgroundColor: '#111',
      color: '#fff',
      padding: '6px',
      borderRadius: '8px',
      border: '2px solid #fff',
      display: 'flex',
      alignItems: 'center',
      gap: '4px'
    });

    inputEl = document.createElement('input');
    Object.assign(inputEl.style, {
      padding: '6px',
      fontSize: '14px',
      backgroundColor: '#222',
      color: '#fff',
      border: '1px solid #555',
      borderRadius: '4px',
      width: '220px'
    });
    inputEl.placeholder = 'Search transcript...';

    prevBtn = makeButton('←');
    nextBtn = makeButton('→');
    closeBtn = makeButton('✕');

    prevBtn.onclick = () => navigate(-1);
    nextBtn.onclick = () => navigate(1);
    closeBtn.onclick = () => toggleUI();

    ui.appendChild(prevBtn);
    ui.appendChild(inputEl);
    ui.appendChild(nextBtn);
    ui.appendChild(closeBtn);
    document.body.appendChild(ui);

    inputEl.focus();
    inputEl.addEventListener('keydown', async (e) => {
      if (e.key === 'Enter') {
        const query = inputEl.value.trim().toLowerCase();
        if (!query || searching) return;
        matches = [];
        currentIndex = 0;
        inputEl.style.borderColor = '#fff';
        searching = true;
        await ensureTranscriptReady();
        const found = await findMatchesIncrementally(query);
        searching = false;
        if (!found.length) inputEl.style.borderColor = 'red';
      } else if (e.key === 'Escape') {
        toggleUI();
      }
    });
  }

  function makeButton(label) {
    const btn = document.createElement('button');
    Object.assign(btn.style, {
      backgroundColor: '#222',
      color: '#fff',
      border: '1px solid #555',
      borderRadius: '4px',
      cursor: 'pointer',
      padding: '4px 8px'
    });
    btn.textContent = label;
    return btn;
  }

  async function ensureTranscriptReady() {
    // Already open?
    if (document.querySelector('ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-searchable-transcript"]'))
      return;

    // Try to open via visible "Transcript" button
    const showTranscriptBtn = [...document.querySelectorAll('tp-yt-paper-button, button, yt-button-shape')]
      .find(b => b.textContent.toLowerCase().includes('transcript'));
    if (showTranscriptBtn) {
      showTranscriptBtn.click();
      await sleep(1500);
      return;
    }

    // Try 3-dot menu
    const menuBtn = document.querySelector('ytd-menu-renderer yt-icon-button, ytd-menu-renderer button');
    if (menuBtn) {
      menuBtn.click();
      await sleep(800);
      const transcriptOption = [...document.querySelectorAll('tp-yt-paper-item')].find(el =>
        el.textContent.toLowerCase().includes('transcript')
      );
      if (transcriptOption) {
        transcriptOption.click();
        await sleep(1500);
      }
    }
  }

  function deepText(el) {
    if (!el) return '';
    let text = el.textContent || '';
    if (el.shadowRoot) {
      for (const n of el.shadowRoot.querySelectorAll('*')) {
        text += n.textContent || '';
      }
    }
    return text.trim();
  }

  async function findMatchesIncrementally(query) {
    const panel = document.querySelector('ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-searchable-transcript"]');
    if (!panel) return [];

    const container = panel.querySelector('#segments-container');
    const scrollContainer = container?.parentElement;
    if (!scrollContainer) return [];

    let lastScrollTop = -1;
    let unchanged = 0;

    while (unchanged < 3) {
      const segments = [...container.querySelectorAll('ytd-transcript-segment-renderer')];
      for (const seg of segments) {
        const textEl = seg.querySelector('.segment-text');
        const linkEl = seg.querySelector('a[href^="/watch"]');
        const text = deepText(textEl);
        if (text.toLowerCase().includes(query)) {
          matches.push({ element: seg, link: linkEl, text });
          highlight(seg);
          seg.scrollIntoView({ behavior: 'smooth', block: 'center' });
          await sleep(400);
          linkEl?.click();
          return matches;
        }
      }
      scrollContainer.scrollTop += 5000;
      await sleep(250);
      if (scrollContainer.scrollTop === lastScrollTop) unchanged++;
      else unchanged = 0;
      lastScrollTop = scrollContainer.scrollTop;
    }
    return matches;
  }

  function highlight(seg) {
    seg.style.background = 'rgba(255,255,0,0.3)';
  }

  function navigate(dir) {
    if (!matches.length) return;
    currentIndex = (currentIndex + dir + matches.length) % matches.length;
    const { element, link } = matches[currentIndex];
    element.scrollIntoView({ behavior: 'smooth', block: 'center' });
    link?.click();
  }
})();
