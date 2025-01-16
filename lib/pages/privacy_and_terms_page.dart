// lib/pages/privacy_and_terms_page.dart

import 'package:flutter/material.dart';

class PrivacyAndTermsPage extends StatelessWidget {
  const PrivacyAndTermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutz & Nutzungsbedingungen'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          """
Datenschutz und Nutzungsbedingungen

Datenschutz
Wir nehmen den Schutz deiner Daten ernst. Aktuell speichert unsere App keine Daten in externen Datenbanken. Alle Informationen, die du in der App eingibst, werden lokal auf deinem Gerät gespeichert. Es erfolgt keine Weitergabe deiner Daten an Dritte.

In Zukunft könnten zusätzliche Funktionen wie ein Login oder Online-Dienste integriert werden. Falls dies geschieht, werden wir diese Datenschutzerklärung entsprechend aktualisieren, um dich transparent über Änderungen zu informieren.

Nutzungsbedingungen
Unsere App ist darauf ausgelegt, dir zu helfen, produktiver zu werden und deine Ziele zu erreichen. Die Nutzung der App erfolgt auf eigene Verantwortung. Wir übernehmen keine Haftung für direkte oder indirekte Schäden, die aus der Nutzung der App entstehen könnten.

Bitte benutze die App verantwortungsbewusst und halte dich an die Gesetze deines Landes.

Kontakt
Falls du Fragen oder Anliegen zu unseren Datenschutzrichtlinien oder Nutzungsbedingungen hast, kontaktiere uns unter kontakt@dineswipe.de.

          """,
          style: textStyle,
        ),
      ),
    );
  }
}
