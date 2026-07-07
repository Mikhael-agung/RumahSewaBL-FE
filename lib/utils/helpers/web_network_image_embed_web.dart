import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

final Set<String> _registeredImageViewTypes = <String>{};

Widget buildWebNetworkImageEmbed(String url) {
  final viewType = 'proof-image-${url.hashCode}';

  if (!_registeredImageViewTypes.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final image = html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain';
      return image;
    });
    _registeredImageViewTypes.add(viewType);
  }

  return HtmlElementView(viewType: viewType);
}
