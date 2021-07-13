import 'dart:convert';
import 'package:app_piso/src/models/acciones_model.dart';
import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/pages/pdf/pdf_api.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/models/selectValue.dart' as selectMap;
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';


class ReportePage extends StatefulWidget {


  @override
  _ReportePageState createState() => _ReportePageState();
}

class _ReportePageState extends State<ReportePage> {
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

    final Map checksPrincipales = {};

    
    

    Future getdata(String? idTest) async{

        List<Decisiones> listDecisiones = await DBProvider.db.getDecisionesIdTest(idTest);         
        List<Acciones> listAcciones= await DBProvider.db.getAccionesIdTest(idTest);
        TestPiso? testplaga = await (DBProvider.db.getTestId(idTest));

        Finca? finca = await DBProvider.db.getFincaId(testplaga!.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(testplaga.idLote);

        return [listDecisiones, listAcciones, finca, parcela];
    }

    
    
    Future<double> _countPercentTotal(String? idTest,int idPlaga) async{
        double countPalga = await DBProvider.db.countPisoTotal(idTest, idPlaga);         
        return countPalga*100;
    }

    Future<double> _countMalezaDanina(String? idTest) async{
        double countPalga = await DBProvider.db.malezaDanina(idTest);        
        return countPalga*100;
    }
    
    Future<double> _countMalezaNoble(String? idTest) async{
        double countPalga = await DBProvider.db.malezaNoble(idTest);        
        return countPalga*100;
    }

    Future<double> _countMulchMaleza(String? idTest) async{
        double countPalga = await DBProvider.db.mulchMaleza(idTest);        
        return countPalga*100;
    }


    

    @override
    Widget build(BuildContext context) {
        TestPiso? testPiso = ModalRoute.of(context)!.settings.arguments as TestPiso;

        return Scaffold(
            appBar: AppBar(
                title: Text('Reporte de Decisiones'),
                actions: [
                    TextButton(
                        
                        onPressed: () => _crearPdf(testPiso),
                        child: Row(
                            children: [
                                Icon(Icons.download, color: kwhite, size: 16,),
                                SizedBox(width: 5,),
                                Text('PDF', style: TextStyle(color: Colors.white),)
                            ],
                        )
                        
                    )
                ],
            ),
            body: FutureBuilder(
                future: getdata(testPiso.id),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    List<Widget> pageItem = [];
                    Finca finca = snapshot.data[2];
                    Parcela parcela = snapshot.data[3];

                    pageItem.add(_principalData(testPiso.id,context, finca, parcela));
                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:_generatePregunta(snapshot.data[0],'Hierbas que consideran problematicas', 1, hierbaProblematica ),
                            )
                        ) 
                    );

                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:[
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Competencia entre hierbas y cacao', 2, itemCompetencia ),
                                    ),
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Valoración de cobertura del piso', 3, itemValoracion ),
                                    )
                                ]
                            )
                        ) 
                    );
                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:[
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Observaciones de suelo', 4, itemObsSuelo ),
                                    ),
                                    Column(
                                        children:_generatePregunta(snapshot.data[0],'Observaciones de sombra', 5, itemObsSombra ),
                                    )
                                ]
                            )
                        ) 
                    );
                    pageItem.add(
                        SingleChildScrollView(
                            child: Column(
                                children:_generatePregunta(snapshot.data[0],'Observaciones de manejo', 6, itemObsManejo ),
                            )
                        )
                    );
                    pageItem.add( _accionesMeses(snapshot.data[1]));
                    
                    
                    return Column(
                        children: [
                            mensajeSwipe('Deslice hacia la izquierda para continuar con el reporte'),
                            Expanded(
                                
                                child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.all(15),
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
                            ),
                        ],
                    );
                },
            ),
        );
    }

    Widget _principalData(String? plagaid, BuildContext context, Finca finca, Parcela parcela){
    
         return Container(
            decoration: BoxDecoration(
                
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
                children: [
                    _dataFincas( context, finca, parcela),
                    Divider(),
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                                children: [
                                    Container(
                                        padding: EdgeInsets.symmetric(vertical: 3),
                                        child: InkWell(
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                    Container(                                                                    
                                                        child: Text(
                                                            "Datos consolidados",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                                                        ),
                                                    ),
                                                    Container(
                                                        padding: EdgeInsets.only(left: 10),
                                                        child: Icon(
                                                            Icons.info_outline_rounded,
                                                            color: Colors.green,
                                                            size: 20,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            onTap: () => _explicacion(context),
                                        ),
                                    ),
                                    Divider(),
                                    Column(
                                        children: [
                                            _tablaCobertura(plagaid, 1),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                    )
                ],
            ),
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
    
    Widget _encabezadoTabla(String? titulo){
        return Column(
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(child: tituloCard(titulo!)),
                        Container(
                            width: 80,
                            child: textoCardBody('Cobertura'),
                        ),
                    ],
                ),
                Divider()
            ],
        );
    }

    Widget _rowTabla(String? titulo, String? idTest, int? idplga, int? indice){
        return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Expanded(child: textoCardBody(titulo!)),
                Container(
                    width: 70,
                    child: FutureBuilder(
                        future: _countPercentTotal(idTest, idplga!),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return textoCardBody('${snapshot.data.toStringAsFixed(2)}%');
                            //return Text('${snapshot.data.toStringAsFixed(2)}%', 
                            //textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold, color: (indice! <= 6) ? Colors.red : Colors.green[900]));
                        },
                    ),
                ),
            ],
        );
    }
    
    Widget _tablaCobertura(String? idTest, int caminata){
        List<Widget> lisItem = [];

        lisItem.add(_encabezadoTabla('Maleza potencialmente dañinos'));

        for (var i = 0; i < itemEnContato.length; i++) {
            String? labelPlaga = itemEnContato.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            int idplga = int.parse(itemEnContato.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "100","label": "No data"})['value']);
            
            

            if (idplga == 6) {
                lisItem.add( _rowTabla(labelPlaga, idTest, idplga, i));
                lisItem.add(Divider());
                lisItem.add(_malezaDanina(idTest,idplga, labelPlaga));
                lisItem.add(SizedBox(height: 10,));
                lisItem.add(Divider());
                lisItem.add(_encabezadoTabla('Malezas de cobertura nobles'));
            }else if(idplga == 8){
                lisItem.add( _rowTabla(labelPlaga, idTest, idplga, i));
                lisItem.add(Divider());
                lisItem.add(_malezaNoble(idTest,idplga, labelPlaga));
                lisItem.add(SizedBox(height: 10,));
                lisItem.add(Divider());
                lisItem.add(_encabezadoTabla('Mulch de maleza'));
            }else if(idplga == 11){
                lisItem.add( _rowTabla(labelPlaga, idTest, idplga, i));
                lisItem.add(Divider());
                lisItem.add(_mulchMaleza(idTest,idplga, labelPlaga));
            }else{
                
               


                lisItem.add( _rowTabla(labelPlaga, idTest, idplga, i));

                    
            }
                        
        }
        return Column(children:lisItem,);
    }
    

    Widget _malezaDanina(String? idTest, int idplga, String? labelPlaga){
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                Expanded(child: subtituloCardBody('Total')),
                Container(
                    width: 70,
                    child: FutureBuilder(
                        future: _countMalezaDanina(idTest),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return subtituloCardBody('${snapshot.data.toStringAsFixed(2)}%');
                        },
                    ),
                    
                ),
            ],
        );
    }

    Widget _malezaNoble(String? idTest, int idplga, String? labelPlaga){
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                Expanded(child: subtituloCardBody('Total')),
                Container(
                    width: 70,
                    child: FutureBuilder(
                        future: _countMalezaNoble(idTest),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return subtituloCardBody('${snapshot.data.toStringAsFixed(2)}%');
                        },
                    ),
                ),
            ],
        );
    }

    Widget _mulchMaleza(String? idTest, int idplga, String? labelPlaga){
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                Expanded(child: subtituloCardBody('Total')),
                Container(
                    width: 70,
                    child: FutureBuilder(
                        future: _countMulchMaleza(idTest),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                                return textFalse;
                            }

                            return subtituloCardBody('${snapshot.data.toStringAsFixed(2)}%');
                        },
                    ),
                ),
            ],
        );
    }


    List<Widget> _generatePregunta(List<Decisiones> decisionesList, String? titulo, int idPregunta, List<Map<String, dynamic>>  listaItem){
        List<Widget> listWidget = [];
        List<Decisiones> listDecisiones = decisionesList.where((i) => i.idPregunta == idPregunta).toList();

        listWidget.add(
            Column(
                children: [
                    Container(
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                            titulo as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                        ),
                    ),
                    Divider(),
                ],
            )
            
        );
        
        
        for (var item in listDecisiones) {
                String? label= listaItem.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listWidget.add(

                    Container(
                        child: CheckboxListTile(
                        title: Text('$label',
                            style: TextStyle(fontSize: 14),
                        
                        ),
                            value: item.repuesta == 1 ? true : false ,
                            activeColor: Colors.teal[900], 
                            onChanged: (value) {
                                
                            },
                        ),
                    )                  
                    
                );
        }
        return listWidget;
    }


    Widget _accionesMeses(List<Acciones> listAcciones){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
            Column(
                children: [
                    Container(
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                            "¿Qué acciones vamos a realizar y cuando?",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                        ),
                    ),
                    Divider(),
                ],
            )
            
        );
        
        
        for (var item in listAcciones) {

                List<String?> meses = [];
                String? label= listSoluciones.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];
                List listaMeses = jsonDecode(item.repuesta!);
                if (listaMeses.length==0) {
                    meses.add('Sin aplicar');
                }
                for (var item in listaMeses) {
                    String? mes = _meses.firstWhere((e) => e['value'] == '$item', orElse: () => {"value": "1","label": "No data"})['label'];
                    
                    meses.add(mes);
                }
                

                listPrincipales.add(

                    ListTile(
                        title: Text('$label',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(meses.join(","+" ")),
                    )                 
                    
                );
            
            
            
            
        }
        return SingleChildScrollView(
            child: Column(children:listPrincipales,),
        );
    }


    Future _crearPdf( TestPiso testPiso ) async{
        
        Map<int,List>? listaMalezadanina = {};

        for (var item in itemEnContato) {
            int key = int.parse(item['value']);
            List<double?> valueItem =[
                await _countPercentTotal(testPiso.id, key)
            ];

            listaMalezadanina.putIfAbsent(key, () => valueItem);
          
        }

        List<double?> totales =[
            await _countMalezaDanina(testPiso.id),
            await _countMalezaNoble(testPiso.id),
            await _countMulchMaleza(testPiso.id),
        ];   
 

        
        final pdfFile = await PdfApi.generateCenteredText(testPiso, listaMalezadanina, totales);
        
        PdfApi.openFile(pdfFile);
    }

    Future<void> _explicacion(BuildContext context){

        return dialogText(
            context,
            Column(
                children: [
                    textoCardBody('•	La tabla de composición del piso presenta % cobertura de diferentes tipos de hierbas determinadas por la frecuencia de observación de cada tipo de maleza en relación a número total de pasos realizados en las tres caminatas.'),
                    textoCardBody('•	En la primera sección se presenta porcentaje de área cubierta con malas hierbas dañinas: Zacate anual, Zacate perenne, Hoja ancha anual, Hoja ancha perenne, Coyolillo y Bejucos en suelo. Se presenta % de cobertura de cada tipo de malas hierbas y la suma de ellas.'),
                    textoCardBody('•	En la segunda sección se presenta porcentaje de área cubierta con las hierbas de cobertura: Cobertura hoja ancha y Cobertura hoja angosta. Se presenta % de cobertura de cada tipo de malas hierbas y la suma de ellas.'),
                    textoCardBody('•	En la tercera sección se presenta porcentaje de área cubierta con materia muerta: Hojarasca, Mulch de malezas. También se presenta % de área con suelo desnudo. Se presenta % de cobertura de cada tipo y la suma de ellas.'),
                    textoCardBody('•	Estos datos sirven para toma de decisión sobre manejo de piso de cacaotal y evaluar el resultado de manejo que se practica en la parcela, siempre con el objetivo de tener un piso cubierto, pero sin competencia'),
                ],
            ),
            'Explicación de la tabla de datos'
        );
    }




}

