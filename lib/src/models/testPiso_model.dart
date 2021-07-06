import 'dart:convert';

TestPiso testpisoFromJson(String str) => TestPiso.fromJson(json.decode(str));

String testpisoToJson(TestPiso data) => json.encode(data.toJson());

class TestPiso {
    TestPiso({
        this.id,
        this.idFinca = '',
        this.idLote = '',
        this.caminatas = 3,
        this.fechaTest,
    });

    String? id;
    String? idFinca;
    String? idLote;
    int? caminatas;
    String? fechaTest;

    factory TestPiso.fromJson(Map<String, dynamic> json) => TestPiso(
        id: json["id"],
        idFinca: json["idFinca"],
        idLote: json["idLote"],
        caminatas: json["caminatas"],
        fechaTest: json["fechaTest"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "idFinca": idFinca,
        "idLote": idLote,
        "caminatas": caminatas,
        "fechaTest": fechaTest,
    };
}