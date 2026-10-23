//! Demo-only JSON-RPC agent engine over stdio (newline-delimited).
//!
//! This process is the fault-isolation boundary for untrusted agent work.
//! Flutter must not execute agent commands in-process.

use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::io::{self, Write};
use std::process;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::sync::mpsc;
use tokio::time::{sleep, Duration};

const ENGINE_NAME: &str = "rust-agent-engine";
const ENGINE_VERSION: &str = "0.1.0";

#[derive(Debug, Deserialize)]
struct RpcRequest {
    jsonrpc: String,
    id: Option<Value>,
    method: String,
    #[serde(default)]
    params: Value,
}

#[derive(Debug, Serialize)]
struct RpcResponse {
    jsonrpc: &'static str,
    id: Value,
    #[serde(skip_serializing_if = "Option::is_none")]
    result: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<RpcError>,
}

#[derive(Debug, Serialize)]
struct RpcError {
    code: i64,
    message: String,
}

#[derive(Debug, Serialize)]
struct RpcNotification {
    jsonrpc: &'static str,
    method: &'static str,
    params: Value,
}

#[tokio::main]
async fn main() {
    let stdin = BufReader::new(tokio::io::stdin());
    let mut lines = stdin.lines();
    let (tx, mut rx) = mpsc::unbounded_channel::<String>();

    // Single writer task keeps stdout line-oriented and ordered.
    tokio::spawn(async move {
        let mut stdout = io::stdout();
        while let Some(line) = rx.recv().await {
            let _ = writeln!(stdout, "{line}");
            let _ = stdout.flush();
        }
    });

    eprintln!(
        "agent_engine ready name={ENGINE_NAME} version={ENGINE_VERSION} pid={}",
        process::id()
    );

    while let Ok(Some(line)) = lines.next_line().await {
        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }
        let request: RpcRequest = match serde_json::from_str(trimmed) {
            Ok(r) => r,
            Err(err) => {
                let response = RpcResponse {
                    jsonrpc: "2.0",
                    id: Value::Null,
                    result: None,
                    error: Some(RpcError {
                        code: -32700,
                        message: format!("parse error: {err}"),
                    }),
                };
                let _ = tx.send(serde_json::to_string(&response).unwrap_or_default());
                continue;
            }
        };

        if request.jsonrpc != "2.0" {
            respond_error(&tx, request.id, -32600, "invalid jsonrpc version");
            continue;
        }

        match request.method.as_str() {
            "ping" => {
                let result = json!({
                    "ok": true,
                    "engine": ENGINE_NAME,
                    "version": ENGINE_VERSION,
                    "pid": process::id(),
                });
                respond_ok(&tx, request.id, result);
            }
            "agent/streamDemo" => {
                let id = request.id.clone();
                let count = request
                    .params
                    .get("count")
                    .and_then(Value::as_u64)
                    .unwrap_or(3)
                    .clamp(1, 8) as usize;
                let tx_events = tx.clone();
                tokio::spawn(async move {
                    for i in 1..=count {
                        let note = RpcNotification {
                            jsonrpc: "2.0",
                            method: "agent/event",
                            params: json!({
                                "type": "progress",
                                "index": i,
                                "total": count,
                                "message": format!("engine tick {i}/{count}"),
                            }),
                        };
                        let _ = tx_events.send(serde_json::to_string(&note).unwrap_or_default());
                        sleep(Duration::from_millis(40)).await;
                    }
                    respond_ok(
                        &tx_events,
                        id,
                        json!({
                            "streamed": count,
                            "engine": ENGINE_NAME,
                        }),
                    );
                });
            }
            "shutdown" => {
                respond_ok(&tx, request.id, json!({ "shuttingDown": true }));
                break;
            }
            _ => respond_error(
                &tx,
                request.id,
                -32601,
                &format!("method not found: {}", request.method),
            ),
        }
    }
}

fn respond_ok(tx: &mpsc::UnboundedSender<String>, id: Option<Value>, result: Value) {
    let Some(id) = id else {
        return;
    };
    let response = RpcResponse {
        jsonrpc: "2.0",
        id,
        result: Some(result),
        error: None,
    };
    let _ = tx.send(serde_json::to_string(&response).unwrap_or_default());
}

fn respond_error(
    tx: &mpsc::UnboundedSender<String>,
    id: Option<Value>,
    code: i64,
    message: &str,
) {
    let Some(id) = id else {
        return;
    };
    let response = RpcResponse {
        jsonrpc: "2.0",
        id,
        result: None,
        error: Some(RpcError {
            code,
            message: message.to_string(),
        }),
    };
    let _ = tx.send(serde_json::to_string(&response).unwrap_or_default());
}
