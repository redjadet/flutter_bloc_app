# Mobile release secret boundary

Release Android builds now reject provider credentials and orchestration shared
secrets passed through Flutter `--dart-define`. The Render/FastAPI service owns
the Hugging Face credential; Flutter sends Firebase identity and request data
only. The retired Firebase Callable fails closed rather than returning that
credential.

Deployment follow-up: configure `HUGGINGFACE_API_KEY` in the FastAPI service's
secret manager, rotate any credential previously used by the mobile path, and
redeploy the backend before relying on Render chat.
