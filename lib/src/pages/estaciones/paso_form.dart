import 'package:app_piso/src/bloc/fincas_bloc.dart';
import 'package:app_piso/src/models/enContacto_model.dart';
import 'package:app_piso/src/models/paso_model.dart';

import 'package:app_piso/src/models/selectValue.dart' as selectMap;
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


class AgregarPlanta extends StatefulWidget {
  @override
  _AgregarPlantaState createState() => _AgregarPlantaState();
}

class _AgregarPlantaState extends State<AgregarPlanta> {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final formKey = GlobalKey<FormState>();

    bool _guardando = false;
    int variableVacias = 0;
    int countPlanta = 0;
    var uuid = Uuid();

    Paso paso = Paso();
    EnContacto enContacto = EnContacto();
    List<EnContacto> listaPlagas = [];

    final fincasBloc = new FincasBloc();
    
    final List<Map<String, dynamic>>  itemPlagas = selectMap.plagasCacao();
    final Map radios = {};
    void radioGroupKeys(){
        for(int i = 0 ; i < itemPlagas.length ; i ++){
            
        radios[itemPlagas[i]['value']] = '-1';
        }
    }



    @override
    void initState() {
        super.initState();
        radioGroupKeys();
    }

    @override
    Widget build(BuildContext context) {

        List data = ModalRoute.of(context).settings.arguments;
        
        paso.idTest = data[1];
        paso.caminata = data[0] ;
        countPlanta = data[2]+1;
        
        //return Scaffold();
        return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(),
            body: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.all(15.0),
                    child: Form(
                        key: formKey,
                        child: Column(
                            children: <Widget>[
                                TitulosPages(titulo: 'Planta $countPlanta caminata ${paso.caminata}'),
                                Divider(),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                            Expanded(child: Text('Lista Plagas', style: Theme.of(context).textTheme.headline6
                                                            .copyWith(fontSize: 16, fontWeight: FontWeight.w600))),
                                            Container(
                                                width: 50,
                                                child: Text('Si', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                                                .copyWith(fontSize: 16, fontWeight: FontWeight.w600,) ),
                                            ),
                                            Container(
                                                width: 50,
                                                child: Text('No', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                                                .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                            ),
                                        ],
                                    ),
                                ),
                                Divider(),
                                _plagasList(),
                                Divider(),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                        Expanded(child: Container(),),
                                        Container(
                                            width: 50,
                                            child: Text('Alta', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                            .copyWith(fontSize: 16, fontWeight: FontWeight.w600))
                                            //color: Colors.deepPurple,
                                        ),
                                        Container(
                                            width: 50,
                                            child: Text('Media', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                            .copyWith(fontSize: 16, fontWeight: FontWeight.w600))
                                            //color: Colors.deepPurple,
                                        ),
                                        Container(
                                            width: 50,
                                            child: Text('Baja', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6
                                            .copyWith(fontSize: 16, fontWeight: FontWeight.w600))
                                        ),
                                    ],
                                ),
                                Divider(),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 30.0),
                                    child: _botonsubmit()
                                )
                            ],
                        ),
                    ),
                ),
            )

        );
    }


    Widget _plagasList(){

        return ListView.builder(
            
            itemBuilder: (BuildContext context, int index) {
                
                String labelPlaga = itemPlagas.firstWhere((e) => e['value'] == '$index', orElse: () => {"value": "1","label": "No data"})['label'];
                int idPlaga = int.parse(itemPlagas.firstWhere((e) => e['value'] == '$index', orElse: () => {"value": "100","label": "No data"})['value']);
                
                
                
                return Column(
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                                Expanded(child: Text('$labelPlaga', style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16, fontWeight: FontWeight.w600))),
                                Transform.scale(
                                    scale: 1.2,
                                    child: Radio(
                                        value: '1',
                                        groupValue: radios[itemPlagas[idPlaga]['value']],
                                        onChanged: (value){
                                            setState(() {
                                                radios[itemPlagas[idPlaga]['value']] = value;
                                            });
                                        },
                                        activeColor: Colors.teal[900],
                                    ),
                                ),
                                Transform.scale(
                                    scale: 1.2,
                                    child: Radio(
                                        value:'2',
                                        groupValue: radios[itemPlagas[idPlaga]['value']],
                                        onChanged: (value){
                                            setState(() {
                                                radios[itemPlagas[idPlaga]['value']] = value;
                                            });
                                        },
                                        activeColor: Colors.red[900],
                                    ),
                                ),
                            

                            ],
                        ),
                        Divider()
                    ],
                );
        
            },
            shrinkWrap: true,
            itemCount: itemPlagas.length,
            physics: NeverScrollableScrollPhysics(),
        );
        
    }



    Widget  _botonsubmit(){
        return RaisedButton.icon(
            icon:Icon(Icons.save, color: Colors.white,),
            
            label: Text('Guardar',
                style: Theme.of(context).textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
            ),
            padding:EdgeInsets.symmetric(vertical: 13, horizontal: 50),
            onPressed:(_guardando) ? null : _submit,
        );
    }


    _listaPlagas(){

        radios.forEach((key, value) {
            final EnContacto itemPiso = EnContacto();
            itemPiso.id = uuid.v1();
            itemPiso.idPlanta = paso.id;
            itemPiso.idPlaga = int.parse(key);
            itemPiso.existe = int.parse(value);


            listaPlagas.add(itemPiso);
        });
        
    }

    void _submit(){
        variableVacias = 0;
        radios.forEach((key, value) {
            if (value == '-1') {
                variableVacias ++;
            } 
        });




        if  ( variableVacias !=  0){
            mostrarSnackbar(variableVacias);
            return null;
        }

        setState(() {_guardando = true;});

        
        if(paso.id == null){
            paso.id =  uuid.v1();
            _listaPlagas();
            fincasBloc.addPlata(paso, paso.idTest, paso.caminata);

            listaPlagas.forEach((item) {
                DBProvider.db.nuevoExistePlagas(item);
            });

        }
         
        setState(() {_guardando = false;});

        Navigator.pop(context, 'estaciones');
       
        
    }


    void mostrarSnackbar(int variableVacias){
        final snackbar = SnackBar(
            content: Text('Hay $variableVacias Campos Vacios, Favor llene todo los campos',
                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
        );
        setState(() {_guardando = false;});
        scaffoldKey.currentState.showSnackBar(snackbar);
    }


}