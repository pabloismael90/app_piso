import 'package:app_piso/src/models/acciones_model.dart';
import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/finca_model.dart';
import 'package:app_piso/src/models/paso_model.dart';
import 'package:app_piso/src/models/selectValue.dart' as selectMap;
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/pages/finca/finca_page.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:uuid/uuid.dart';

class DesicionesPage extends StatefulWidget {
    DesicionesPage({Key key}) : super(key: key);

    @override
    _DesicionesPageState createState() => _DesicionesPageState();
}

class _DesicionesPageState extends State<DesicionesPage> {


    Decisiones decisiones = Decisiones();
    Acciones acciones = Acciones();
    List<Decisiones> listaDecisiones = [];
    List<Acciones> listaAcciones = [];
    String idPlagaMain = "";
    bool _guardando = false;
    var uuid = Uuid();
    
    final List<Map<String, dynamic>>  itemEnContato = selectMap.itemContacto();
    final List<Map<String, dynamic>>  hierbaProblematica = selectMap.hierbaProblematica();
    final List<Map<String, dynamic>>  itemSituacion = selectMap.situacionPlaga();
    final List<Map<String, dynamic>>  itemProbSuelo = selectMap.problemasPlagaSuelo();
    final List<Map<String, dynamic>>  itemProbSombra = selectMap.problemasPlagaSombra();
    final List<Map<String, dynamic>>  itemProbManejo = selectMap.problemasPlagaManejo();
    final List<Map<String, dynamic>>  _meses = selectMap.listMeses();
    final List<Map<String, dynamic>>  listSoluciones = selectMap.solucionesXmes();

    Widget textFalse = Text('0.00%', textAlign: TextAlign.center);
    final Map checksPrincipales = {};
    final Map checkhierbaProblema = {};
    final Map checksSituacion = {};
    final Map checksSuelo = {};
    final Map checksSombra = {};
    final Map checksManejo = {};
    final Map itemActividad = {};
    final Map itemResultado = {};

    void checkKeys(){
        for(int i = 0 ; i < itemEnContato.length ; i ++){
            checksPrincipales[itemEnContato[i]['value']] = false;
        }
        for(int i = 0 ; i < hierbaProblematica.length ; i ++){
            checkhierbaProblema[hierbaProblematica[i]['value']] = false;
        }
        for(int i = 0 ; i < itemSituacion.length ; i ++){
            checksSituacion[itemSituacion[i]['value']] = false; 
        }
        for(int i = 0 ; i < itemProbSuelo.length ; i ++){
            checksSuelo[itemProbSuelo[i]['value']] = false;
        }
        for(int i = 0 ; i < itemProbSombra.length ; i ++){
            checksSombra[itemProbSombra[i]['value']] = false;
        }

        for(int i = 0 ; i < itemProbManejo.length ; i ++){
            checksManejo[itemProbManejo[i]['value']] = false;
        }
        for(int i = 0 ; i < listSoluciones.length ; i ++){
            itemActividad[i] = [];
            itemResultado[i] = '';
        }

    }
    


    final formKey = new GlobalKey<FormState>();

   
    
    Future<double> _countPercentTotal(String idTest,int idPlaga) async{
        double countPalga = await DBProvider.db.countPisoTotal(idTest, idPlaga);
        //print(countPalga);        
        return countPalga*100;
    }

    
    @override
    void initState() {
        super.initState();
        checkKeys();
    }


    @override
    Widget build(BuildContext context) {
        TestPiso plagaTest = ModalRoute.of(context).settings.arguments;
        
       
        Future _getdataFinca() async{
            Finca finca = await DBProvider.db.getFincaId(plagaTest.idFinca);
            Parcela parcela = await DBProvider.db.getParcelaId(plagaTest.idLote);
            List<Paso> pasos = await DBProvider.db.getTodasPasoIdTest(plagaTest.id);
            return [finca, parcela, pasos];
        }

        

        return Scaffold(
            appBar: AppBar(),
            body: FutureBuilder(
                future: _getdataFinca(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    List<Widget> pageItem = List<Widget>();
                    Finca finca = snapshot.data[0];
                    Parcela parcela = snapshot.data[1];
                    
                    pageItem.add(_principalData(finca, parcela, plagaTest.id));
                    pageItem.add(_plagasPrincipales());   
                    pageItem.add(_situacionPlaga());   
                    pageItem.add(_problemasSuelo());   
                    pageItem.add(_problemasSombra());   
                    pageItem.add(_problemasManejo());   
                    pageItem.add(_accionesMeses());   
                    pageItem.add(_botonsubmit(plagaTest.id));   

                    return Column(
                        children: [
                            Container(
                                child: Column(
                                    children: [
                                        TitulosPages(titulo: 'Toma de Decisiones'),
                                        Divider(),
                                        Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10),
                                            child: Text(
                                                "Deslice hacia la derecha para continuar con el formulario",
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme
                                                    .headline5
                                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 16)
                                            ),
                                        ),
                                    ],
                                )
                            ),
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

    Widget _principalData(Finca finca, Parcela parcela, String plagaid){
    
                return Container(
                    decoration: BoxDecoration(
                        
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                        children: [
                            _dataFincas( context, finca, parcela),

                            Expanded(
                                child: SingleChildScrollView(
                                    child: Container(
                                        color: Colors.white,
                                        child: Column(
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 10),
                                                    child: InkWell(
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                                Container(                                                                    
                                                                    child: Text(
                                                                        "Porcentaje de cobertura",
                                                                        textAlign: TextAlign.center,
                                                                        style: Theme.of(context).textTheme
                                                                            .headline5
                                                                            .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                                                                    ),
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets.only(left: 10),
                                                                    child: Icon(
                                                                        Icons.info_outline_rounded,
                                                                        color: Colors.green,
                                                                        size: 22.0,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        onTap: () => _dialogText(context),
                                                    ),
                                                ),
                                                
                                                Container(
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
                                                    child: Column(
                                                        children: [
                                                            _countPlagas(plagaid, 1),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            )
                            
                        ],
                    ),
                );
                

            
    }

    Widget _dataFincas( BuildContext context, Finca finca, Parcela parcela ){
        String labelMedidaFinca;
        String labelvariedad;

        final item = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca.tipoMedida}');
        labelMedidaFinca  = item['label'];

        

        final itemvariedad = selectMap.variedadCacao().firstWhere((e) => e['value'] == '${parcela.variedadCacao}');
        labelvariedad  = itemvariedad['label'];

        return Container(
                    
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white,
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
                    
                    Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                            
                                Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                    child: Text(
                                        "${finca.nombreFinca}",
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context).textTheme.headline6,
                                    ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only( bottom: 10.0),
                                    child: Text(
                                        "${parcela.nombreLote}",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only( bottom: 10.0),
                                    child: Text(
                                        "Productor ${finca.nombreProductor}",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                ),

                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                        Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.only( bottom: 10.0),
                                                    child: Text(
                                                        "Área Finca: ${finca.areaFinca} ($labelMedidaFinca)",
                                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                    ),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only( bottom: 10.0),
                                                    child: Text(
                                                        "N de Plantas: ${parcela.numeroPlanta}",
                                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                    ),
                                                ),
                                            ],
                                        ),
                                        Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.only( bottom: 10.0, left: 20),
                                                    child: Text(
                                                        "Área Parcela: ${parcela.areaLote} ($labelMedidaFinca)",
                                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                    ),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only( bottom: 10.0, left: 20),
                                                    child: Text(
                                                        "Variedad: $labelvariedad ",
                                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                    ),
                                                ),
                                            ],
                                        )
                                    ],
                                )

                                
                            ],  
                        ),
                    ),
                ],
            ),
        );

    }
    
    

    Widget _countPlagas(String idTest, int estacion){
        List<Widget> lisItem = List<Widget>();

        for (var i = 0; i < itemEnContato.length; i++) {
            String labelPlaga = itemEnContato.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            int idplga = int.parse(itemEnContato.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "100","label": "No data"})['value']);
            //print(idTest);
            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text('$labelPlaga', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
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

                                    return Text('${snapshot.data.toStringAsFixed(0)}%', textAlign: TextAlign.center);
                                },
                            ),
                        ),
                        
                    ],
                )
            );
            lisItem.add(Divider());
        }
        return Column(children:lisItem,);
    }


    Widget _plagasPrincipales(){
        List<Widget> listHierbaProblema = List<Widget>();

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
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );

        for (var i = 0; i < hierbaProblematica.length; i++) {
            String labelPlaga = hierbaProblematica.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
            listHierbaProblema.add(

                CheckboxListTile(
                    title: Text('$labelPlaga',
                        style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
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

    Widget _situacionPlaga(){
        List<Widget> listSituacionPlaga = List<Widget>();

        listSituacionPlaga.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "Situación de las plagas en la parcela",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 20)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        

        for (var i = 0; i < itemSituacion.length; i++) {
            String labelSituacion = itemSituacion.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
            listSituacionPlaga.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelSituacion',
                            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16),
                        ),
                        value: checksSituacion[itemSituacion[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksSituacion[itemSituacion[i]['value']] = value;
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
                child: Column(children:listSituacionPlaga,)
            ),
        );
    }

    Widget _problemasSuelo(){
        List<Widget> listProblemasSuelo = List<Widget>();

        listProblemasSuelo.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "¿Porqué hay problemas de plagas?  Suelo",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 20)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        

        for (var i = 0; i < itemProbSuelo.length; i++) {
            String labelProblemaSuelo = itemProbSuelo.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
            listProblemasSuelo.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelProblemaSuelo'),
                        value: checksSuelo[itemProbSuelo[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksSuelo[itemProbSuelo[i]['value']] = value;
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
                child: Column(children:listProblemasSuelo,)
            ),
        );
    }

    Widget _problemasSombra(){
        List<Widget> listProblemasSombra = List<Widget>();

        listProblemasSombra.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "¿Porqué hay problemas de plagas?  Sombra",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 20)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        

        for (var i = 0; i < itemProbSombra.length; i++) {
            String labelProblemaSombra = itemProbSombra.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
            listProblemasSombra.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelProblemaSombra'),
                        value: checksSombra[itemProbSombra[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksSombra[itemProbSombra[i]['value']] = value;
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
                child: Column(children:listProblemasSombra,)
            ),
        );
    }

    Widget _problemasManejo(){
        List<Widget> listProblemasManejo = List<Widget>();

        listProblemasManejo.add(
            Column(
                children: [
                    Container(
                        child: Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                                "¿Porqué hay problemas de plagas?  Manejo",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 20)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        

        for (var i = 0; i < itemProbManejo.length; i++) {
            String labelProblemaManejo = itemProbManejo.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
            listProblemasManejo.add(

                Container(
                    child: CheckboxListTile(
                        title: Text('$labelProblemaManejo'),
                        value: checksManejo[itemProbManejo[i]['value']], 
                        onChanged: (value) {
                            setState(() {
                                checksManejo[itemProbManejo[i]['value']] = value;
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
                child: Column(children:listProblemasManejo,)
            ),
        );
    }

    Widget _accionesMeses(){

        List<Widget> listaAcciones = List<Widget>();
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
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 20)
                            ),
                        )
                    ),
                    Divider(),
                ],
            )
            
        );
        for (var i = 0; i < listSoluciones.length; i++) {
            String labelSoluciones = listSoluciones.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            
            
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


    Widget  _botonsubmit(String idplaga){
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
                                    .headline5
                                    .copyWith(fontWeight: FontWeight.w600)
                            ),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60),
                            child: RaisedButton.icon(
                                icon:Icon(Icons.save),
                                label: Text('Guardar',
                                    style: Theme.of(context).textTheme
                                        .headline6
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
        _listaDecisiones(checksPrincipales, 1);
        _listaDecisiones(checksSituacion, 2);
        _listaDecisiones(checksSuelo, 3);
        _listaDecisiones(checksSombra, 4);
        _listaDecisiones(checksManejo, 5);
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