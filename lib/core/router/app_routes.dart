// coverage:ignore-file - static container of route constants.
/// Central place to keep route names and paths used by GoRouter.
class AppRoutes {
  AppRoutes._();

  static const counter = 'counter';
  static const counterPath = '/';

  static const example = 'example';
  static const examplePath = '/example';

  static const charts = 'charts';
  static const chartsPath = '/charts';

  static const calculator = 'calculator';
  static const calculatorPath = '/calculator';

  static const calculatorPayment = 'calculator-payment';
  static const calculatorPaymentPath = '/calculator/payment';

  static const settings = 'settings';
  static const settingsPath = '/settings';

  static const chat = 'chat';
  static const chatPath = '/chat';

  static const chatList = 'chat-list';
  static const chatListPath = '/chat-list';

  static const websocket = 'websocket';
  static const websocketPath = '/websocket';

  static const googleMaps = 'google-maps';
  static const googleMapsPath = '/google-maps';

  static const graphql = 'graphql-demo';
  static const graphqlPath = '/graphql-demo';

  static const auth = 'auth';
  static const authPath = '/auth';

  static const profile = 'profile';
  static const profilePath = '/profile';

  static const manageAccount = 'manage-account';
  static const manageAccountPath = '/manage-account';

  static const register = 'register';
  static const registerPath = '/register';

  static const search = 'search';
  static const searchPath = '/search';

  static const todoList = 'todo-list';
  static const todoListPath = '/todo-list';

  static const loggedOut = 'logged-out';
  static const loggedOutPath = '/logged-out';

  static const libraryDemo = 'library-demo';
  static const libraryDemoPath = '/library-demo';

  static const whiteboard = 'whiteboard';
  static const whiteboardPath = '/whiteboard';

  static const markdownEditor = 'markdown-editor';
  static const markdownEditorPath = '/markdown-editor';

  static const scapes = 'scapes';
  static const scapesPath = '/scapes';

  static const genuiDemo = 'genui-demo';
  static const genuiDemoPath = '/genui-demo';

  static const walletconnectAuth = 'walletconnect-auth';
  static const walletconnectAuthPath = '/walletconnect-auth';

  static const supabaseAuth = 'supabase-auth';
  static const supabaseAuthPath = '/supabase-auth';

  static const playlearn = 'playlearn';
  static const playlearnPath = '/playlearn';

  static const playlearnVocabulary = 'playlearn-vocabulary';
  static const playlearnVocabularyPath = '/playlearn/vocabulary/:topicId';

  static const cameraGallery = 'camera-gallery';
  static const cameraGalleryPath = '/camera-gallery';

  static const igamingDemo = 'igaming-demo';
  static const igamingDemoPath = '/igaming-demo';
  static const igamingDemoGame = 'igaming-demo-game';
  static const igamingDemoGamePath = '/igaming-demo/game';

  static const fcmDemo = 'fcm-demo';
  static const fcmDemoPath = '/fcm-demo';

  static const firebaseFunctionsTest = 'firebase-functions-test';
  static const firebaseFunctionsTestPath = '/firebase-functions-test';

  static const iotDemo = 'iot-demo';
  static const iotDemoPath = '/iot-demo';

  static const iapDemo = 'iap-demo';
  static const iapDemoPath = '/iap-demo';

  static const caseStudyDemo = 'case-study-demo';
  static const caseStudyDemoPath = '/case-study-demo';

  static const caseStudyDemoNew = 'case-study-demo-new';
  static const caseStudyDemoNewPath = '/case-study-demo/new';

  static const caseStudyDemoRecord = 'case-study-demo-record';
  static const caseStudyDemoRecordPath = '/case-study-demo/record';

  static const caseStudyDemoReview = 'case-study-demo-review';
  static const caseStudyDemoReviewPath = '/case-study-demo/review';

  static const caseStudyDemoHistory = 'case-study-demo-history';
  static const caseStudyDemoHistoryPath = '/case-study-demo/history';

  static const caseStudyDemoHistoryDetail = 'case-study-demo-history-detail';
  static const caseStudyDemoHistoryDetailPath = '/case-study-demo/history/:id';

  static const staffAppDemo = 'staff-app-demo';
  static const staffAppDemoPath = '/staff-app-demo';

  static const aiDecisionDemo = 'ai-decision-demo';
  static const aiDecisionDemoPath = '/ai-decision-demo';

  static const staffAppDemoDashboard = 'staff-app-demo-dashboard';
  static const staffAppDemoDashboardPath = '/staff-app-demo/dashboard';

  static const staffAppDemoTimeclock = 'staff-app-demo-timeclock';
  static const staffAppDemoTimeclockPath = '/staff-app-demo/timeclock';

  static const staffAppDemoMessages = 'staff-app-demo-messages';
  static const staffAppDemoMessagesPath = '/staff-app-demo/messages';

  static const staffAppDemoContent = 'staff-app-demo-content';
  static const staffAppDemoContentPath = '/staff-app-demo/content';

  static const staffAppDemoForms = 'staff-app-demo-forms';
  static const staffAppDemoFormsPath = '/staff-app-demo/forms';

  static const staffAppDemoProof = 'staff-app-demo-proof';
  static const staffAppDemoProofPath = '/staff-app-demo/proof';

  static const staffAppDemoAdmin = 'staff-app-demo-admin';
  static const staffAppDemoAdminPath = '/staff-app-demo/admin';

  /// Returns true if [path] is safe for post-login redirect (local path only).
  /// Rejects null, empty, protocol-relative (//), and external URLs.
  static bool isSafeRedirectPath(final String? path) {
    if (path == null || path.isEmpty) return false;
    if (!path.startsWith('/')) return false;
    if (path.startsWith('//')) return false;
    return true;
  }
}
