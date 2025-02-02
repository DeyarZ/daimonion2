// lib/pages/privacy_and_terms_page.dart

import 'package:flutter/material.dart';
import '../l10n/generated/l10n.dart'; // Lokalisierung importieren

class PrivacyAndTermsPage extends StatelessWidget {
  const PrivacyAndTermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final textStyle = const TextStyle(color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.privacyAndTermsTitle),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          loc.privacyAndTermsContent,
          style: textStyle,
        ),
      ),
    );
  }
}
