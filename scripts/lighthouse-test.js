#!/usr/bin/env node

const lighthouse = require('lighthouse');
const chromeLauncher = require('chrome-launcher');
const fs = require('fs');
const path = require('path');

// Configuration
const config = {
  extends: 'lighthouse:default',
  settings: {
    onlyAudits: [
      'first-contentful-paint',
      'largest-contentful-paint',
      'first-meaningful-paint',
      'speed-index',
      'total-blocking-time',
      'cumulative-layout-shift',
      'server-response-time',
      'render-blocking-resources',
      'unused-css-rules',
      'unused-javascript',
      'modern-image-formats',
      'uses-optimized-images',
      'uses-text-compression',
      'uses-responsive-images',
      'efficient-animated-content',
      'preload-lcp-image',
      'prioritize-lcp-image'
    ]
  }
};

// URLs to test
const urls = [
  { name: 'Homepage', url: 'http://localhost:5500/' },
  { name: 'Products', url: 'http://localhost:5500/products.html' },
  { name: 'About', url: 'http://localhost:5500/about.html' },
  { name: 'Contact', url: 'http://localhost:5500/contact.html' }
];

async function runLighthouse() {
  console.log('🚀 Starting FreshThreads Lighthouse Performance Test...\n');

  const chrome = await chromeLauncher.launch({
    chromeFlags: ['--headless', '--disable-gpu', '--no-sandbox']
  });

  const results = [];

  for (const { name, url } of urls) {
    console.log(`📊 Testing ${name} (${url})...`);

    try {
      const runnerResult = await lighthouse(url, {
        port: chrome.port,
        logLevel: 'error',
        output: 'json'
      }, config);

      const { lhr } = runnerResult;
      const scores = lhr.categories;

      // Extract performance metrics
      const metrics = {
        name,
        url,
        performance: Math.round(scores.performance.score * 100),
        accessibility: Math.round(scores.accessibility.score * 100),
        bestPractices: Math.round(scores['best-practices'].score * 100),
        seo: Math.round(scores.seo.score * 100),
        pwa: Math.round(scores.pwa.score * 100),
        fcp: lhr.audits['first-contentful-paint'].displayValue,
        lcp: lhr.audits['largest-contentful-paint'].displayValue,
        tbt: lhr.audits['total-blocking-time'].displayValue,
        cls: lhr.audits['cumulative-layout-shift'].displayValue,
        speedIndex: lhr.audits['speed-index'].displayValue
      };

      results.push(metrics);

      // Console output
      console.log(`✅ ${name} Results:`);
      console.log(`   Performance: ${metrics.performance}/100`);
      console.log(`   Accessibility: ${metrics.accessibility}/100`);
      console.log(`   Best Practices: ${metrics.bestPractices}/100`);
      console.log(`   SEO: ${metrics.seo}/100`);
      console.log(`   PWA: ${metrics.pwa}/100`);
      console.log(`   FCP: ${metrics.fcp}`);
      console.log(`   LCP: ${metrics.lcp}`);
      console.log(`   TBT: ${metrics.tbt}`);
      console.log(`   CLS: ${metrics.cls}\n`);

    } catch (error) {
      console.error(`❌ Error testing ${name}:`, error.message);
    }
  }

  await chrome.kill();

  // Generate detailed report
  generateReport(results);

  // Check if all tests passed
  const performanceThreshold = 90;
  const failedTests = results.filter(result => result.performance < performanceThreshold);

  if (failedTests.length > 0) {
    console.log(`❌ Performance tests failed for: ${failedTests.map(t => t.name).join(', ')}`);
    console.log(`   Minimum score required: ${performanceThreshold}/100`);
    process.exit(1);
  } else {
    console.log('✅ All performance tests passed!');
    process.exit(0);
  }
}

function generateReport(results) {
  const timestamp = new Date().toISOString();
  const reportDir = path.join(__dirname, '../lighthouse-reports');

  if (!fs.existsSync(reportDir)) {
    fs.mkdirSync(reportDir, { recursive: true });
  }

  // JSON Report
  const jsonReport = {
    timestamp,
    results,
    summary: {
      averagePerformance: Math.round(results.reduce((sum, r) => sum + r.performance, 0) / results.length),
      averageAccessibility: Math.round(results.reduce((sum, r) => sum + r.accessibility, 0) / results.length),
      averageBestPractices: Math.round(results.reduce((sum, r) => sum + r.bestPractices, 0) / results.length),
      averageSEO: Math.round(results.reduce((sum, r) => sum + r.seo, 0) / results.length),
      averagePWA: Math.round(results.reduce((sum, r) => sum + r.pwa, 0) / results.length)
    }
  };

  const jsonPath = path.join(reportDir, `lighthouse-${Date.now()}.json`);
  fs.writeFileSync(jsonPath, JSON.stringify(jsonReport, null, 2));

  // HTML Report
  const htmlReport = generateHTMLReport(jsonReport);
  const htmlPath = path.join(reportDir, `lighthouse-${Date.now()}.html`);
  fs.writeFileSync(htmlPath, htmlReport);

  console.log(`📝 Reports generated:`);
  console.log(`   JSON: ${jsonPath}`);
  console.log(`   HTML: ${htmlPath}\n`);
}

function generateHTMLReport(data) {
  return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshThreads Lighthouse Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 20px; }
        .header { background: #0070f3; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 30px; }
        .metric { background: #f8f9fa; padding: 15px; border-radius: 8px; text-align: center; }
        .metric-value { font-size: 2em; font-weight: bold; color: #0070f3; }
        .results { margin-top: 20px; }
        .result-card { background: white; border: 1px solid #e1e5e9; border-radius: 8px; padding: 20px; margin-bottom: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .score { display: inline-block; padding: 4px 8px; border-radius: 4px; color: white; font-weight: bold; }
        .score.good { background: #0cce6b; }
        .score.average { background: #ffa400; }
        .score.poor { background: #ff4e42; }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin-top: 15px; }
        .metric-item { background: #f8f9fa; padding: 10px; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 FreshThreads Lighthouse Performance Report</h1>
        <p>Generated: ${data.timestamp}</p>
    </div>

    <div class="summary">
        <div class="metric">
            <div class="metric-value">${data.summary.averagePerformance}</div>
            <div>Average Performance</div>
        </div>
        <div class="metric">
            <div class="metric-value">${data.summary.averageAccessibility}</div>
            <div>Average Accessibility</div>
        </div>
        <div class="metric">
            <div class="metric-value">${data.summary.averageBestPractices}</div>
            <div>Average Best Practices</div>
        </div>
        <div class="metric">
            <div class="metric-value">${data.summary.averageSEO}</div>
            <div>Average SEO</div>
        </div>
        <div class="metric">
            <div class="metric-value">${data.summary.averagePWA}</div>
            <div>Average PWA</div>
        </div>
    </div>

    <div class="results">
        ${data.results.map(result => `
            <div class="result-card">
                <h3>${result.name} - ${result.url}</h3>
                <div style="margin: 15px 0;">
                    <span class="score ${getScoreClass(result.performance)}">Performance: ${result.performance}</span>
                    <span class="score ${getScoreClass(result.accessibility)}">Accessibility: ${result.accessibility}</span>
                    <span class="score ${getScoreClass(result.bestPractices)}">Best Practices: ${result.bestPractices}</span>
                    <span class="score ${getScoreClass(result.seo)}">SEO: ${result.seo}</span>
                    <span class="score ${getScoreClass(result.pwa)}">PWA: ${result.pwa}</span>
                </div>
                <div class="metrics-grid">
                    <div class="metric-item"><strong>FCP:</strong> ${result.fcp}</div>
                    <div class="metric-item"><strong>LCP:</strong> ${result.lcp}</div>
                    <div class="metric-item"><strong>TBT:</strong> ${result.tbt}</div>
                    <div class="metric-item"><strong>CLS:</strong> ${result.cls}</div>
                    <div class="metric-item"><strong>Speed Index:</strong> ${result.speedIndex}</div>
                </div>
            </div>
        `).join('')}
    </div>
</body>
</html>`;
}

function getScoreClass(score) {
  if (score >= 90) return 'good';
  if (score >= 50) return 'average';
  return 'poor';
}

// Run the lighthouse tests
runLighthouse().catch(console.error);
