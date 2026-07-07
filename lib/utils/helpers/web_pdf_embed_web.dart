import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

final Set<String> _registeredViewTypes = <String>{};

Widget buildWebPdfEmbed(String url) {
  final viewType = 'proof-pdf-${url.hashCode}';

  if (!_registeredViewTypes.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = '0'
        ..width = '100%'
        ..height = '100%'
        ..allow = 'fullscreen';
      return iframe;
    });
    _registeredViewTypes.add(viewType);
  }

  return HtmlElementView(viewType: viewType);
}
