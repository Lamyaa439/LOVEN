import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ArtworkImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://loven-88b0a.firebasestorage.app',
  );

  Future<String> uploadArtworkImage({
    required XFile imageFile,
    required String artistId,
  }) async {
    final bytes = await imageFile.readAsBytes();

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = _storage.ref().child(
          'artwork_images/$artistId/$fileName',
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