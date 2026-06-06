import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Uploads account profile images to Firebase Storage.
///
/// Owned by the account feature; registered in [AppDependencies] and consumed
/// via [RepositoryProvider] (e.g. [EditAccountScreen]).
class ProfileImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://loven-88b0a.firebasestorage.app',
  );

  Future<String> uploadProfileImage({
    required XFile imageFile,
    required String userId,
  }) async {
    final bytes = await imageFile.readAsBytes();

    final ref = _storage.ref().child(
          'profile_images/$userId/profile.jpg',
        );

    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    return ref.getDownloadURL();
  }
}
