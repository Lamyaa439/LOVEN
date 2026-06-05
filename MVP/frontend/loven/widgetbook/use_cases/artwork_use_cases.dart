import 'package:loven/features/artwork/view/widgets/upload_artwork_preview.dart';
import 'package:widgetbook/widgetbook.dart';

final artworkUseCases = WidgetbookComponent(
  name: 'Artwork',
  useCases: [
    WidgetbookUseCase(
      name: 'Upload Artwork UI',
      builder: (context) {
        return const UploadArtworkPreview();
      },
    ),
  ],
);