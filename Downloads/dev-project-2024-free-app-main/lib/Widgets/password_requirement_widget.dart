import 'package:flutter/material.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final bool hasValidLength;
  final bool hasLowercase;
  final bool hasUppercase;
  final bool hasDigit;
  final bool hasSpecialChar;

  const PasswordRequirementsWidget({
    super.key,
    required this.hasValidLength,
    required this.hasLowercase,
    required this.hasUppercase,
    required this.hasDigit,
    required this.hasSpecialChar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPasswordRequirement("Between 8 and 20 characters", hasValidLength),
        _buildPasswordRequirement("At least 1 lowercase character", hasLowercase),
        _buildPasswordRequirement("At least 1 uppercase character", hasUppercase),
        _buildPasswordRequirement("At least 1 digit", hasDigit),
        _buildPasswordRequirement("At least 1 special character", hasSpecialChar),
      ],
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: isValid ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            requirement,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
