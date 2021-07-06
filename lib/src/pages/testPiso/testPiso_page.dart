import 'package:app_piso/src/bloc/fincas_bloc.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/button.dart';
import 'package:app_piso/src/utils/widget/dialogDelete.dart';
import 'package:app_piso/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


final fincasBloc = new FincasBloc();

class TestPage extends StatefulWidget {

    

  @override
  _TestPageState createState() => _TestPageState();
}


class _TestPageState extends State<TestPage> {

    
    Future _getdataFinca(TestPiso textPiso) async{
        Finca? finca = await DBProvider.db.getFincaId(textPiso.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(textPiso.idLote);
        return [finca, parcela];
    }

    @override
    Widget build(BuildContext context) {
        var size = MediaQuery.of(context).size;
        fincasBloc.obtenerPisos();

        return Scaffold(
                appBar: AppBar(title: Text('Selecciona Parcelas'),),
                body: StreamBuilder<List<TestPiso>>(
                    stream: fincasBloc.pisoStream,                    
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());

                        }

                        List<TestPiso> textPisos= snapshot.data;
                        
                        return Column(
                            children: [
                                Expanded(
                                    child:
                                    textPisos.length == 0
                                    ?
                                    textoListaVacio('Ingrese una toma de datos')
                                    :
                                    SingleChildScrollView(child: _listaDePisos(textPisos, size, context))
                                ),
                            ],
                        );
                        
                        
                    },
                ),
                bottomNavigationBar: botonesBottom(_addtest(context)),
        );
        
    }

    Widget _addtest(BuildContext context){
        return Row(
            children: [
                Spacer(),
                ButtonMainStyle(
                    title: 'Escoger parcelas',
                    icon: Icons.post_add,
                    press: () => Navigator.pushNamed(context, 'addTest'),
                ),
                Spacer()
            ],
        );
    }


    Widget  _listaDePisos(List textPisos, Size size, BuildContext context){
        return ListView.builder(
            itemBuilder: (context, index) {
                return Dismissible(
                    key: UniqueKey(),
                    child: GestureDetector(
                        child: FutureBuilder(
                            future: _getdataFinca(textPisos[index]),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                    return Center(child: CircularProgressIndicator());
                                }
                                Finca finca = snapshot.data[0];
                                Parcela parcela = snapshot.data[1];

                                return _cardDesing(size, textPisos[index], finca, parcela);
                            },
                        ),
                        onTap: () => Navigator.pushNamed(context, 'caminatas', arguments: textPisos[index]),
                    ),
                    confirmDismiss: (direction) => confirmacionUser(direction, context),
                    direction: DismissDirection.endToStart,
                    background: backgroundTrash(context),
                    movementDuration: Duration(milliseconds: 500),
                    onDismissed: (direction) => fincasBloc.borrarTestPiso(textPisos[index].id),
                );
               
            },
            shrinkWrap: true,
            itemCount: textPisos.length,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );



    }

    Widget _cardDesing(Size size, TestPiso textPiso, Finca finca, Parcela parcela){
        
        return cardDefault(
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    encabezadoCard('${finca.nombreFinca}','${parcela.nombreLote}', 'assets/icons/test.svg'),
                    textoCardBody('Fecha: ${textPiso.fechaTest}'),
                    iconTap(' Tocar para completar datos')
                ],
            )
        );
    }
}