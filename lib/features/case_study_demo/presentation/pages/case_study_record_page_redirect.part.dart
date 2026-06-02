part of 'case_study_record_page.dart';

class _CaseStudyStepRedirect extends StatefulWidget {
  const _CaseStudyStepRedirect({required this.targetRouteName});

  final String targetRouteName;

  @override
  State<_CaseStudyStepRedirect> createState() => _CaseStudyStepRedirectState();
}

class _CaseStudyStepRedirectState extends State<_CaseStudyStepRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.goNamed(widget.targetRouteName);
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
