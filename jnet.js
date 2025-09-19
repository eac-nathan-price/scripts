// ==UserScript==
// @name         JNet Document Downloader
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Download all documents from JNet
// @author       You
// @match        https://your-jnet-site.com/*
// @require      https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js
// @grant        none
// ==/UserScript==

// Detect environment
const isTampermonkey = typeof GM_info !== 'undefined' && GM_info.script;
const isConsole = !isTampermonkey;

// Load JSZip only if not in Tampermonkey (where it's loaded via @require)
async function loadJSZip() {
  if (isTampermonkey) return; // JSZip loaded via @require in Tampermonkey
  
  if (typeof JSZip === "undefined") {
    await new Promise((resolve, reject) => {
      const s = document.createElement("script");
      s.src = "https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js";
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }
}

// Main execution function
async function main() {
  await loadJSZip();

  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const sanitize = s => s.replace(/[\/\\:*?"<>|]/g, "-").replace(/\s+/g, " ").trim();
  const toYMD = s => {
    const m = String(s).match(/(\d{1,2})\/(\d{1,2})\/(\d{2,4})/);
    if (!m) return sanitize(s);
    let [, mm, dd, yy] = m;
    yy = yy.length === 2 ? "20" + yy : yy;
    return `${yy}-${mm.padStart(2,"0")}-${dd.padStart(2,"0")}`;
  };

  // Case info for zip filename
  const caseNum = document.querySelector("#ContentPlaceHolder1_lblCaseNumber")?.innerText.trim() || "CASE";
  const first = document.querySelector("#ContentPlaceHolder1_lblFirstName")?.innerText.trim() || "FIRST";
  const last = document.querySelector("#ContentPlaceHolder1_lblLastName")?.innerText.trim() || "LAST";
  const zipFileName = `${caseNum}-${last}-${first}.zip`;

  const seenIds = new Set();
  const seenNames = Object.create(null);
  const zip = new JSZip();
  let successCount = 0;
  let failCount = 0;

  async function processPage() {
    const rows = Array.from(document.querySelectorAll('#ContentPlaceHolder1_gvDocs tr'));

    for (const row of rows) {
      const link = row.querySelector('a[id^="ContentPlaceHolder1_gvDocs_btnSelectDoc"]');
      const cols = row.querySelectorAll('td');
      if (!link || cols.length < 3) continue;

      const m = (link.getAttribute('onclick') || '').match(/DocViewer\.aspx\?id=(\d+)/);
      if (!m) continue;

      const id = m[1];
      if (seenIds.has(id)) continue; // skip duplicates
      seenIds.add(id);

      const url = new URL(`/access/DocViewer.aspx?id=${id}`, location.origin).href;

      const desc = sanitize(cols[1].innerText);
      const ymd = toYMD(cols[2].innerText);

      const base = `${ymd} ${desc}`;
      const n = (seenNames[base] = (seenNames[base] || 0) + 1);
      
      // Handle PDF extension properly
      let fileName;
      if (base.toLowerCase().endsWith('.pdf')) {
        // Already has .pdf extension, just ensure it's lowercase
        fileName = n > 1 ? `${base} (${n})` : base;
        if (fileName.endsWith('.PDF')) {
          fileName = fileName.slice(0, -4) + '.pdf';
        }
      } else {
        // No PDF extension, add it
        fileName = n > 1 ? `${base} (${n}).pdf` : `${base}.pdf`;
      }

      await sleep(400);

      try {
        const res = await fetch(url, { credentials: "include" });
        if (!res.ok) {
          console.warn("❌ Failed:", id, res.status);
          failCount++;
          continue;
        }
        const blob = await res.blob();
        const arrayBuffer = await blob.arrayBuffer();
        zip.file(fileName, arrayBuffer);
        console.log("✅ Added to zip:", fileName);
        successCount++;
      } catch (err) {
        console.error("❌ Error fetching", id, err);
        failCount++;
      }
    }
  }

  async function goToFirstPage() {
    const firstBtn = document.querySelector("#ContentPlaceHolder1_gvDocs_first");
    if (!firstBtn || firstBtn.classList.contains("disabled")) {
      console.log("Already on first page or no first button found");
      return;
    }

    console.log("Navigating to first page...");
    
    // Remember current first row id before clicking first
    const currentFirstId = (document.querySelector('#ContentPlaceHolder1_gvDocs tr a[id^="ContentPlaceHolder1_gvDocs_btnSelectDoc"]')?.getAttribute("onclick") || "").match(/id=(\d+)/)?.[1];

    firstBtn.click();
    await sleep(500);

    // Wait until the page actually changes (or retry a few times)
    let tries = 0;
    while (tries < 10) {
      const newFirstId = (document.querySelector('#ContentPlaceHolder1_gvDocs tr a[id^="ContentPlaceHolder1_gvDocs_btnSelectDoc"]')?.getAttribute("onclick") || "").match(/id=(\d+)/)?.[1];
      if (newFirstId && newFirstId !== currentFirstId) break;
      await sleep(500);
      tries++;
    }
    
    console.log("Now on first page");
  }

  async function goThroughPages() {
    // First, ensure we start from page 1
    await goToFirstPage();
    
    while (true) {
      await processPage();

      const nextBtn = document.querySelector("#ContentPlaceHolder1_gvDocs_next");
      if (!nextBtn || nextBtn.classList.contains("disabled")) break;

      // Remember current first row id before clicking next
      const currentFirstId = (document.querySelector('#ContentPlaceHolder1_gvDocs tr a[id^="ContentPlaceHolder1_gvDocs_btnSelectDoc"]')?.getAttribute("onclick") || "").match(/id=(\d+)/)?.[1];

      nextBtn.click();
      await sleep(500);

      // Wait until the page actually changes (or retry a few times)
      let tries = 0;
      while (tries < 10) {
        const newFirstId = (document.querySelector('#ContentPlaceHolder1_gvDocs tr a[id^="ContentPlaceHolder1_gvDocs_btnSelectDoc"]')?.getAttribute("onclick") || "").match(/id=(\d+)/)?.[1];
        if (newFirstId && newFirstId !== currentFirstId) break;
        await sleep(500);
        tries++;
      }
    }
  }

  await goThroughPages();

  // Generate the zip and trigger download
  zip.generateAsync({ type: "blob" }).then(content => {
    const a = document.createElement("a");
    a.href = URL.createObjectURL(content);
    a.download = zipFileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    console.log(`🎉 Done! ${successCount} files succeeded, ${failCount} failed. Saved as ${zipFileName}`);
  });
}

// Execute based on environment
if (isConsole) {
  // Console usage: wrap in async function and execute immediately
  (async function() {
    await main();
  })();
} else {
  // Tampermonkey usage: just call main() directly
  main();
}
