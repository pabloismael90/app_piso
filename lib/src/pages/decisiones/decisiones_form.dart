import 'package:app_piso/src/models/acciones_model.dart';
import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/finca_model.dart';
import 'package:app_piso/src/models/paso_model.dart';
import 'package:app_piso/src/models/selectValue.dart' as selectMap;
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/pages/finca/finca_page.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:uuid/uuid.dart';

class DesicionesPage extends StatefulWidget {
    DesicionesPage({Key? key}) : super(key: key);

    @override
    _DesicionesPageState createState() => _DesicionesPageState();
}

class _DesicionesPageState extends State<DesicionesPage> {


    Decisiones decisiones = Decisiones();
    Acciones acciones = Acciones();
    List<Decisiones> listaDecisiones = [];
    List<Acciones> listaAcciones = [];
    String? idPlagaMain = "";
    bool _guardando = false;
    var uuid = Uuid();
    
    final List<Map<String, dynamic>>  itemEnContato = selectMap.itemContacto();
    final List<Map<String, dynamic>>  hierbaProblematica = selectMap.hierbaProblematica();
    final List<Map<String, dynamic>>  itemCompetencia = selectMap.competenciaHierba();
    final List<Map<String, dynamic>>  itemValoracion = selectMap.valoracionCobertura();
    final List<Map<String, dynamic>>  itemObsSuelo = selectMap.observacionSuelo();
    final List<Map<String, dynamic>>  itemObsSombra = selectMap.observacionSombra();
    final List<Map<String, dynamic>>  itemObsManejo = selectMap.observacionManejo();
    final List<Map<String, dynamic>>  _meses = selectMap.listMeses();
    final List<Map<String, dynamic>>  listSoluciones = selectMap.solucionesXmes();

    Widget textFalse = Text('0.00%', textAlign: TextAlign.center);

    final Map checkhierbaProblema = {};
    final Map checksCompetencia = {};
    final Map checksValoracion = {};
    final Map checksObsSuelo = {};
    final Map checksObsSombra = {};
    final Map checksObsManejo = {};
    final Map itemActividad = {};
    final Map itemResultado = {};

    void checkKeys(){

        for(int i = 0 ; i < hierbaProblematica.length ; i ++){
            checkhierbaProblema[hierbaProblematica[i]['value']] = false;
        }
        for(int i = 0 ; i < itemCompetencia.length ; i ++){
            checksCompetencia[itemCompetencia[i]['value']] = false; 
        }
        for(int i = 0 ; i < itemValoracion.length ; i ++){
            checksValoracion[itemValoracion[i]['value']] = false;
        }
        for(int i = 0 ; i < itemObsSuelo.length ; i ++){
            checksObsSuelo[itemObsSuelo[i]['value']] = false;
        }

        for(int i = 0 ; i < itemObsSombra.length ; i ++){
            checksObsSombra[itemObsSombra[i]['value']] = false;
        }
        for(int i = 0 ; i < itemObsManejo.length ; i ++){
            checksObsManejo[itemObsManejo[i]['value']] = false;
        }
        for(int i = 0 ; i < listSoluciones.length ; i ++){
            itemActividad[i] = [];
            itemResultado[i] = '';
        }

    }
    


    final formKey = new GlobalKey<FormState>();

   
    
    Future<double> _countPercentTotal(String? idTest,int idPlaga) async{
        double countPalga = await DBProvider.db.countPisoTotal(idTest, idPlaga);
        //print(countPalga);        
        return countPalga*100;
    }
    Future<double> _countTotalCompetencia(String? idTest,int idPlaga) async{
        double countPalga = await DBProvider.db.countCompetencia(idTest, idPlaga);        
        return countPalga*100;
    }
    Future<double> _countTotalNoCompetencia(String? idTest,int idPlaga) async{
        double countPalga = await DBProvider.db.countNoCompetencia(idTest, idPlaga);        
        return countPalga*100;
    }

    
    @override
    void initState() {
        super.initState();
        checkKeys();
    }


    @override
    Widget build(BuildContext context) {
        TestPiso? plagaTest = ModalRoute.of(context)!.settings.arguments as TestPiso?;
        
       
        Future _getdataFinca() async{
            Finca? finca = await DBProvider.db.getFincaId(plagaTest!.idFinca);
            Parcela? parcela = await DBProvider.db.getParcelaId(plagaTest.idLote);
            List<Paso> pasos = await DBProvider.db.getTodasPasoIdTest(plagaTest.id);
            return [finca, parcela, pasos];
        }

        

        return Scaffold(
            appBar: AppBar(title: Text('Toma de Decisiones'),),
            body: FutureBuilder(
                future: _getdataFinca(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    List<Widget> pageItem = [];
                    Finca finca = snapshot.data[0];
                    Parcela parcela = snapshot.data[1];
                    
                    pageItem.add(_principalData(finca, parcela, plagaTest!.id));
                    pageItem.add(_hierbasProblematicas());   
                    pageItem.add(_competeciaValoracion());  
                    pageItem.add(_observaciones());   
                    pageItem.add(_obsManejo());   
                    pageItem.add(_accionesMeses());   
                    pageItem.add(_botonsubmit(plagaTest.id));   

                    return Column(
                        children: [
                            mensajeSwipe('Deslice hacia la izquierda para continuar con el formulario'),
                            Expanded(
                                
                                child: Swiper(
                                    itemBuilder: (BuildContext context, int index) {
                                        return pageItem[index];
                                    },
                                    itemCount: pageItem.length,
                                    viewportFraction: 1,
                                    loop: false,
                                    scale: 1,
                                ),
                            ),
                        ],
                    );

                        
                },
            ),
            
            
        );
    }

    Widget _principalData(Finca finca, Parcela parcela, String? plagaid){
    
                return Column(
                    children: [
                        _dataFincas( context, finca, parcela),

                        Expanded(
                            child: SingleChildScrollView(
                                child: Column(
                                    children: [
                                        Container(
                                            padding: EdgeInsets.symmetric(vertical: 10),
                                            child: InkWell(
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                        Container(                                                                    
                                                            child: Text(
                                                                "Porcentaje de cobertura",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                                                            ),
                                                        ),
                                                        Padding(
                                                            padding: EdgeInsets.only(left: 10),
                                                            child: Icon(
                                                                Icons.info_outline_rounded,
                                                                color: Colors.green,
                                                                size: 20,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                onTap: () => _dialogText(context),
                                            ),
                                        ),
                                        Divider(),
                                        Container(
                                            child: Column(
                                                children: [
                                                     Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                            Expanded(
                                                                child: Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                                                                    child: Text('Estado de piso', textAlign: TextAlign.start, style: Theme.of(context).textTheme.headline6!
                                                                                            .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                                                ),
                                                            ),
                                                            
                                                            Container(
                                                                width: 100,
                                                                child: Text('Cobertura', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6!
                                                                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            ),
                                                        ],
                                                    ),
                                                    Divider(),
                                                    _countPlagas(plagaid, 1),
                                                ],
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        )
                        
                    ],
                );
                

            
    }

    Widget _dataFincas( BuildContext context, Finca finca, Parcela parcela ){
        String? labelMedidaFinca;
        String? labelvariedad;

        labelMedidaFinca = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca.tipoMedida}')['label'];
        labelvariedad = selectMap.variedadCacao().firstWhere((e) => e['value'] == '${parcela.variedadCacao}')['label'];

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                encabezadoCard('${finca.nombreFinca}','Parcela: ${parcela.nombreLote}', ''),
                textoCardBody('Productor: ${finca.nombreProductor}'),
                tecnico('${finca.nombreTecnico}'),
                textoCardBody('Variedad: $labelvariedad'),
                Wrap(
                    spacing: 20,
                    children: [
                        textoCardBody('Área Finca: ${finca.areaFinca} ($labelMedidaFinca)'),
                        textoCardBody('Área Parcela: ${parcela.areaLote} ($labelMedidaFinca)'),
                        textoCardBody('N de plantas: ${parcela.numeroPlanta}'),
                    ],
                ),
            ],  
        );

    }
    
    
    Widget _titulosTabla(String titulo){
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(titulo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6!
                          .copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Divider()
            ],
        );
    }
    
    
    
    Widget _countPlagas(String? idTest, int caminata){
        List<Widget> lisItem = [];

        for (var i = 0; i < itemEnContato.length; i++) {
            String? labelPlaga = itemEnContato.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            int idplga = int.parse(itemEnContato.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "100","label": "No data"})['value']);
            
            

            if (idplga == 5) {
                   lisItem.add(_countCompetencia(idTest,idplga, labelPlaga));
            }else if(idplga == 9){
                lisItem.add(_countNoCompetencia(idTest,idplga, labelPlaga));
            }else if(idplga == 10){
                lisItem.add(_sueloDesnudo(idTest,idplga, labelPlaga));
            }else{
                if (idplga == 0) {
                    lisItem.add(_titulosTabla('Maleza potencialmente dañinos'));
                }
                if (idplga == 6) {
                    lisItem.add(_titulosTabla('Malezas de cobertura nobles'));
                }
                if (idplga == 8) {
                    lisItem.add(_titulosTabla('Mulch de maleza'));
                }


                lisItem.add(
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            Expanded(
                                child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text('$labelPlaga', 
                                    textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold, color: (i <= 5) ? Colors.red : Colors.green[900]) ,),
                                ),
                            ),
                            Container(
                                width: 50,
                                
                                child: FutureBuilder(
                                    future: _countPercentTotal(idTest, idplga),
                                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                                        if (!snapshot.hasData) {
                                            return textFalse;
                                        }

                                        return Text('${snapshot.data.toStringAsFixed(2)}%', 
                                        textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold, color: (i <= 5) ? Colors.red : Colors.green[900]));
                                    },
                                ),
                            ),
                            Container(width: 50,),
                            
                        ],
                    )
                );
            }
                        
            lisItem.add(Divider());
        }
        return Column(children:lisItem,);
    }
    

    Widget _countCompetencia(String? idTest, int idplga, String? labelPlaga){
        return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('$labelPlaga', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.red) ,),
                    ),
                ),
                Container(
                    width: 50,
                    child: FutureBuilder(
                        future: _countPercentTotal(idTest, idplga),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return Text('${snapshot.data.toStringAsFixed(2)}%', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
                        },
                    ),
                ),
                Container(
                    width: 50,
                    child: FutureBuilder(
                        future: _countTotalCompetencia(idTest, idplga),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return Text('${snapshot.data.toStringAsFixed(2)}%', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.red));
                        },
                    ),
                ),
                
            ],
        );
    }

    Widget _countNoCompetencia(String? idTest, int idplga, String? labelPlaga){
        return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('$labelPlaga', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]) ,),
                    ),
                ),
                Container(
                    width: 50,
                    child: FutureBuilder(
                        future: _countPercentTotal(idTest, idplga),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return Text('${snapshot.data.toStringAsFixed(2)}%', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]));
                        },
                    ),
                ),
                Container(
                    width: 50,
                    child: FutureBuilder(
                        future: _countTotalNoCompetencia(idTest, idplga),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return Text('${snapshot.data.toStringAsFixed(2)}%', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900]));
                        },
                    ),
                ),
                
            ],
        );
    }

    Widget _sueloDesnudo(String? idTest, int idplga, String? labelPlaga){
        return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('$labelPlaga', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.brown) ,),
                    ),
                ),
                Container(
                    width: 50,
                    child: FutureBuilder(
                        future: _countPercentTotal(idTest, idplga),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return Text('${snapshot.data.toStringAsFixed(2)}%', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold, color: Colors.brown));
                        },
                    ),
                ),
                Container(width: 50,),
                
            ],
        );
    }


    Widget _hierbasProblematicas(){
        List<Widget> listHierbaProblema = [];

        listHierbaProblema.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Hierbas que consideran problematicas",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );

        for (var i = 0; i < hierbaProblematica.length; i++) {
            String? labelPlaga = hierbaProblematica.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
            listHierbaProblema.add(

                CheckboxListTile(
                    title: Text('$labelPlaga',
                        style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16),
                    ),
                    value: checkhierbaProblema[hierbaProblematica[i]['value']], 
                    onChanged: (value) {
                        setState(() {
                            checkhierbaProblema[hierbaProblematica[i]['value']] = value;
                            //print(value);
                        });
                    },
                )                  
                    
            );
        }
        
        return SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Column(children:listHierbaProblema,)
            ),
        );
    }

    Widget _competeciaValoracion(){
        List<Widget> listCompValora = [];

        listCompValora.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Competencia entre hierbas y cacao",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        
        for (var i = 0; i < itemCompetencia.length; i++) {
            String? labelSituacion = itemCompetencia.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
                        
            listCompValora.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelSituacion',
                            style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 16),
                        ),
                        value: checksCompetencia[itemCompetencia[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksCompetencia[itemCompetencia[i]['value']] = value;
                                //print(value);
                            });
                        },
                    ),
                )                  
                    
            );
        }

        listCompValora.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Valoración de cobertura del piso",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        
        for (var i = 0; i < itemValoracion.length; i++) {
            String? labelProblemaSuelo = itemValoracion.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            listCompValora.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelProblemaSuelo'),
                        value: checksValoracion[itemValoracion[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksValoracion[itemValoracion[i]['value']] = value;
                                //print(value);
                            });
                        },
                    ),
                )                  
                    
            );
        }
        
        return SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Column(children:listCompValora,)
            ),
        );
    }

    Widget _observaciones(){
        List<Widget> listObservaciones = [];

        listObservaciones.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Observaciones de suelo",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        

        for (var i = 0; i < itemObsSuelo.length; i++) {
            String? labelProblemaSombra = itemObsSuelo.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listObservaciones.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelProblemaSombra'),
                        value: checksObsSuelo[itemObsSuelo[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksObsSuelo[itemObsSuelo[i]['value']] = value;
                                //print(value);
                            });
                        },
                    ),
                )                  
                    
            );
        }

        listObservaciones.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Observaciones de sombra",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        

        for (var i = 0; i < itemObsSombra.length; i++) {
            String? labelProblemaManejo = itemObsSombra.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listObservaciones.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelProblemaManejo'),
                        value: checksObsSombra[itemObsSombra[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksObsSombra[itemObsSombra[i]['value']] = value;
                                //print(value);
                            });
                        },
                    ),
                )
            );
        }
        
        return SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Column(children:listObservaciones,)
            ),
        );
    }

    Widget _obsManejo(){
        List<Widget> listObsManejo = [];

        listObsManejo.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Observaciones de manejo",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        

        for (var i = 0; i < itemObsManejo.length; i++) {
            String? labelProblemaManejo = itemObsManejo.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            listObsManejo.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelProblemaManejo'),
                        value: checksObsManejo[itemObsManejo[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksObsManejo[itemObsManejo[i]['value']] = value;
                                //print(value);
                            });
                        },
                    ),
                )
            );
        }

        return SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Column(children:listObsManejo,)
            ),
        );
    }

    Widget _accionesMeses(){

        List<Widget> listaAcciones = [];
        listaAcciones.add(
            
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "¿Qué acciones vamos a realizar y cuando?",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < listSoluciones.length; i++) {
            String? labelSoluciones = listSoluciones.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
            listaAcciones.add(
                Container(
                    padding: EdgeInsets.all(16),
                    child: MultiSelectFormField(
                        autovalidate: false,
                        chipBackGroundColor: Colors.deepPurple,
                        chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                        dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
                        checkBoxActiveColor: Colors.deepPurple,
                        checkBoxCheckColor: Colors.white,
                        dialogShapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0))
                        ),
                        title: Text(
                            "$labelSoluciones",
                            style: TextStyle(fontSize: 16),
                        ),
                        validator: (value) {
                            if (value == null || value.length == 0) {
                            return 'Seleccione una o mas opciones';
                            }
                            return null;
                        },
                        dataSource: _meses,
                        textField: 'label',
                        valueField: 'value',
                        okButtonLabel: 'Aceptar',
                        cancelButtonLabel: 'Cancelar',
                        hintWidget: Text('Seleccione una o mas meses'),
                        initialValue: itemActividad[i],
                        onSaved: (value) {
                            if (value == null) return;
                                setState(() {
                                itemActividad[i] = value;
                            });
                        },
                    ),
                )
            );
        }

        return SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Column(children:listaAcciones,)
            ),
        );
    }


    Widget  _botonsubmit(String? idplaga){
        idPlagaMain = idplaga;
        return SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Column(
                    children: [
                        Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 30),
                            child: Text(
                                "¿Ha Terminado todos los formularios de toma de desición?",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.w600)
                            ),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60),
                            child: RaisedButton.icon(
                                icon:Icon(Icons.save),
                                label: Text('Guardar',
                                    style: Theme.of(context).textTheme
                                        .headline6!
                                        .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
                                ),
                                padding:EdgeInsets.all(13),
                                onPressed:(_guardando) ? null : _submit,
                                
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    _listaDecisiones(Map checksPreguntas, int pregunta){
       
        checksPreguntas.forEach((key, value) {
            final Decisiones itemDesisiones = Decisiones();
            itemDesisiones.id = uuid.v1();
            itemDesisiones.idPregunta = pregunta;
            itemDesisiones.idItem = int.parse(key);
            itemDesisiones.repuesta = value ? 1 : 0;
            itemDesisiones.idTest = idPlagaMain;

            listaDecisiones.add(itemDesisiones);
        });
    }

    _listaAcciones(){

        //print(itemActividad);
        itemActividad.forEach((key, value) {
            final Acciones itemAcciones = Acciones();
            itemAcciones.id = uuid.v1();
            itemAcciones.idItem = key;
            itemAcciones.repuesta = value.toString();
            itemAcciones.idTest = idPlagaMain;
            
            listaAcciones.add(itemAcciones);
        });
    }

    void _submit(){
        setState(() {_guardando = true;});
        _listaDecisiones(checkhierbaProblema, 1);
        _listaDecisiones(checksCompetencia, 2);
        _listaDecisiones(checksValoracion, 3);
        _listaDecisiones(checksObsSuelo, 4);
        _listaDecisiones(checksObsSombra, 5);
        _listaDecisiones(checksObsManejo, 6);
        _listaAcciones();

        listaDecisiones.forEach((decision) {
        //     print("Id Pregunta: ${element.idPregunta}");
        //     print("Id item: ${element.idItem}");
        //     print("Id Respues: ${element.repuesta}");
        //     print("Id prueba: ${element.idTest}");
            DBProvider.db.nuevaDecision(decision);
        });

        
        
        listaAcciones.forEach((accion) {
        //     print("Id item: ${element.idItem}");
        //     print("Id Respues: ${element.repuesta}");
        //     print("Id prueba: ${element.idTest}");
            DBProvider.db.nuevaAccion(accion);
        });
        fincasBloc.obtenerDecisiones(idPlagaMain);
        setState(() {_guardando = false;});

        Navigator.pop(context, 'estaciones');
    }

}

Future<void> _dialogText(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Titulo'),
                content: SingleChildScrollView(
                    child: ListBody(
                        children: <Widget>[
                        Text('Texto para breve explicacion'),
                        ],
                    ),
                ),
                actions: <Widget>[
                    TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                        Navigator.of(context).pop();
                        },
                    ),
                ],
            );
        },
    );
}