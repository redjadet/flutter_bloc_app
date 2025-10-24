import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/data/mock_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_action_buttons.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_bottom_nav.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_gallery.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final MockProfileRepository _repository = MockProfileRepository();
  ProfileUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile(); // ignore: discarded_futures - async call in initState is intentional
  }

  Future<void> _loadProfile() async {
    final user = await _repository.getProfile();
    if (!mounted) return;
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : _user == null
        ? const Center(child: Text('Failed to load profile'))
        : Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ProfileHeader(user: _user!),
                        const ProfileActionButtons(),
                        SizedBox(height: UI.gapL * 2),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ProfileGallery(images: _user!.galleryImages),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.pageHorizontalPadding,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: UI.gapL * 2),
                          SizedBox(
                            width: double.infinity,
                            height: context.isMobile ? 52 : 56,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'SEE MORE',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: context.responsiveCaptionSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.52,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 100 + MediaQuery.of(context).padding.bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ProfileBottomNav(),
              ),
            ],
          ),
  );
}
