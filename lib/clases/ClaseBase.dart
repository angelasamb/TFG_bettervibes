abstract class ClaseBase{
  late final String id;

  ClaseBase(this.id);

  Map<String, dynamic> toMap();
//fromMap() no puede ser abstract porque devuelve la instancia del Objeto
}

