# Mobile release secret boundary

Mobile release/profile builds now reject provider credentials and orchestration
shared secrets passed through Flutter `--dart-define`. The Render/FastAPI service owns
the Hugging Face credential; Flutter sends Firebase identity and request data
only. The retired Firebase Callable fails closed rather than returning that
credential. Security, deployment, and demo docs now remove the obsolete
client-token/header flow and restrict mobile release defines to public client
configuration. Android and iOS release/profile entrypoints fail closed when a
forbidden provider or shared secret is present.

Deployment follow-up: configure `HUGGINGFACE_API_KEY` in the FastAPI service's
secret manager, rotate any credential previously used by the mobile path, and
redeploy the backend before relying on Render chat. The FastAPI Cloud deploy
helper now honors the CLI's supported `rich-toolkit` version range so this
secret-driven restart can complete and runs `pip check` before upload to catch
future incompatible dependency pins.
