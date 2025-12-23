const server = Bun.serve({
  routes: {
    "/healthz": new Response("OK"),
    "/readyz": new Response("OK"),
  },
  fetch(_req, _server) {
    return new Response("Hello World!");
  },
  port: process.env["PORT"] || 3000,
});

console.log(`hello world server: http://127.0.0.1:${server.port}`);
process.on(
  "SIGINT",
  () => void server.stop().catch(() => process.exit(1)).finally(() => process.exit(0)),
);
