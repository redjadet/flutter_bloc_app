# Dentists Case Study

Need a cross-platform application for dentists that allows them to record responses to predefined case study questions. The app should work on both iOS and Android platforms and should preferably be developed using Flutter.

The main goal of the application is to allow dentists to record answers to ten predefined case study questions. Each question will be shown one at a time, and the dentist will record a video response for each question. Every answer should be captured as a separate video clip, and all clips should be uploaded together along with relevant case metadata such as doctor name, case type, and optional notes.

The application will include a login screen where users can enter their email and password to access the system. After logging in, users will see a home screen that provides options to record a new case study, view previously recorded cases, or access settings. When starting a new case, the user will enter the doctor’s name, select the case type, and optionally add notes before beginning the recording process.

During the recording workflow, the system will present ten predefined questions sequentially. The user will record a video response for each question, and each response will be saved as an individual video clip. Once all questions have been answered, the clips should be uploaded to the server along with the case information.

We are looking for developers who have strong experience building mobile applications, particularly apps that include video recording and file uploads. Experience with API integration and handling media files efficiently is important.

## Implementation in this repository

The **Case Study Demo** feature (`lib/features/case_study_demo/`) implements this brief as a reference flow: Firebase-auth–gated wizard, per-question video capture, local persistence (Hive), review/submit, and history with playback. When Supabase is configured, submissions can use private storage and per-user remote records (see plans below).

- **Routes:** `/case-study-demo` (home, new case, record, review, history, detail) — see [Feature overview](../feature_overview.md).
- **Plans:** [Dentist demo implementation plan](../changes/2026-04-01_dentist_case_study_demo_plan.md), [Supabase private storage extension](../changes/2026-04-02_case_study_supabase_private_storage_plan.md).
- **Index:** [Case studies README](README.md).
