abstract class ClaseBase{
  final String id;

  ClaseBase({required this.id});

  Map<String, dynamic> toMap();
//fromMap() no puede ser abstract porque devuelve la instancia del Objeto
}

