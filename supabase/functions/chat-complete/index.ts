import "jsr:@supabase/functions-js/edge-runtime.d.ts";

/**
 * chat-complete — Supabase Edge proxy for Hugging Face chat completions.
 * Canonical deploy source for this repo. Contract: supabase/README.md.
 * Deploy: `npx supabase functions deploy chat-complete` (verify_jwt: true in config.toml).
 */

const SCHEMA_VERSION = 1;
const MAX_BODY_BYTES = 512 * 1024;
const HF_CHAT_COMPLETIONS_URL = "https://router.huggingface.co/v1/chat/completions";
const UPSTREAM_TIMEOUT_MS = 120_000;

type ChatMsg = { role: string; content: string };

type ErrorBody = {
  code: string;
  retryable: boolean;
  message: string;
  details?: Record<string, unknown>;
};

function jsonHeaders(): HeadersInit {
  return {
    "Content-Type": "application/json",
    Connection: "keep-alive",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };
}

function errRes(
  status: number,
  body: ErrorBody,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: jsonHeaders(),
  });
}

function okRes(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: jsonHeaders(),
  });
}

function parseAllowedModels(): Set<string> | null {
  const raw = Deno.env.get("HUGGINGFACE_MODEL_ALLOWLIST")?.trim();
  if (!raw) return null;
  return new Set(
    raw.split(",").map((s) => s.trim()).filter((s) => s.length > 0),
  );
}

function resolveEffectiveModel(
  clientModel: string | undefined,
  pinned: string,
  allowlist: Set<string> | null,
): { ok: true; model: string } | { ok: false; message: string } {
  if (clientModel === undefined || clientModel === "") {
    return { ok: true, model: pinned };
  }
  if (allowlist) {
    if (!allowlist.has(clientModel)) {
      return {
        ok: false,
        message: "Client model is not allowlisted for this deployment.",
      };
    }
    return { ok: true, model: clientModel };
  }
  if (clientModel !== pinned) {
    return {
      ok: false,
      message:
        "Client model must match the server pinned model or be omitted unless HUGGINGFACE_MODEL_ALLOWLIST is set.",
    };
  }
  return { ok: true, model: clientModel };
}

function isChatMessageArray(v: unknown): v is ChatMsg[] {
  if (!Array.isArray(v) || v.length === 0) return false;
  for (const item of v) {
    if (!item || typeof item !== "object") return false;
    const m = item as Record<string, unknown>;
    const role = m.role;
    const content = m.content;
    if (typeof role !== "string" || typeof content !== "string") return false;
    if (!role.trim() || !content.length) return false;
    if (!["user", "assistant", "system", "tool"].includes(role)) return false;
  }
  return true;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: jsonHeaders() });
  }

  if (req.method !== "POST") {
    return errRes(405, {
      code: "invalid_request",
      retryable: false,
      message: "Only POST is supported.",
    });
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return errRes(401, {
      code: "auth_required",
      retryable: false,
      message: "Missing or invalid Authorization header.",
    });
  }

  const contentLength = req.headers.get("content-length");
  if (contentLength && Number(contentLength) > MAX_BODY_BYTES) {
    return errRes(413, {
      code: "invalid_request",
      retryable: false,
      message: "Request body too large.",
      details: { maxBytes: MAX_BODY_BYTES },
    });
  }

  let rawBody: unknown;
  try {
    const text = await req.text();
    if (new TextEncoder().encode(text).byteLength > MAX_BODY_BYTES) {
      return errRes(413, {
        code: "invalid_request",
        retryable: false,
        message: "Request body too large.",
      });
    }
    rawBody = text ? JSON.parse(text) : null;
  } catch {
    return errRes(400, {
      code: "invalid_request",
      retryable: false,
      message: "Invalid JSON body.",
    });
  }

  if (!rawBody || typeof rawBody !== "object") {
    return errRes(400, {
      code: "invalid_request",
      retryable: false,
      message: "Request body must be a JSON object.",
    });
  }

  const body = rawBody as Record<string, unknown>;
  const schemaVersion = body.schemaVersion;
  if (schemaVersion !== SCHEMA_VERSION) {
    return errRes(400, {
      code: "invalid_request",
      retryable: false,
      message: `schemaVersion must be ${SCHEMA_VERSION}.`,
      details: { got: schemaVersion },
    });
  }

  if (!isChatMessageArray(body.messages)) {
    return errRes(400, {
      code: "invalid_request",
      retryable: false,
      message:
        "messages must be a non-empty array of { role, content } with allowed roles.",
    });
  }
  const messages = body.messages as ChatMsg[];

  const clientMessageId =
    typeof body.clientMessageId === "string"
      ? body.clientMessageId
      : undefined;
  if (body.clientMessageId !== undefined && clientMessageId === "") {
    return errRes(400, {
      code: "invalid_request",
      retryable: false,
      message: "clientMessageId, when provided, must be a non-empty string.",
    });
  }

  const clientModel =
    typeof body.model === "string" && body.model.trim()
      ? body.model.trim()
      : undefined;

  const hfKey = Deno.env.get("HUGGINGFACE_API_KEY")?.trim() ?? "";
  const pinnedModel = Deno.env.get("HUGGINGFACE_MODEL")?.trim() ?? "";
  if (!hfKey || !pinnedModel) {
    return errRes(500, {
      code: "missing_configuration",
      retryable: false,
      message: "HUGGINGFACE_API_KEY or HUGGINGFACE_MODEL is not configured.",
    });
  }

  const allowlist = parseAllowedModels();
  const resolved = resolveEffectiveModel(clientModel, pinnedModel, allowlist);
  if (!resolved.ok) {
    return errRes(400, {
      code: "invalid_request",
      retryable: false,
      message: resolved.message,
    });
  }
  const effectiveModel = resolved.model;

  const hfPayload = {
    model: effectiveModel,
    messages,
    stream: false,
  };

  let hfResponse: Response;
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), UPSTREAM_TIMEOUT_MS);
  try {
    hfResponse = await fetch(HF_CHAT_COMPLETIONS_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${hfKey}`,
      },
      body: JSON.stringify(hfPayload),
      signal: controller.signal,
    });
  } catch (e) {
    clearTimeout(timeoutId);
    const aborted = e instanceof Error && e.name === "AbortError";
    return errRes(aborted ? 504 : 502, {
      code: aborted ? "upstream_timeout" : "upstream_unavailable",
      retryable: true,
      message: aborted
        ? "Hugging Face request timed out."
        : "Could not reach Hugging Face.",
      details: { clientMessageId },
    });
  }
  clearTimeout(timeoutId);

  const hfText = await hfResponse.text();
  let hfJson: unknown;
  try {
    hfJson = hfText ? JSON.parse(hfText) : null;
  } catch {
    hfJson = null;
  }

  if (hfResponse.status === 401 || hfResponse.status === 403) {
    return errRes(403, {
      code: "forbidden",
      retryable: false,
      message: "Hugging Face rejected the upstream credentials or request.",
      details: { clientMessageId, upstreamStatus: hfResponse.status },
    });
  }

  if (hfResponse.status === 429) {
    return errRes(429, {
      code: "rate_limited",
      retryable: false,
      message: "Rate limited by Hugging Face.",
      details: { clientMessageId },
    });
  }

  if (hfResponse.status >= 500) {
    return errRes(502, {
      code: "upstream_unavailable",
      retryable: true,
      message: "Hugging Face returned a server error.",
      details: {
        clientMessageId,
        upstreamStatus: hfResponse.status,
      },
    });
  }

  if (!hfResponse.ok || !hfJson || typeof hfJson !== "object") {
    return errRes(502, {
      code: "upstream_unavailable",
      retryable: true,
      message: "Unexpected response from Hugging Face.",
      details: {
        clientMessageId,
        upstreamStatus: hfResponse.status,
      },
    });
  }

  const root = hfJson as Record<string, unknown>;
  const choices = root.choices;
  if (!Array.isArray(choices) || choices.length === 0) {
    return errRes(502, {
      code: "upstream_unavailable",
      retryable: true,
      message: "Hugging Face response missing choices.",
      details: { clientMessageId },
    });
  }

  const first = choices[0];
  if (!first || typeof first !== "object") {
    return errRes(502, {
      code: "upstream_unavailable",
      retryable: true,
      message: "Invalid Hugging Face choice shape.",
      details: { clientMessageId },
    });
  }

  const message = (first as Record<string, unknown>).message;
  let content = "";
  if (message && typeof message === "object") {
    const c = (message as Record<string, unknown>).content;
    if (typeof c === "string") {
      content = c;
    } else if (Array.isArray(c)) {
      content = c
        .map((part) => {
          if (part && typeof part === "object") {
            const t = (part as Record<string, unknown>).text;
            if (typeof t === "string") return t;
          }
          return "";
        })
        .join("");
    }
  }

  if (!content.trim()) {
    return errRes(502, {
      code: "upstream_unavailable",
      retryable: true,
      message: "Empty assistant content from Hugging Face.",
      details: { clientMessageId },
    });
  }

  return okRes({
    schemaVersion: SCHEMA_VERSION,
    assistantMessage: {
      role: "assistant",
      content,
    },
    metadata: {
      ...(clientMessageId ? { clientMessageId } : {}),
      model: effectiveModel,
    },
  });
});
