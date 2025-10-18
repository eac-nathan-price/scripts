// ==UserScript==
// @name         YouTube Ctrl F
// @namespace    https://youtube.com/
// @version      2.0
// @description  Press Ctrl+Shift+F to search YouTube's transcript and jump to that timestamp.
// @author       eac-nathan-price
// @match        https://www.youtube.com/watch*
// @grant        none
// ==/UserScript==

(function() {
  'use strict';

  let inputBox = null;
  let cachedTranscript = [];
  let scanning = false;

  // Shortcut: Ctrl+Shift+F
  document.addEventListener('keydown', async (e) => {
    if (e.ctrlKey && e.shiftKey && e.key.toLowerCase() === 'f') {
      e.preventDefault();
      toggleInputBox();
    }
  });

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
      width: '300px'
    });

    document.body.appendChild(inputBox);
    inputBox.focus();

    // Fetch transcript
    ensureTranscriptLoaded();

    inputBox.addEventListener('keydown', async (e) => {
      if (e.key === 'Enter') {
        const query = inputBox.value.trim().toLowerCase();
        if (!query) return;

        if (!cachedTranscript.length && !scanning) {
          inputBox.value = 'Loading transcript...';
          inputBox.disabled = true;
          await scanTranscript();
          inputBox.disabled = false;
          inputBox.value = query;
        }

        const match = cachedTranscript.find(item => item.text.toLowerCase().includes(query));
        if (match) {
          match.element.scrollIntoView({ behavior: 'smooth', block: 'center' });
          match.element.click(); // this should click the timestamp link
        } else {
          inputBox.style.borderColor = 'red';
        }
      } else if (e.key === 'Escape') {
        toggleInputBox();
      }
    });
  }

  async function ensureTranscriptLoaded() {
    // Open transcript if not visible
    if (document.querySelector('ytd-transcript-renderer')) return;

    // Open "..." menu under description
    const menuButton = document.querySelector('#primary-inner ytd-video-description-transcript-section-renderer tp-yt-paper-button, #primary-inner ytd-video-description #expand');
    if (menuButton) menuButton.click();

    // Wait and look for “Show transcript” button
    let showButton;
    for (let i = 0; i < 20; i++) {
      showButton = [...document.querySelectorAll('button, yt-button-shape')].find(el => el.textContent.toLowerCase().includes('transcript'));
      if (showButton) break;
      await sleep(500);
    }

    if (showButton) {
      showButton.click();
      await sleep(2000);
    }
  }

  async function scanTranscript() {
    scanning = true;
    cachedTranscript = [];
    const container = document.querySelector('ytd-transcript-renderer #segments-container');
    if (!container) {
      scanning = false;
      return;
    }

    const scrollContainer = container.parentElement;
    let lastScrollTop = -1;
    let unchanged = 0;

    while (unchanged < 3) {
      const items = [...container.querySelectorAll('ytd-transcript-segment-renderer')];
      for (const item of items) {
        const textEl = item.querySelector('#segment-text');
        const timeEl = item.querySelector('a[href^="/watch"]');
        if (textEl && !cachedTranscript.find(x => x.element === timeEl)) {
          cachedTranscript.push({
            text: textEl.textContent.trim(),
            element: timeEl
          });
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

  function sleep(ms) {
    return new Promise(res => setTimeout(res, ms));
  }
})();
