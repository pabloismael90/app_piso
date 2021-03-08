
import 'package:app_piso/src/bloc/fincas_bloc.dart';
import 'package:app_piso/src/models/paso_model.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/dialogDelete.dart';
import 'package:app_piso/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PasoPage extends StatefulWidget {
  @override
  _PasoPageState createState() => _PasoPageState();
}

class _PasoPageState extends State<PasoPage> {

    final fincasBloc = new FincasBloc();

    @override
    Widget build(BuildContext context) {
        List dataCaminatases = ModalRoute.of(context).settings.arguments;
        TestPiso piso = dataCaminatases[0];
        int indiceCaminata = dataCaminatases[1]+1;
        fincasBloc.obtenerPasoIdTest(piso.id, indiceCaminata);

        return Scaffold(
            appBar: AppBar(),
            body: StreamBuilder<List<Paso>>(
                stream: fincasBloc.pasoStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    //print(snapshot.data);
                    final paso = snapshot.data;

                    if (paso.length == 0) {
                        return Column(
                            children: [
                                TitulosPages(titulo: 'Caminata $indiceCaminata'),
                                Divider(), 
                                Expanded(child: Center(
                                    child: Text('No hay datos: \nIngrese datos de pasos', 
                                    textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline6,
                                        )
                                    )
                                )
                            ],
                        );
                    }
                    
                    return Column(
                        children: [
                            TitulosPages(titulo: 'Caminata $indiceCaminata'),
                            Divider(),                            
                            Expanded(child: SingleChildScrollView(child: _listaDePisos(paso, context, indiceCaminata))),
                        ],
                    );
                },
            ),
            bottomNavigationBar: BottomAppBar(
                child: Container(
                    color: kBackgroundColor,
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: _countPiso(piso.id, indiceCaminata, piso)
                    ),
                ),
            ),
        );
    }

    


    Widget  _listaDePisos(List paso, BuildContext context, int indiceCaminata){

        return ListView.builder(
            itemBuilder: (context, index) {
                if (paso[index].caminata == indiceCaminata) {

                    return Dismissible(
                        key: UniqueKey(),
                        child: GestureDetector(
                            child:Container(
                                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                    
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.5),
                                        boxShadow: [
                                            BoxShadow(
                                                color: Color(0xFF3A5160)
                                                    .withOpacity(0.05),
                                                offset: const Offset(1.1, 1.1),
                                                blurRadius: 17.0),
                                            ],
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                            
                                            Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                                child: Text(
                                                    "Paso ${index+1}",
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: Theme.of(context).textTheme.headline6,
                                                ),
                                            ),
                                        ],
                                    ),
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

    

    Widget  _countPiso(String idPlaga,  int caminatas, TestPiso piso){
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
                            Text('Pasos: $value / 20',
                                style: Theme.of(context).textTheme
                                        .headline6
                                        .copyWith(fontWeight: FontWeight.w600)
                            ),
                            _addPaso(context, caminatas, piso, value),
                        ],
                    );
                }else{
                    if (caminatas <= 2){
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                Container(
                                    child: Text('Pasos: $value / 20',
                                        style: Theme.of(context).textTheme
                                                .headline6
                                                .copyWith(fontWeight: FontWeight.w600)
                                    ),
                                ),
                                RaisedButton.icon(
                                    icon:Icon(Icons.navigate_next_rounded),                               
                                    label: Text('Siguiente caminata',
                                        style: Theme.of(context).textTheme
                                            .headline6
                                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)
                                    ),
                                    padding:EdgeInsets.all(13),
                                    onPressed:() => Navigator.popAndPushNamed(context, 'pasos', arguments: [piso, caminatas]),
                                )
                            ],
                        );
                    }else{
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                Container(
                                    child: Text('Pisos : $value / 20',
                                        style: Theme.of(context).textTheme
                                                .headline6
                                                .copyWith(fontWeight: FontWeight.w600)
                                    ),
                                ),
                                RaisedButton.icon(
                                    icon:Icon(Icons.chevron_left),                               
                                    label: Text('Lista de caminatas',
                                        style: Theme.of(context).textTheme
                                            .headline6
                                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)
                                    ),
                                    padding:EdgeInsets.all(13),
                                    onPressed:() => Navigator.pop(context),
                                )
                            ],
                        );
                    }

                    
                }                
            },
        );
    }


    Widget  _addPaso(BuildContext context,  int caminata, TestPiso plaga, int value){
        return RaisedButton.icon(
            
            icon:Icon(Icons.add_circle_outline_outlined),
            
            label: Text('Agregar Paso',
                style: Theme.of(context).textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)
            ),
            padding:EdgeInsets.all(13),
            onPressed:() => Navigator.pushNamed(context, 'addPasos', arguments: [caminata,plaga.id,value]),
        );
    }

}