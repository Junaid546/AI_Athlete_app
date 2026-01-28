import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Welcome to Athlete AI',
      description: 'Your personal AI-powered training companion for peak performance.',
      icon: Icons.waving_hand,
    ),
    OnboardingPageData(
      title: 'Smart Workout Plans',
      description: 'Get customized training plans based on your sport and goals.',
      icon: Icons.fitness_center,
    ),
    OnboardingPageData(
      title: 'Track Your Progress',
      description: 'Monitor your sessions, view charts, and get AI insights.',
      icon: Icons.show_chart,
    ),
    OnboardingPageData(
      title: 'Let\'s Get Started',
      description: 'Create your profile and start your journey to better performance.',
      icon: Icons.rocket_launch,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToProfileSetup();
    }
  }

  void _goToProfileSetup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(data: _pages[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == _pages.length - 1 ? 'Start' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            data.icon,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ProfileSetupScreen extends StatefulWidget {
  final String? userId;
  final String? email;
  final String? name;
  final UserRole? role;

  const ProfileSetupScreen({
    super.key,
    this.userId,
    this.email,
    this.name,
    this.role,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _sportController = TextEditingController();
  final _ageController = TextEditingController();
  final _goalController = TextEditingController();
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _selectedRole = widget.role ?? UserRole.athlete;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _sportController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Select Your Role', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<UserRole>(
                        title: const Text('Athlete'),
                        value: UserRole.athlete,
                        groupValue: _selectedRole,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<UserRole>(
                        title: const Text('Coach'),
                        value: UserRole.coach,
                        groupValue: _selectedRole,
                        onChanged: (value) => setState(() => _selectedRole = value!),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _sportController,
                  decoration: const InputDecoration(labelText: 'Sport'),
                  validator: (value) => value!.isEmpty ? 'Please enter your sport' : null,
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter your age';
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) return 'Please enter a valid age';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _goalController,
                  decoration: const InputDecoration(labelText: 'Training Goal'),
                  validator: (value) => value!.isEmpty ? 'Please enter your goal' : null,
                ),
                const SizedBox(height: 20),
                Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final profile = UserProfile(
                            id: widget.userId ?? DateTime.now().toString(),
                            name: _nameController.text,
                            email: _emailController.text,
                            primarySport: _sportController.text,
                            trainingGoals: [_goalController.text],
                            role: _selectedRole,
                            gender: Gender.other, // Default
                            experienceLevel: ExperienceLevel.beginner, // Default
                            trainingFrequency: TrainingFrequency.threeDays, // Default
                            sessionDuration: SessionDuration.sixtyMin, // Default
                            preferredTime: PreferredTime.morning, // Default
                            equipmentLevel: EquipmentLevel.minimal, // Default
                            createdAt: DateTime.now(),
                          );
                          ref.read(userProfileProvider.notifier).setProfile(profile);
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                      child: const Text('Complete Setup'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
