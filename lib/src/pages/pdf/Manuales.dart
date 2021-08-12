import 'package:app_piso/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';


class Manuales extends StatelessWidget {
  const Manuales({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Lista de instructivos'),),
            body: ListView(
                children: [
                    _card( context, 'Instructivo piso cacao', 'assets/documentos/Instructivo Piso.pdf'),
                    _card( context, 'Manual de usuario Cacao Piso', 'assets/documentos/Manual de usuario Cacao Piso.pdf')
                ],
            )
        );
    }

    Widget _card( BuildContext context, String titulo, String url){
        return GestureDetector(
            child: cardDefault(
                tituloCard('$titulo'),
            ),
            onTap: () => Navigator.pushNamed(context, 'PDFview', arguments: [titulo, url]),
        );
    }


}