
import 'package:app_piso/src/bloc/fincas_bloc.dart';
import 'package:app_piso/src/models/enContacto_model.dart';
import 'package:app_piso/src/models/paso_model.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/button.dart';
import 'package:app_piso/src/utils/widget/dialogDelete.dart';
import 'package:app_piso/src/utils/widget/varios_widget.dart';
import 'package:app_piso/src/models/selectValue.dart' as selectMap;
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PasoPage extends StatefulWidget {
  @override
  _PasoPageState createState() => _PasoPageState();
}

Future<EnContacto?> _enContacto(Paso? paso) async{
    EnContacto? enContacto = await DBProvider.db.existeEnContactoIdPaso(paso!.id);         
    return enContacto;
}

class _PasoPageState extends State<PasoPage> {

    final fincasBloc = new FincasBloc();

    @override
    Widget build(BuildContext context) {
        List dataCaminatases = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        TestPiso piso = dataCaminatases[0];
        int? indiceCaminata = dataCaminatases[1]+1;
        fincasBloc.obtenerPasoIdTest(piso.id, indiceCaminata);

        return Scaffold(
            appBar: AppBar(title: Text('Lista pasos caminata $indiceCaminata'),),
            body: StreamBuilder<List<Paso>>(
                stream: fincasBloc.pasoStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    final paso = snapshot.data;

                    return Column(
                        children: [ 
                            Expanded(
                                child: paso.length == 0
                                ?
                                textoListaVacio('Ingrese datos de pasos')
                                :
                                SingleChildScrollView(child: _listaDePisos(paso, context, indiceCaminata)),
                            ),
                        ],
                    );
                },
            ),
            bottomNavigationBar: botonesBottom(_countPiso(piso.id, indiceCaminata, piso) ),
        );
    }

    


    Widget  _listaDePisos(List paso, BuildContext context, int? indiceCaminata){

        return ListView.builder(
            itemBuilder: (context, index) {
                if (paso[index].caminata == indiceCaminata) {
                    return Dismissible(
                        key: UniqueKey(),
                        child: GestureDetector(
                            child:cardDefault(
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        tituloCard('Paso ${index+1}'),
                                        FutureBuilder(
                                            future: _enContacto(paso[index]),
                                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                if (!snapshot.hasData) {
                                                    return Container();
                                                }
                                                String labelEnContacto = selectMap.itemContacto().firstWhere((e) => e['value'] == '${snapshot.data.idContacto}')['label'];
                                                return subtituloCardBody('En contacto con : $labelEnContacto');
                                            },
                                        ),
                                    ],
                                )

                            )
                        ),
                        confirmDismiss: (direction) => confirmacionUser(direction, context),
                        direction: DismissDirection.endToStart,
                        background: backgroundTrash(context),
                        movementDuration: Duration(milliseconds: 500),
                        onDismissed: (direction) => fincasBloc.borrarPaso(paso[index]),
                    );
                }
                return Container();
            },
            shrinkWrap: true,
            itemCount: paso.length,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }

    

    Widget  _countPiso(String? idPlaga,  int? caminatas, TestPiso piso){
        return StreamBuilder<List<Paso>>(
            stream: fincasBloc.pasoStream,
            
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                List<Paso> pasos = snapshot.data;
                
                int value = pasos.length;
                
                if (value < 20) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                            textoBottom('Pasos: $value / 20', kTextColor),
                            _addPaso(context, caminatas, piso, value),
                        ],
                    );
                }else{
                    if (caminatas! <= 2){
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                textoBottom('Pasos: $value / 20',  kTextColor),
                                ButtonMainStyle(
                                    title: 'Siguiente caminata',
                                    icon: Icons.navigate_next_rounded,
                                    press: () => Navigator.popAndPushNamed(context, 'pasos', arguments: [piso, caminatas]),
                                )
                            ],
                        );
                    }else{
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                textoBottom('Plantas: $value / 10',  kTextColor),
                                ButtonMainStyle(
                                    title: 'Lista de sitios',
                                    icon: Icons.chevron_left,
                                    press:() => Navigator.pop(context),
                                )
                            ],
                        );
                    }

                    
                }                
            },
        );
    }


    Widget  _addPaso(BuildContext context,  int? caminata, TestPiso plaga, int value){
        return ButtonMainStyle(
            title: 'Agregar Paso',
            icon: Icons.post_add,
            press:() => Navigator.pushNamed(context, 'addPasos', arguments: [caminata,plaga.id,value]),
        );
    }

}