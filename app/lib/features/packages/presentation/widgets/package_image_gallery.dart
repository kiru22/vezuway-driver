import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../data/models/package_model.dart';

/// Widget de galería de imágenes para paquetes.
/// Soporta tanto imágenes locales (Uint8List) como remotas (PackageImage).
class PackageImageGallery extends StatefulWidget {
  /// Imágenes locales (bytes) - para la pantalla de creación
  final List<Uint8List>? localImages;

  /// Imágenes remotas del servidor
  final List<PackageImage>? remoteImages;

  /// Callback cuando se elimina una imagen local (por índice)
  final void Function(int index)? onRemoveLocal;

  /// Callback cuando se elimina una imagen remota (por id)
  final void Function(String mediaId)? onRemoveRemote;

  /// Si está en modo edición (muestra botón de eliminar)
  final bool editMode;

  /// Altura de la galería
  final double height;

  const PackageImageGallery({
    super.key,
    this.localImages,
    this.remoteImages,
    this.onRemoveLocal,
    this.onRemoveRemote,
    this.editMode = false,
    this.height = 180,
  });

  @override
  State<PackageImageGallery> createState() => _PackageImageGalleryState();
}

class _PackageImageGalleryState extends State<PackageImageGallery> {
  late PageController _pageController;
  int _currentPage = 0;

  int get _totalImages =>
      (widget.localImages?.length ?? 0) + (widget.remoteImages?.length ?? 0);

  int get _pageCount => (_totalImages / 2).ceil();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_totalImages == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            itemCount: _pageCount,
            itemBuilder: (context, pageIndex) {
              return _buildPage(pageIndex);
            },
          ),
        ),
        if (_pageCount > 1) ...[
          const SizedBox(height: 12),
          _buildDotsIndicator(),
        ],
      ],
    );
  }

  Widget _buildPage(int pageIndex) {
    final startIndex = pageIndex * 2;
    final images = <Widget>[];

    for (var i = startIndex; i < startIndex + 2 && i < _totalImages; i++) {
      images.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == startIndex ? 0 : 6,
              right: i == startIndex + 1 || i == _totalImages - 1 ? 0 : 6,
            ),
            child: _buildImageTile(i),
          ),
        ),
      );
    }

    // Si solo hay una imagen en esta página, añadir espacio vacío
    if (images.length == 1) {
      images.add(const Expanded(child: SizedBox()));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(children: images),
    );
  }

  Widget _buildImageTile(int index) {
    final colors = context.colors;
    final localCount = widget.localImages?.length ?? 0;
    final isLocal = index < localCount;

    Widget imageWidget;
    VoidCallback? onRemove;

    if (isLocal) {
      // Imagen local (Uint8List)
      imageWidget = Image.memory(
        widget.localImages![index],
        fit: BoxFit.cover,
      );
      if (widget.onRemoveLocal != null) {
        onRemove = () => widget.onRemoveLocal!(index);
      }
    } else {
      // Imagen remota
      final remoteIndex = index - localCount;
      final remoteImage = widget.remoteImages![remoteIndex];
      imageWidget = Image.network(
        remoteImage.thumbUrl ?? remoteImage.url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colors.surface,
            child: Icon(
              Icons.broken_image_outlined,
              color: colors.textMuted,
              size: 40,
            ),
          );
        },
      );
      if (widget.onRemoveRemote != null) {
        onRemove = () => widget.onRemoveRemote!(remoteImage.id);
      }
    }

    return GestureDetector(
      onTap: () => _showFullscreenImage(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageWidget,
          ),
          if (widget.editMode && onRemove != null)
            Positioned(
              top: 8,
              right: 8,
              child: _RemoveButton(onTap: onRemove),
            ),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pageCount, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : colors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  void _showFullscreenImage(int index) {
    final localCount = widget.localImages?.length ?? 0;
    final isLocal = index < localCount;

    showDialog(
      context: context,
      builder: (context) {
        Widget image;
        if (isLocal) {
          image = Image.memory(
            widget.localImages![index],
            fit: BoxFit.contain,
          );
        } else {
          final remoteIndex = index - localCount;
          image = Image.network(
            widget.remoteImages![remoteIndex].url,
            fit: BoxFit.contain,
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: image,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
