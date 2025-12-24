const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware to log requests
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    version: '1.0',
    environment: 'blue',
    timestamp: new Date().toISOString()
  });
});

// Main route
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Version 1.0 - Blue Environment</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 0;
          padding: 0;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
          background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        }
        .container {
          text-align: center;
          background: white;
          padding: 60px 80px;
          border-radius: 20px;
          box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          max-width: 600px;
        }
        h1 {
          color: #1e3c72;
          font-size: 2.5em;
          margin-bottom: 20px;
        }
        .version {
          color: #2a5298;
          font-size: 3em;
          font-weight: bold;
          margin: 20px 0;
        }
        .environment {
          background: #1e3c72;
          color: white;
          padding: 15px 30px;
          border-radius: 50px;
          display: inline-block;
          font-size: 1.2em;
          margin: 20px 0;
        }
        .info {
          color: #666;
          margin-top: 30px;
          line-height: 1.8;
        }
        .badge {
          display: inline-block;
          background: #4CAF50;
          color: white;
          padding: 5px 15px;
          border-radius: 20px;
          font-size: 0.9em;
          margin: 10px 5px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🚀 Welcome to the Blue-Green Deployment Demo</h1>
        <div class="version">Version 1.0</div>
        <div class="environment">🔵 BLUE ENVIRONMENT</div>
        <div class="info">
          <p><strong>Status:</strong> <span class="badge">PRODUCTION</span></p>
          <p>This is the current production environment running the stable Version 1.0 of the application.</p>
          <p><strong>Server Time:</strong> ${new Date().toISOString()}</p>
          <p><strong>Hostname:</strong> ${require('os').hostname()}</p>
        </div>
      </div>
    </body>
    </html>
  `);
});

// API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    version: '1.0',
    environment: 'blue',
    status: 'production',
    timestamp: new Date().toISOString(),
    hostname: require('os').hostname(),
    platform: process.platform,
    nodeVersion: process.version
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Application v1.0 (Blue Environment) is running on port ${PORT}`);
  console.log(`🌐 Server started at ${new Date().toISOString()}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});