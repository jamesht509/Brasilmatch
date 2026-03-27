import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _brazilianCityController = TextEditingController();
  final _brazilianStateController = TextEditingController();
  
  String _selectedGender = 'male';
  String _selectedInterestedIn = 'female';
  List<String> _photos = []; // Agora armazena URLs do Supabase, não paths locais
  
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  
  bool _isUploadingPhoto = false; // Estado de loading para upload

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _brazilianCityController.dispose();
    _brazilianStateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Verificar limite de fotos
    if (_photos.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo de 6 fotos'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // PASSO 1: Escolher imagem da galeria
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return; // Usuário cancelou
    
    // PASSO 2: Pegar ID do usuário autenticado
    final authState = ref.read(authProvider);
    if (authState.authUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: usuário não autenticado'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    final userId = authState.authUser!.id;
    
    // PASSO 3: Mostrar loading
    setState(() {
      _isUploadingPhoto = true;
    });
    
    // PASSO 4: Fazer upload real para Supabase Storage
    final photoUrl = await _storageService.uploadProfilePhoto(
      filePath: image.path,
      userId: userId,
    );
    
    // PASSO 5: Esconder loading
    setState(() {
      _isUploadingPhoto = false;
    });
    
    // PASSO 6: Verificar resultado
    if (photoUrl != null) {
      // Sucesso! Adicionar URL à lista
      setState(() {
        _photos.add(photoUrl);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto adicionada!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Erro no upload
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao fazer upload. Tente novamente.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;

    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos 1 foto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authState = ref.read(authProvider);
    if (authState.authUser == null) return;

    final user = UserModel(
      id: authState.authUser!.id,
      email: authState.authUser!.email!,
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      bio: _bioController.text.trim(),
      photos: _photos,
      avatarUrl: _photos.first,
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: 'USA',
      brazilianCity: _brazilianCityController.text.trim(),
      brazilianState: _brazilianStateController.text.trim(),
      gender: _selectedGender,
      interestedIn: _selectedInterestedIn,
      createdAt: DateTime.now(),
    );

    await ref.read(authProvider.notifier).createProfile(user);

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete seu perfil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: 0.5,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                
                const SizedBox(height: 32),
                
                // Photos Section
                Text(
                  'Adicione fotos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Adicione pelo menos 1 foto (máx. 6)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _photos.length) {
                        return _AddPhotoButton(
                          onTap: _pickImage,
                          isLoading: _isUploadingPhoto,
                        );
                      }
                      return _PhotoThumbnail(
                        path: _photos[index],
                        onRemove: () {
                          setState(() {
                            _photos.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Basic Info
                CustomTextField(
                  controller: _nameController,
                  label: 'Nome',
                  hint: 'Seu nome',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite seu nome';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _ageController,
                  label: 'Idade',
                  hint: '18+',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.cake_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite sua idade';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 18) {
                      return 'Você precisa ter 18 anos ou mais';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _bioController,
                  label: 'Bio',
                  hint: 'Conte um pouco sobre você...',
                  maxLines: 3,
                  maxLength: 200,
                ),
                
                const SizedBox(height: 24),
                
                // Gender Selection
                Text(
                  'Seu gênero',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: 'Homem',
                        icon: Icons.male,
                        isSelected: _selectedGender == 'male',
                        onTap: () => setState(() => _selectedGender = 'male'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        label: 'Mulher',
                        icon: Icons.female,
                        isSelected: _selectedGender == 'female',
                        onTap: () => setState(() => _selectedGender = 'female'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Interested In
                Text(
                  'Interessado em',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        label: 'Mulheres',
                        icon: Icons.female,
                        isSelected: _selectedInterestedIn == 'female',
                        onTap: () => setState(() => _selectedInterestedIn = 'female'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        label: 'Homens',
                        icon: Icons.male,
                        isSelected: _selectedInterestedIn == 'male',
                        onTap: () => setState(() => _selectedInterestedIn = 'male'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        label: 'Ambos',
                        icon: Icons.wc,
                        isSelected: _selectedInterestedIn == 'both',
                        onTap: () => setState(() => _selectedInterestedIn = 'both'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Location Section
                Text(
                  'Onde você mora agora?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _cityController,
                        label: 'Cidade',
                        hint: 'Miami',
                        prefixIcon: Icons.location_city,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite a cidade';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _stateController,
                        label: 'Estado',
                        hint: 'FL',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o estado';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Brazilian Origin
                Text(
                  'De onde você é no Brasil? 🇧🇷',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _brazilianCityController,
                        label: 'Cidade',
                        hint: 'São Paulo',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite a cidade';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _brazilianStateController,
                        label: 'Estado',
                        hint: 'SP',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o estado';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Complete Button
                CustomButton(
                  text: 'Completar perfil',
                  onPressed: _handleComplete,
                  isLoading: authState.isLoading,
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _AddPhotoButton({
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // Desabilitar durante loading
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLoading ? AppColors.textHint : AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicionar',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _PhotoThumbnail({
    required this.path,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceVariant,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: path,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.image,
                  size: 40,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textHint.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
