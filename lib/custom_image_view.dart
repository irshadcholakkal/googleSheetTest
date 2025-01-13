// // ignore_for_file: must_be_immutable

// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class CustomImageView extends StatelessWidget {
//   ///[url] is required parameter for fetching network image
//   String? url;

//   ///[imagePath] is required parameter for showing png,jpg,etc image
//   String? imagePath;

//   ///[svgPath] is required parameter for showing svg image
//   String? svgPath;

//   ///[file] is required parameter for fetching image file
//   File? file;

//   double? height;
//   double? width;
//   Color? color;
//   BoxFit? fit;
//   final String placeHolder;
//   Alignment? alignment;
//   VoidCallback? onTap;
//   EdgeInsetsGeometry? margin;
//   BorderRadius? radius;
//   BoxBorder? border;

//   ///a [CustomImageView] it can be used for showing any type of images
//   /// it will shows the placeholder image if image is not found on network image
//   CustomImageView({
//     this.url,
//     this.imagePath,
//     this.svgPath,
//     this.file,
//     this.height,
//     this.width,
//     this.color,
//     this.fit,
//     this.alignment,
//     this.onTap,
//     this.radius,
//     this.margin,
//     this.border,
//     this.placeHolder = '',
//   });

//   @override
//   Widget build(BuildContext context) {
//     return alignment != null
//         ? Align(
//       alignment: alignment!,
//       child: _buildWidget(),
//     )
//         : _buildWidget();
//   }

//   Widget _buildWidget() {
//     return Padding(
//       padding: margin ?? EdgeInsets.zero,
//       child: InkWell(
//         onTap: onTap,
//         child: _buildCircleImage(),
//       ),
//     );
//   }

//   ///build the image with border radius
//   _buildCircleImage() {
//     if (radius != null) {
//       return ClipRRect(
//         borderRadius: radius ?? BorderRadius.zero,
//         child: _buildImageWithBorder(),
//       );
//     } else {
//       return _buildImageWithBorder();
//     }
//   }

//   ///build the image with border and border radius style
//   _buildImageWithBorder() {
//     if (border != null) {
//       return Container(
//         decoration: BoxDecoration(
//           border: border,
//           borderRadius: radius,
//         ),
//         child: _buildImageView(),
//       );
//     } else {
//       return _buildImageView();
//     }
//   }

//   Widget _buildImageView() {
//     if (svgPath != null && svgPath!.isNotEmpty) {
//       return Container(
//         height: height,
//         width: width,
//         child: SvgPicture.asset(
//           svgPath!,
//           height: height,
//           width: width,
//           fit: fit ?? BoxFit.contain,
//           color: color,
//         ),
//       );
//     } else if (file != null && file!.path.isNotEmpty) {
//       return Image.file(
//         file!,
//         height: height,
//         width: width,
//         fit: fit ?? BoxFit.cover,
//         color: color,
//       );
//     } else if (url != null && url!.isNotEmpty) {
//       return CachedNetworkImage(
//         height: height,
//         width: width,
//         fit: fit,
//         imageUrl: url!,
//         color: color,
//         placeholder: (context, url) => Container(
//           height: 30,
//           width: 30,
//           child: LinearProgressIndicator(
//             color: Colors.grey.shade200,
//             backgroundColor: Colors.grey.shade100,
//           ),
//         ),
//         errorWidget: (context, url, error) => Icon(Icons.image));
//       //   Image.asset(
//       //     placeHolder,
//       //     height: height,
//       //     width: width,
//       //     fit: fit ?? BoxFit.cover,
//       //   ),
//       // );
//     } else if (imagePath != null && imagePath!.isNotEmpty) {
//       return Image.asset(
//         imagePath!,
//         height: height,
//         width: width,
//         fit: fit ?? BoxFit.cover,
//         color: color,
//       );
//     }
//     return const SizedBox();
//   }
// }



import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
Widget buildImage(String imageUrl) {
  return Container(
    height: 80,
    width: double.infinity,
    child: kIsWeb ? Image.network(
      imageUrl,
      height: 80,
      fit: BoxFit.cover,
      headers: const {
        'Access-Control-Allow-Origin': '*',
      },
      errorBuilder: (context, error, stackTrace) => 
        const Center(child: Icon(Icons.image_not_supported)),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    ) : CachedNetworkImage(
      height: 80,
      fit: BoxFit.cover,
      imageUrl: imageUrl,
      errorWidget: (context, url, error) => 
        const Center(child: Icon(Icons.image_not_supported)),
      progressIndicatorBuilder: (context, url, progress) => 
        const Center(child: CircularProgressIndicator()),
    ),
  );
}