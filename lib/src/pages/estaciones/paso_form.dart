import 'package:app_piso/src/bloc/fincas_bloc.dart';
import 'package:app_piso/src/models/enContacto_model.dart';
import 'package:app_piso/src/models/paso_model.dart';

import 'package:app_piso/src/models/selectValue.dart' as selectMap;
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/widget/button.dart';
import 'package:app_piso/src/utils/widget/varios_widget.dart';
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
    int? countPlanta = 0;
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

        List data = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
        
        paso.idTest = data[1];
        paso.caminata = data[0] ;
        countPlanta = data[2]+1;
        
        //return Scaffold();
        return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(title: Text('Paso $countPlanta Caminata ${paso.caminata}'),),
            body: SingleChildScrollView(
                child: Container(
                    child: Form(
                        key: formKey,
                        child: Column(
                            children: <Widget>[
                                SizedBox(height: 10,),
                                tituloCard('Punta de zapato en contacto con :'),
                                _malezaList(),
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


    Widget _malezaList(){
        List<Widget> listaContacto = [];

        listaContacto.add(
            _tituloLista('Malezas dañinas'),
        );

        for (var item in itemEnContato) {
            String labelPlaga = itemEnContato.firstWhere((e) => e['value'] == '${item['value']}', orElse: () => {"value": "1","label": "No data"})['label'];
            int idContacto = int.parse(itemEnContato.firstWhere((e) => e['value'] == '${item['value']}', orElse: () => {"value": "100","label": "No data"})['value']);

            if (item['value'] == '7') {
                listaContacto.add(
                    _tituloLista('Coberturas vivas'),
                );
            } else if(item['value'] == '9'){
                listaContacto.add(
                    _tituloLista('Coberturas muertas'),
                );
            }

            listaContacto.add(
                CheckboxListTile(
                    title: textoCardBody(labelPlaga),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    value: (radios[itemEnContato[idContacto]['value']] == '1') ? true : false,
                    onChanged: (value){
                        setState(() {
                            radioGroupKeys();
                            radios[itemEnContato[idContacto]['value']] = value! ? '1' : '2';
                            
                        });
                    }
                )
            );
        }

        return Column(children: listaContacto,);
        
    }

    Widget _tituloLista(String? texto){
        return Column(
            children: [
                Divider(),
                tituloCard(texto!),
                Divider()
            ],
        );
    }



    Widget  _botonsubmit(){
        return ButtonMainStyle(
            title: 'Guardar',
            icon: Icons.save,
            press:(_guardando) ? null : _submit,
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

        variableVacias = 0;
        radios.forEach((key, value) {
            if (value == '2') {
                variableVacias ++;
            } 
        });
        if  ( variableVacias ==  radios.length){
            mostrarSnackbar('Selección vacía, favor seleccione un item.', context);
            return null;
        }
        
        setState(() {_guardando = true;});
        
        
        if(paso.id == null){
            paso.id =  uuid.v1();
            _listaPlagas();
            fincasBloc.addPlata(paso, paso.idTest, paso.caminata);

            listaPlagas.forEach((item) {
                DBProvider.db.nuevoEnContacto(item);
                
            });

        }
        mostrarSnackbar('Registro paso guardado', context);
        setState(() {_guardando = false;});

        Navigator.pop(context, 'pasos');
       
        
    }

    

   


}