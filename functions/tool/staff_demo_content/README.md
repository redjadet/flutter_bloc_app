# Staff Demo Content Drop Folder

Put demo files (PDFs and videos) in this folder, then run:

```bash
cd functions
npm run setup:staff-demo
```

Supported:

- `*.pdf` (uploaded as `application/pdf`, stored under `staff-app-demo/content/`)
- `*.mp4` (uploaded as `video/mp4`)
- `*.mov` (uploaded as `video/quicktime`)

The script will:

- Upload each file to Firebase Storage: `staff-app-demo/content/<filename>`
- Upsert a Firestore doc in `staffDemoContent` with:
  - `title`: derived from filename
  - `type`: `pdf` or `video`
  - `storagePath`: the Storage path above
  - `isPublished: true`

Override the folder with:

```bash
STAFF_DEMO_CONTENT_DIR="/absolute/path/to/your/files" npm run setup:staff-demo
```
