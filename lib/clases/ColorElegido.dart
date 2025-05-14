enum ColorElegido{
  Rojo,
  Naranja,
  Amarillo,
  Verde,
  AzulClaro,
  AzulOscuro,
  Morado,
  Rosa,
  Gris;

  //convierte un string en un valor enum
  static ColorElegido formarString(String color){
    return ColorElegido.values.firstWhere(
        (e) => e.name ==color, //busca primer elemento que coincida con el string proporcionado
      orElse: () => ColorElegido.Amarillo, //amarillo por defecto
    );
  }
}
