class Paso {
    Paso({
        this.id,
        this.idTest,
        this.caminata,
        
    });

    String? id;
    String? idTest;
    int? caminata;

    factory Paso.fromJson(Map<String, dynamic> json) => Paso(
        id: json["id"],
        idTest: json["idTest"],
        caminata: json["caminata"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idTest": idTest,
        "caminata": caminata,
    };
}
