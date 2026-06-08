#!/usr/bin/env node
/**
 * Read Flutter/Dart runtime errors via `dart mcp-server` (DTD + get_runtime_errors).
 *
 * Exit codes:
 *   0 — no runtime errors, or no controllable session (unless --strict)
 *   1 — runtime errors present, or --strict with no session/app
 *   2 — MCP / tooling failure
 *
 * Usage:
 *   node script/mcp_runtime_errors.js [--strict] [--clear] [--json] [--repo-root PATH] [--self-test]
 */

import { spawn } from 'node:child_process';
import { realpathSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DEFAULT_REPO_ROOT = resolve(__dirname, '..');

const NO_SESSION_PATTERNS = [
  /no active debug session/i,
  /no connected apps/i,
  /no apps currently connected/i,
  /no dtd uris found/i,
  /no dtd instances found/i,
];

const NO_ERRORS_PATTERNS = [
  /no runtime errors/i,
  /no errors found/i,
  /0 runtime errors/i,
];

function parseArgs(argv) {
  const opts = {
    strict: false,
    clear: false,
    json: false,
    selfTest: false,
    repoRoot: process.env.REPO_ROOT ?? DEFAULT_REPO_ROOT,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case '--strict':
        opts.strict = true;
        break;
      case '--clear':
        opts.clear = true;
        break;
      case '--json':
        opts.json = true;
        break;
      case '--self-test':
        opts.selfTest = true;
        break;
      case '--repo-root':
        i += 1;
        opts.repoRoot = resolve(argv[i] ?? '');
        break;
      case '-h':
      case '--help':
        printHelp();
        process.exit(0);
        break;
      default:
        console.error(`Unknown argument: ${arg}`);
        printHelp();
        process.exit(2);
    }
  }
  return opts;
}

function printHelp() {
  console.log(`Usage: node script/mcp_runtime_errors.js [options]

Options:
  --strict       Fail when DTD or a connected debug app is unavailable
  --clear        Pass clearRuntimeErrors: true to get_runtime_errors
  --json         Print a JSON summary on stdout
  --repo-root    Prefer DTD whose working directory matches this path
  --self-test    Verify dart mcp-server + DTD list/connect only (always exit 0)
  -h, --help     Show this help
`);
}

class McpStdioClient {
  constructor() {
    this.proc = spawn('dart', ['mcp-server', '--force-roots-fallback'], {
      stdio: ['pipe', 'pipe', 'pipe'],
      env: process.env,
    });
    this.buf = Buffer.alloc(0);
    this.pending = new Map();
    this.nextId = 1;
    this.proc.stdout.on('data', (chunk) => {
      this.buf = Buffer.concat([this.buf, chunk]);
      this.#drain();
    });
    this.proc.on('exit', (code, signal) => {
      for (const [, handlers] of this.pending) {
        handlers.reject(
          new Error(`dart mcp-server exited (code=${code ?? 'null'}, signal=${signal ?? 'null'})`),
        );
      }
      this.pending.clear();
    });
  }

  #drain() {
    while (true) {
      const nl = this.buf.indexOf('\n');
      if (nl === -1) return;
      const line = this.buf.subarray(0, nl).toString('utf8').trim();
      this.buf = this.buf.subarray(nl + 1);
      if (!line) continue;
      let msg;
      try {
        msg = JSON.parse(line);
      } catch {
        continue;
      }
      if (typeof msg?.id !== 'number' || !this.pending.has(msg.id)) continue;
      const { resolve, reject } = this.pending.get(msg.id);
      this.pending.delete(msg.id);
      if (msg.error) reject(msg.error);
      else resolve(msg.result);
    }
  }

  request(method, params) {
    const id = this.nextId++;
    return new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
      this.proc.stdin.write(`${JSON.stringify({ jsonrpc: '2.0', id, method, params })}\n`);
    });
  }

  callTool(name, args) {
    return this.request('tools/call', { name, arguments: args });
  }

  close() {
    try {
      this.proc.stdin.end();
    } catch {
      /* ignore */
    }
    this.proc.kill();
  }
}

function toolText(result) {
  if (!result) return '';
  if (Array.isArray(result.content)) {
    return result.content.map((c) => c.text ?? '').join('');
  }
  return typeof result === 'string' ? result : JSON.stringify(result);
}

function toolIsError(result) {
  return result?.isError === true;
}

function extractWsUris(text) {
  return [...text.matchAll(/ws:\/\/[^\s`'"]+/g)].map((m) => m[0]);
}

function pickDtdUri(listText, repoRoot) {
  const uris = extractWsUris(listText);
  if (uris.length === 0) return null;
  const normalizedRoot = realpathSync(repoRoot);
  const lines = listText.split('\n');
  for (const uri of uris) {
    const idx = listText.indexOf(uri);
    const window = listText.slice(Math.max(0, idx - 200), idx + 400);
    if (window.includes(normalizedRoot)) return uri;
  }
  for (const line of lines) {
    if (!line.includes('ws://')) continue;
    const uri = line.match(/ws:\/\/[^\s`'"]+/)?.[0];
    if (!uri) continue;
    if (line.includes(normalizedRoot)) return uri;
  }
  return uris[0];
}

function extractAppUris(appsText) {
  const uris = new Set();
  for (const m of appsText.matchAll(/vm-service:\/\/[^\s`'"]+/g)) {
    uris.add(m[0]);
  }
  for (const m of appsText.matchAll(/http:\/\/127\.0\.0\.1:\d+\/[^\s`'"]+/g)) {
    uris.add(m[0]);
  }
  return [...uris];
}

function isNoSessionMessage(text) {
  const trimmed = text.trim();
  if (!trimmed) return true;
  return NO_SESSION_PATTERNS.some((re) => re.test(trimmed));
}

function hasRuntimeErrors(text) {
  const trimmed = text.trim();
  if (!trimmed) return false;
  if (isNoSessionMessage(trimmed)) return false;
  if (NO_ERRORS_PATTERNS.some((re) => re.test(trimmed))) return false;
  if (/^#+\s+\d+\s/m.test(trimmed)) return true;
  if (/\b(Exception|Error|AssertionError|Stack trace|RenderFlex|overflowed)\b/.test(trimmed)) {
    return true;
  }
  return trimmed.length > 0;
}

function emitJson(payload) {
  console.log(JSON.stringify(payload, null, 2));
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  const client = new McpStdioClient();

  const finish = (code, payload) => {
    if (opts.json && payload) emitJson(payload);
    client.close();
    process.exit(code);
  };

  try {
    await client.request('initialize', {
      protocolVersion: '2025-11-25',
      capabilities: {},
      clientInfo: { name: 'mcp_runtime_errors', version: '1.0.0' },
    });
    client.proc.stdin.write(`${JSON.stringify({ jsonrpc: '2.0', method: 'initialized', params: {} })}\n`);

    const dtdListResult = await client.callTool('dtd', { command: 'listDtdUris' });
    const dtdListText = toolText(dtdListResult);
    const dtdUri = pickDtdUri(dtdListText, opts.repoRoot);

    if (!dtdUri) {
      const payload = {
        status: 'skipped',
        reason: 'no_dtd',
        strict: opts.strict,
        dtdList: dtdListText.trim(),
      };
      if (opts.selfTest) {
        console.log('self-test: dart mcp-server reachable; no DTD instances (ok).');
        return finish(0, payload);
      }
      if (!opts.json) {
        console.log('⏭️  No DTD instances found — skipping runtime error check.');
      }
      return finish(opts.strict ? 1 : 0, payload);
    }

    const connectResult = await client.callTool('dtd', { command: 'connect', uri: dtdUri });
    const connectText = toolText(connectResult);
    if (toolIsError(connectResult)) {
      const payload = { status: 'error', reason: 'dtd_connect_failed', message: connectText };
      if (!opts.json) console.error(`❌ DTD connect failed: ${connectText}`);
      return finish(2, payload);
    }

    if (opts.selfTest) {
      console.log(`self-test: connected to ${dtdUri}`);
      console.log(connectText.trim());
      return finish(0, { status: 'ok', selfTest: true, dtdUri, connect: connectText.trim() });
    }

    const appsResult = await client.callTool('dtd', { command: 'listConnectedApps' });
    const appsText = toolText(appsResult);
    const appUris = extractAppUris(appsText);
    const hasApps = appUris.length > 0 || !/no connected apps/i.test(appsText);

    if (!hasApps || /no connected apps found/i.test(appsText)) {
      const payload = {
        status: 'skipped',
        reason: 'no_connected_app',
        strict: opts.strict,
        dtdUri,
        apps: appsText.trim(),
      };
      if (!opts.json) {
        if (opts.strict) {
          console.error('❌ --strict: DTD connected but no debug app.');
        } else {
          console.log('⏭️  DTD connected but no debug app — skipping runtime error check.');
        }
        console.log(appsText.trim());
      }
      return finish(opts.strict ? 1 : 0, payload);
    }

    const errorArgs = {};
    if (opts.clear) errorArgs.clearRuntimeErrors = true;
    if (appUris.length === 1) errorArgs.appUri = appUris[0];

    const errorsResult = await client.callTool('get_runtime_errors', errorArgs);
    const errorsText = toolText(errorsResult);

    if (toolIsError(errorsResult)) {
      const payload = { status: 'error', reason: 'get_runtime_errors_failed', message: errorsText };
      if (!opts.json) console.error(`❌ get_runtime_errors failed: ${errorsText}`);
      return finish(2, payload);
    }

    if (isNoSessionMessage(errorsText)) {
      const payload = {
        status: 'skipped',
        reason: 'no_active_debug_session',
        strict: opts.strict,
        dtdUri,
        apps: appsText.trim(),
        errors: errorsText.trim(),
      };
      if (!opts.json) {
        console.log('⏭️  No active debug session for runtime errors.');
        console.log(errorsText.trim());
      }
      return finish(opts.strict ? 1 : 0, payload);
    }

    if (!hasRuntimeErrors(errorsText)) {
      const payload = {
        status: 'ok',
        reason: 'no_runtime_errors',
        dtdUri,
        appUris,
        errors: errorsText.trim(),
      };
      if (!opts.json) {
        console.log('✅ No runtime errors reported.');
        if (errorsText.trim()) console.log(errorsText.trim());
      }
      return finish(0, payload);
    }

    const payload = {
      status: 'failed',
      reason: 'runtime_errors_present',
      dtdUri,
      appUris,
      errors: errorsText.trim(),
    };
    if (!opts.json) {
      console.error('❌ Runtime errors reported by VM:');
      console.error(errorsText.trim());
    }
    return finish(1, payload);
  } catch (err) {
    const message = err?.message ?? String(err);
    if (!opts.json) console.error(`❌ MCP runtime error check failed: ${message}`);
    return finish(2, { status: 'error', reason: 'mcp_failure', message });
  }
}

main();
