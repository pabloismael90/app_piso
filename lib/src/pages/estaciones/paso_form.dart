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
    
    final List<Map<String, dynamic>>  itemEnContato = selectMap.itemContacto();
    final Map radios = {};
    void radioGroupKeys(){
        for(int i = 0 ; i < itemEnContato.length ; i ++){
            
        radios[itemEnContato[i]['value']] = '2';
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
                                TitulosPages(titulo: 'Paso $countPlanta Caminata ${paso.caminata}'),
                                Divider(),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('Punta de zapato en contacto con :', style: Theme.of(context).textTheme.headline6
                                                .copyWith(fontSize: 16, fontWeight: FontWeight.w600))
                                ),
                                Divider(),
                                _plagasList(),
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
                
                String labelPlaga = itemEnContato.firstWhere((e) => e['value'] == '$index', orElse: () => {"value": "1","label": "No data"})['label'];
                int idPlaga = int.parse(itemEnContato.firstWhere((e) => e['value'] == '$index', orElse: () => {"value": "100","label": "No data"})['value']);
                
                return CheckboxListTile(
                    title: Text(labelPlaga, style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                    value: (radios[itemEnContato[idPlaga]['value']] == '1') ? true : false,
                    onChanged: (value){
                        setState(() {
                            //print(value);
                            radios[itemEnContato[idPlaga]['value']] = value ? '1' : '2';
                            print(radios[itemEnContato[idPlaga]['value']]);
                        });
                    }

                );
        
            },
            shrinkWrap: true,
            itemCount: itemEnContato.length,
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
            itemPiso.idPaso = paso.id;
            itemPiso.idContacto = int.parse(key);
            itemPiso.existe = int.parse(value);


            listaPlagas.add(itemPiso);
        });
        
    }

    void _submit(){
        
        setState(() {_guardando = true;});

        
        if(paso.id == null){
            paso.id =  uuid.v1();
            _listaPlagas();
            fincasBloc.addPlata(paso, paso.idTest, paso.caminata);

            listaPlagas.forEach((item) {
                DBProvider.db.nuevoEnContacto(item);
            });

        }
         
        setState(() {_guardando = false;});

        Navigator.pop(context, 'pasos');
       
        
    }


   


}