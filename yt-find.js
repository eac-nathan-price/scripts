// ==UserScript==
// @name         YouTube Find
// @namespace    https://youtube.com/
// @version      2.1
// @description  Press Ctrl+Shift+F to search YouTube's transcript and jump to that timestamp.
// @author       eac-nathan-price
// @match        https://www.youtube.com/watch*
// @grant        none
// ==/UserScript==

(function() {
  'use strict';

  let inputBox = null;
  let cachedSegments = [];
  let scanning = false;

  // Helper: wait
  const sleep = (ms) => new Promise(res => setTimeout(res, ms));

  // Shortcut handler
  document.addEventListener('keydown', async (e) => {
    if (e.ctrlKey && e.shiftKey && e.key.toLowerCase() === 'f') {
      e.preventDefault();
      toggleInputBox();
    }
  });

  // Toggle the floating search box
  function toggleInputBox() {
    if (inputBox) {
      inputBox.remove();
      inputBox = null;
      return;
    }

    inputBox = document.createElement('input');
    inputBox.type = 'text';
    inputBox.placeholder = 'Search transcript...';
    Object.assign(inputBox.style, {
      position: 'fixed',
      top: '20px',
      left: '50%',
      transform: 'translateX(-50%)',
      zIndex: 999999,
      padding: '10px',
      fontSize: '16px',
      backgroundColor: '#111',
      color: '#fff',
      border: '2px solid #fff',
      borderRadius: '6px',
      width: '320px'
    });
    document.body.appendChild(inputBox);
    inputBox.focus();

    inputBox.addEventListener('keydown', async (e) => {
      if (e.key === 'Enter') {
        const query = inputBox.value.trim().toLowerCase();
        if (!query) return;
        await ensureTranscriptReady();
        if (!cachedSegments.length) await scanTranscript();

        const match = cachedSegments.find(s => s.text.toLowerCase().includes(query));
        if (match) {
          match.element.scrollIntoView({ behavior: 'smooth', block: 'center' });
          await sleep(300);
          match.element.querySelector('a[href^="/watch"]')?.click();
        } else {
          inputBox.style.borderColor = 'red';
        }
      } else if (e.key === 'Escape') {
        toggleInputBox();
      }
    });
  }

  // Ensure transcript is open and visible
  async function ensureTranscriptReady() {
    // If transcript panel already exists
    if (document.querySelector('ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-searchable-transcript"]'))
      return;

    // Open transcript via the “...” menu or the description section
    const buttons = [...document.querySelectorAll('tp-yt-paper-button, button, yt-button-shape')];
    const showTranscriptBtn = buttons.find(b => b.textContent.toLowerCase().includes('transcript'));
    if (showTranscriptBtn) {
      showTranscriptBtn.click();
      await sleep(1500);
      return;
    }

    // Otherwise try opening from the context menu under description
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

  // Extract visible text, even inside shadow DOM
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

  // Collect and cache transcript segments
  async function scanTranscript() {
    scanning = true;
    cachedSegments = [];

    const panel = document.querySelector('ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-searchable-transcript"]');
    if (!panel) {
      scanning = false;
      return;
    }

    const container = panel.querySelector('#segments-container');
    const scrollContainer = container?.parentElement;
    if (!scrollContainer) {
      scanning = false;
      return;
    }

    let lastScrollTop = -1;
    let unchanged = 0;

    while (unchanged < 3) {
      const items = [...container.querySelectorAll('ytd-transcript-segment-renderer')];
      for (const item of items) {
        const textEl = item.querySelector('.segment-text');
        const linkEl = item.querySelector('a[href^="/watch"]');
        const text = deepText(textEl);
        if (text && !cachedSegments.find(s => s.element === item)) {
          cachedSegments.push({ text, element: item, link: linkEl });
        }
      }

      scrollContainer.scrollTop += 5000;
      await sleep(300);

      if (scrollContainer.scrollTop === lastScrollTop) unchanged++;
      else unchanged = 0;
      lastScrollTop = scrollContainer.scrollTop;
    }

    scanning = false;
  }

})();
