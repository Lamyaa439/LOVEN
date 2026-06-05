import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ArtistProfileImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://loven-88b0a.firebasestorage.app',
  );

  Future<String> uploadProfileImage({
    required XFile imageFile,
    required String artistId,
  }) async {
    final bytes = await imageFile.readAsBytes();

    final ref = _storage.ref().child(
          'artist_profiles/$artistId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return ref.getDownloadURL();
  }

  Future<String> uploadCoverImage({
    required XFile imageFile,
    required String artistId,
  }) async {
    final bytes = await imageFile.readAsBytes();

    final ref = _storage.ref().child(
          'artist_profiles/$artistId/cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return ref.getDownloadURL();
  }
}