class EnContacto {
    EnContacto({
        this.id,
        this.idPaso,
        this.idContacto,
        this.existe = 1,
    });

    String? id;
    String? idPaso;
    int? idContacto;
    int? existe;

    factory EnContacto.fromJson(Map<String, dynamic> json) => EnContacto(
        id: json["id"],
        idPaso: json["idPaso"],
        idContacto: json["idContacto"],
        existe: json["existe"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idPaso": idPaso,
        "idContacto":idContacto,
        "existe": existe,
    };
}