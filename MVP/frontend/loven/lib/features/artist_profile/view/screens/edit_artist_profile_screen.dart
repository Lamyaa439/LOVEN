import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/artist_profile_cubit.dart';
import '../../controller/artist_profile_state.dart';
import '../../model/artist_model.dart';

class EditArtistProfileScreen extends StatefulWidget {
  const EditArtistProfileScreen({
    super.key,
    required this.artist,
  });

  final ArtistModel artist;

  @override
  State<EditArtistProfileScreen> createState() =>
      _EditArtistProfileScreenState();
}

class _EditArtistProfileScreenState extends State<EditArtistProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _displayNameController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;
  late final TextEditingController _shippingPolicyController;

  final List<String> _cities = [
    'Riyadh',
    'Jeddah',
    'Mecca',
    'Medina',
    'Dammam',
    'Khobar',
    'Dhahran',
    'Taif',
    'Tabuk',
    'Abha',
    'Hail',
    'Jazan',
    'Najran',
    'Al Bahah',
    'Al Ahsa',
    'Yanbu',
  ];

  @override
  void initState() {
    super.initState();

    _displayNameController =
        TextEditingController(text: widget.artist.displayName);
    _cityController =
        TextEditingController(text: widget.artist.city ?? '');
    _bioController =
        TextEditingController(text: widget.artist.bio ?? '');
    _shippingPolicyController =
        TextEditingController(text: widget.artist.shippingPolicy ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _shippingPolicyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<ArtistProfileCubit>().updateProfileInfo(
          displayName: _displayNameController.text.trim(),
          city: _cityController.text.trim(),
          bio: _bioController.text.trim(),
          shippingPolicy: _shippingPolicyController.text.trim(),
        );

    if (!mounted) return;

    final state = context.read<ArtistProfileCubit>().state;

    if (state.status == ArtistProfileStatus.success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ArtistProfileCubit, ArtistProfileState>(
      listener: (context, state) {
        if (state.status == ArtistProfileStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Could not update profile'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Artist Profile'),
          centerTitle: true,
        ),
        body: BlocBuilder<ArtistProfileCubit, ArtistProfileState>(
          builder: (context, state) {
            final isLoading = state.status == ArtistProfileStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Display name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: _cityController.text.isEmpty
                          ? null
                          : _cityController.text,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _cityController.text = value ?? '';
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _shippingPolicyController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Shipping policy',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _save,
                        child: Text(isLoading ? 'Saving...' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}