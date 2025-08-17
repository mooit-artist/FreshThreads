#!/usr/bin/env node

/**
 * FreshThreads Aikido Security Demo
 * This script demonstrates Aikido runtime security protection
 */

// Import Aikido firewall first (before any other imports)
require("@aikidosec/firewall");

const http = require("http");
const url = require("url");

console.log("🛡️ FreshThreads Aikido Security Demo Starting...");
console.log("🔒 Aikido Runtime Protection: ACTIVE");

// Create a simple HTTP server for demonstration
const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;

  // Set CORS headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Content-Type", "application/json");

  console.log(`📥 Request: ${req.method} ${path}`);

  if (path === "/") {
    // Home endpoint
    res.writeHead(200);
    res.end(
      JSON.stringify(
        {
          message: "FreshThreads Security Demo",
          aikido_protection: "active",
          timestamp: new Date().toISOString(),
          endpoints: [
            "GET /",
            "GET /health",
            "GET /security-test",
            "POST /vulnerable-endpoint",
          ],
        },
        null,
        2,
      ),
    );
  } else if (path === "/health") {
    // Health check endpoint
    res.writeHead(200);
    res.end(
      JSON.stringify({
        status: "healthy",
        aikido: "protected",
        timestamp: new Date().toISOString(),
      }),
    );
  } else if (path === "/security-test") {
    // Demonstrate Aikido's protection capabilities
    const query = parsedUrl.query;

    res.writeHead(200);
    res.end(
      JSON.stringify(
        {
          message: "Security test endpoint",
          note: "Try malicious payloads - Aikido will block them!",
          examples: [
            '/security-test?input=<script>alert("xss")</script>',
            "/security-test?input='; DROP TABLE users; --",
            "/security-test?file=../../../etc/passwd",
          ],
          received_query: query,
          aikido_status: "monitoring",
        },
        null,
        2,
      ),
    );
  } else if (path === "/vulnerable-endpoint" && req.method === "POST") {
    // Simulated vulnerable endpoint (Aikido will protect this)
    let body = "";

    req.on("data", (chunk) => {
      body += chunk.toString();
    });

    req.on("end", () => {
      try {
        const data = JSON.parse(body);

        // This would normally be vulnerable to injection attacks
        // But Aikido will detect and block malicious payloads
        console.log("📝 Received data:", data);

        res.writeHead(200);
        res.end(
          JSON.stringify({
            message: "Data processed safely",
            received: data,
            protection: "Aikido firewall active",
            timestamp: new Date().toISOString(),
          }),
        );
      } catch (error) {
        res.writeHead(400);
        res.end(
          JSON.stringify({
            error: "Invalid JSON",
            message: error.message,
          }),
        );
      }
    });
  } else {
    // 404 for unknown endpoints
    res.writeHead(404);
    res.end(
      JSON.stringify({
        error: "Not Found",
        path: path,
        message: "Endpoint not found",
      }),
    );
  }
});

// Start the server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log("🛡️ Protected by Aikido Runtime Security");
  console.log("");
  console.log("📋 Test endpoints:");
  console.log(`   GET  http://localhost:${PORT}/`);
  console.log(`   GET  http://localhost:${PORT}/health`);
  console.log(`   GET  http://localhost:${PORT}/security-test`);
  console.log(`   POST http://localhost:${PORT}/vulnerable-endpoint`);
  console.log("");
  console.log("🧪 Try these security test URLs:");
  console.log(
    `   http://localhost:${PORT}/security-test?input=<script>alert("xss")</script>`,
  );
  console.log(
    `   http://localhost:${PORT}/security-test?input='; DROP TABLE users; --`,
  );
  console.log(
    `   http://localhost:${PORT}/security-test?file=../../../etc/passwd`,
  );
  console.log("");
  console.log("Press Ctrl+C to stop the server");
});

// Graceful shutdown
process.on("SIGINT", () => {
  console.log("\n🛑 Shutting down server...");
  server.close(() => {
    console.log("✅ Server stopped");
    process.exit(0);
  });
});

// Error handling
process.on("uncaughtException", (error) => {
  console.error("💥 Uncaught Exception:", error);
  process.exit(1);
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("💥 Unhandled Rejection at:", promise, "reason:", reason);
  process.exit(1);
});
