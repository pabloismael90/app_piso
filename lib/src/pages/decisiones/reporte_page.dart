import 'dart:convert';
import 'package:app_piso/src/models/acciones_model.dart';
import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/models/selectValue.dart' as selectMap;
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/titulos.dart';
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

    Future<double> _countTotalCompetencia(String? idTest,int idPlaga) async{
        double countPalga = await DBProvider.db.malezaDanina(idTest, idPlaga);        
        return countPalga*100;
    }
    Future<double> _countTotalNoCompetencia(String? idTest,int idPlaga) async{
        double countPalga = await DBProvider.db.malezaNoble(idTest, idPlaga);        
        return countPalga*100;
    }


    

    @override
    Widget build(BuildContext context) {
        String? idTest = ModalRoute.of(context)!.settings.arguments as String?;

        return Scaffold(
            appBar: AppBar(),
            body: FutureBuilder(
                future: getdata(idTest),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                    }
                    List<Widget> pageItem = [];
                    Finca finca = snapshot.data[2];
                    Parcela parcela = snapshot.data[3];

                    pageItem.add(_principalData(idTest,context, finca, parcela));
                    
                    pageItem.add( _hierbasProblematicas(snapshot.data[0]));
                    _plagasPDF(idTest,1);
                    pageItem.add( _competeciaValoracion(snapshot.data[0]));
                    pageItem.add( _observaciones(snapshot.data[0]));
                    pageItem.add( _obsManejo(snapshot.data[0]));
                    pageItem.add( _accionesMeses(snapshot.data[1]));
                    
                    
                    return Column(
                        children: [
                            Container(
                                child: Column(
                                    children: [
                                        
                                        TitulosPages(titulo: 'Reporte de Decisiones'),
                                        Divider(),
                                        Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10),
                                            child: Text(
                                                "Deslice hacia la derecha para continuar con el reporte",
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme
                                                    .headline5!
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
            // floatingActionButton: FloatingActionButton(
            //     child: Icon(Icons.save_alt),     
            //     onPressed: ()async{
            //         writePDF();
            //         await savePDF();
            //         Directory documentsDirectory = await getExternalStorageDirectory();
            //         String documentPath = documentsDirectory.path;
            //         String fullPath = "$documentPath/example.pdf";
            //         Navigator.push(context, MaterialPageRoute(
            //             builder: (context) => PDFView(fullPath)
            //         ));
            //     },
            // ),
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

                    Expanded(
                        child: SingleChildScrollView(
                            child: Container(
                                color: Colors.white,
                                child: Column(
                                    children: [
                                        Container(
                                            child: Padding(
                                                padding: EdgeInsets.only(top: 20, bottom: 10),
                                                child: Text(
                                                    "Porcentaje de cobertura",
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context).textTheme
                                                        .headline5!
                                                        .copyWith(fontWeight: FontWeight.w600, fontSize: 18)
                                                ),
                                            )
                                        ),
                                        Divider(),
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
                        ),
                    )
                ],
            ),
        );

            
    }
    Widget _dataFincas( BuildContext context, Finca finca, Parcela parcela ){
        String? labelMedidaFinca;
        String? labelvariedad;

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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                        "N de plantas: ${parcela.numeroPlanta}",
                                                        style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                    ),
                                                ),
                                            ],
                                        ),
                                        Flexible(
                                            child: Column(
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
                                                            "Variedad: $labelvariedad",
                                                            style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                                                        ),
                                                    ),
                                                ],
                                            ),
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



    Widget _hierbasProblematicas(List<Decisiones> decisionesList){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
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
        

        for (var item in decisionesList) {

            if (item.idPregunta == 1) {
                String? label = hierbaProblematica.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listPrincipales.add(

                    Container(
                        child: CheckboxListTile(
                        title: Text('$label'),
                            value: item.repuesta == 1 ? true : false ,
                            activeColor: Colors.teal[900], 
                            onChanged: (value) {
                                
                            },
                        ),
                    )                  
                        
                );
            }
            
            
            
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
                child: Column(children:listPrincipales,)
            ),
        );
        
    }

    Widget _competeciaValoracion(List<Decisiones> decisionesList){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
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
        

        for (var item in decisionesList) {

            if (item.idPregunta == 2) {
                String? label= itemCompetencia.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listPrincipales.add(

                    Container(
                        child: CheckboxListTile(
                        title: Text('$label'),
                            value: item.repuesta == 1 ? true : false ,
                            activeColor: Colors.teal[900], 
                            onChanged: (value) {
                                
                            },
                        ),
                    )                  
                    
                );
            }
            
        }

        listPrincipales.add(
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
        

        for (var item in decisionesList) {

            if (item.idPregunta == 3) {
                String? label= itemValoracion.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listPrincipales.add(

                    Container(
                        child: CheckboxListTile(
                        title: Text('$label'),
                            value: item.repuesta == 1 ? true : false ,
                            activeColor: Colors.teal[900], 
                            onChanged: (value) {
                                
                            },
                        ),
                    )                  
                    
                );
            }
            
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
                child: Column(children:listPrincipales,)
            ),
        );
        
    }

    Widget _observaciones(List<Decisiones> decisionesList){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
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
        

        for (var item in decisionesList) {

            if (item.idPregunta == 4) {
                String? label= itemObsSuelo.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listPrincipales.add(

                    Container(
                        child: CheckboxListTile(
                        title: Text('$label'),
                            value: item.repuesta == 1 ? true : false ,
                            activeColor: Colors.teal[900], 
                            onChanged: (value) {
                                
                            },
                        ),
                    )                  
                    
                );
            }
            
        }

        listPrincipales.add(
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
        

        for (var item in decisionesList) {

            if (item.idPregunta == 5) {
                String? label= itemObsSombra.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listPrincipales.add(

                    Container(
                        child: CheckboxListTile(
                        title: Text('$label'),
                            value: item.repuesta == 1 ? true : false ,
                            activeColor: Colors.teal[900], 
                            onChanged: (value) {
                                
                            },
                        ),
                    )                  
                    
                );
            }
            
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
                child: Column(children:listPrincipales,)
            ),
        );
        
    }

    Widget _obsManejo(List<Decisiones> decisionesList){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
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
        

        for (var item in decisionesList) {

            if (item.idPregunta == 6) {
                String? label= itemObsManejo.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listPrincipales.add(

                    Container(
                        child: CheckboxListTile(
                        title: Text('$label'),
                            value: item.repuesta == 1 ? true : false ,
                            activeColor: Colors.teal[900], 
                            onChanged: (value) {
                                
                            },
                        ),
                    )                  
                    
                );
            }
            
            
            
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
                child: Column(children:listPrincipales,)
            ),
        );
        
    }


    Widget _accionesMeses(List<Acciones> listAcciones){
        List<Widget> listPrincipales = [];

        listPrincipales.add(
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
                            style: Theme.of(context).textTheme
                                    .headline5!
                                    .copyWith(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        subtitle: Text(meses.join(","+" ")),
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
                child: Column(children:listPrincipales,)
            ),
        );
    }


    Widget _plagasPDF(String? idTest, int caminata){
        List<Widget> lisItem = [];

        for (var i = 0; i < itemEnContato.length; i++) {
            String? labelPlaga = itemEnContato.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "1","label": "No data"})['label'];
            int idplga = int.parse(itemEnContato.firstWhere((e) => e['value'] == '$i', orElse: () => {"value": "100","label": "No data"})['value']);
            lisItem.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Expanded(child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('$labelPlaga', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold) ,),
                        ),),
                        
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
        }
        return Column(children:lisItem,);
    }



   

    


}