import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class BasicInfoSection extends StatelessWidget {
  final UserProfile userProfile;
  final Function(String, dynamic) onFieldEdit;

  const BasicInfoSection({
    super.key,
    required this.userProfile,
    required this.onFieldEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 BASIC INFORMATION',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Full Name
            _buildEditableField(
              context,
              'Full Name',
              userProfile.name,
              Icons.edit,
              () => _showEditDialog(context, 'Full Name', userProfile.name, 'name'),
            ),

            // Email
            _buildFieldWithVerification(
              context,
              'Email',
              userProfile.email,
              Icons.lock,
              true, // Verified
              null, // No edit for email
            ),

            // Phone Number
            if (userProfile.phone != null)
              _buildFieldWithVerification(
                context,
                'Phone Number',
                userProfile.phone!,
                Icons.edit,
                true, // Verified
                () => _showEditDialog(context, 'Phone Number', userProfile.phone!, 'phone'),
              ),

            // Date of Birth
            if (userProfile.dateOfBirth != null)
              _buildEditableField(
                context,
                'Date of Birth',
                '${userProfile.dateOfBirth!.day}/${userProfile.dateOfBirth!.month}/${userProfile.dateOfBirth!.year}',
                Icons.edit,
                () => _showDatePicker(context),
              ),

            // Age (calculated)
            if (userProfile.calculatedAge > 0)
              _buildInfoField(
                context,
                'Age',
                '${userProfile.calculatedAge} years',
                null,
              ),

            // Gender
            _buildEditableField(
              context,
              'Gender',
              _getGenderDisplayName(userProfile.gender),
              Icons.edit,
              () => _showGenderPicker(context),
            ),

            // Location
            _buildEditableField(
              context,
              'Location',
              'Bahawalpur, Pakistan', // Placeholder
              Icons.edit,
              () => _showLocationPicker(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onEdit,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(icon, size: 20),
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWithVerification(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isVerified,
    VoidCallback? onEdit,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(icon, size: 20),
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context,
    String label,
    String value,
    IconData? icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String title, String currentValue, String field) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onFieldEdit(field, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: userProfile.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      onFieldEdit('dateOfBirth', pickedDate);
    }
  }

  void _showGenderPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: Gender.values.map((gender) {
          return ListTile(
            title: Text(_getGenderDisplayName(gender)),
            onTap: () {
              onFieldEdit('gender', gender);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    // For now, just show a text field
    _showEditDialog(context, 'Location', 'Bahawalpur, Pakistan', 'location');
  }

  String _getGenderDisplayName(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Non-binary';
    }
  }
}
