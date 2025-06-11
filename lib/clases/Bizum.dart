import 'package:cloud_firestore/cloud_firestore.dart';

class Bizum {
  final DocumentReference personaPaga;
  final DocumentReference personaRecibe;
  final num precio;
  final bool hecho;

  Bizum({
    required this.personaPaga,
    required this.personaRecibe,
    required this.precio,
    this.hecho = false,
  });

  factory Bizum.fromFirestore(Map<String, dynamic> data) {
    return Bizum(
      personaPaga: data['personaPaga'] as DocumentReference,
      personaRecibe: data['personaRecibe'] as DocumentReference,
      precio: (data['precio'] ?? 0) as num,
      hecho: data['hecho'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'personaPaga': personaPaga,
      'personaRecibe': personaRecibe,
      'precio': precio,
      'hecho': hecho,
    };
  }
}