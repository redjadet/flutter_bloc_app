import { spawn } from "node:child_process";

class McpStdioClient {
  constructor(command, args, env) {
    this.proc = spawn(command, args, {
      stdio: ["pipe", "pipe", "pipe"],
      env: { ...process.env, ...(env ?? {}) },
    });
    this.buffer = Buffer.alloc(0);
    this.pending = new Map();
    this.nextId = 1;

    this.proc.stdout.on("data", (chunk) => {
      this.buffer = Buffer.concat([this.buffer, chunk]);
      this.#drain();
    });

    this.proc.stderr.on("data", (chunk) => {
      // eslint-disable-next-line no-console
      console.error(String(chunk));
    });
  }

  #drain() {
    // dart mcp-server uses newline-delimited JSON-RPC.
    while (true) {
      const nl = this.buffer.indexOf("\n");
      if (nl === -1) return;

      const body = this.buffer.subarray(0, nl).toString("utf8").trim();
      this.buffer = this.buffer.subarray(nl + 1);
      if (!body) continue;

      const msg = JSON.parse(body);
      if (typeof msg?.id === "number" && this.pending.has(msg.id)) {
        const { resolve, reject, timeout } = this.pending.get(msg.id);
        clearTimeout(timeout);
        this.pending.delete(msg.id);
        if (msg.error) reject(Object.assign(new Error(msg.error.message ?? "MCP error"), { error: msg.error }));
        else resolve(msg.result);
      }
    }
  }

  request(method, params) {
    const id = this.nextId++;
    const msg = { jsonrpc: "2.0", id, method, params };
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`Timeout waiting for response to ${method}`));
      }, 15_000);
      this.pending.set(id, { resolve, reject, timeout });
      this.send(msg);
    });
  }

  send(msg) {
    this.proc.stdin.write(`${JSON.stringify(msg)}\n`);
  }

  async close() {
    this.proc.stdin.end();
    this.proc.kill("SIGTERM");
  }
}

async function main() {
  const root = `file://${process.cwd()}`;
  const client = new McpStdioClient("dart", ["mcp-server", "--force-roots-fallback"], {
    FLUTTER_SDK: process.env.FLUTTER_SDK ?? "/Users/ilkersevim/Flutter_SDK/flutter",
  });

  try {
    const init = await client.request("initialize", {
      protocolVersion: "2025-11-25",
      capabilities: {},
      clientInfo: { name: "mcp-smoke", version: "0.0.0" },
    });

    // eslint-disable-next-line no-console
    console.log("initialize.ok", {
      protocolVersion: init?.protocolVersion,
      serverInfo: init?.serverInfo,
      capabilities: init?.capabilities ? Object.keys(init.capabilities) : null,
    });

    // MCP servers typically accept "initialized" notification; best-effort.
    client.send({ jsonrpc: "2.0", method: "initialized", params: {} });

    const tools = await client.request("tools/list", {});
    const names = (tools?.tools ?? []).map((t) => t?.name).filter(Boolean);
    if (!names.includes("analyze_files") || !names.includes("hot_reload")) {
      throw new Error(`Expected Dart/Flutter MCP tools missing. Got: ${names.join(", ")}`);
    }
    // eslint-disable-next-line no-console
    console.log("tools.count", names.length);
    // eslint-disable-next-line no-console
    console.log("tools.sample", names.slice(0, 30));

    const roots = await client.request("tools/call", {
      name: "roots",
      arguments: { command: "add", uris: [root] },
    });
    // eslint-disable-next-line no-console
    console.log("roots.add", roots?.content?.[0]?.text ?? roots);
  } finally {
    await client.close();
  }
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exitCode = 1;
});
