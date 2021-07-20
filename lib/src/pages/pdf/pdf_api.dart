import 'dart:convert';
import 'dart:io';

import 'package:app_piso/src/models/acciones_model.dart';
import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:app_piso/src/models/selectValue.dart' as selectMap;
import 'package:pdf/widgets.dart';

class PdfApi {
    

    static Future<File> generateCenteredText(
        TestPiso? testPiso,
        Map<int,List> listaMalezadanina,
        List<double?> totales,
    
    ) async {
        final pdf = pw.Document();
        final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Museo/Museo300.ttf'));
        Finca? finca = await DBProvider.db.getFincaId(testPiso!.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(testPiso.idLote);
        List<Decisiones> listDecisiones = await DBProvider.db.getDecisionesIdTest(testPiso.id);
        List<Acciones> listAcciones= await DBProvider.db.getAccionesIdTest(testPiso.id);

        String? labelMedidaFinca = selectMap.dimenciones().firstWhere((e) => e['value'] == '${finca!.tipoMedida}')['label'];
        String? labelvariedad = selectMap.variedadCacao().firstWhere((e) => e['value'] == '${parcela!.variedadCacao}')['label'];

        
        final List<Map<String, dynamic>>?  hierbaProblematica = selectMap.hierbaProblematica();
        final List<Map<String, dynamic>>?  itemCompetencia = selectMap.competenciaHierba();
        final List<Map<String, dynamic>>?  itemValoracion = selectMap.valoracionCobertura();
        final List<Map<String, dynamic>>?  itemObsSuelo = selectMap.observacionSuelo();
        final List<Map<String, dynamic>>?  itemObsSombra = selectMap.observacionSombra();
        final List<Map<String, dynamic>>?  itemObsManejo = selectMap.observacionManejo();
        final List<Map<String, dynamic>>?  _meses = selectMap.listMeses();
        final List<Map<String, dynamic>>?  listSoluciones = selectMap.solucionesXmes();

        pdf.addPage(
            
            pw.MultiPage(
                pageFormat: PdfPageFormat.a4,
                build: (context) => <pw.Widget>[
                    _encabezado('Datos de finca', font),
                    pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                            pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                    _textoBody('Finca: ${finca!.nombreFinca}', font),
                                    _textoBody('Parcela: ${parcela!.nombreLote}', font),
                                    _textoBody('Productor: ${finca.nombreProductor}', font),
                                    finca.nombreTecnico != '' ?
                                    _textoBody('Técnico: ${finca.nombreTecnico}', font)
                                    : pw.Container(),

                                    _textoBody('Variedad: $labelvariedad', font),


                                ]
                            ),
                            pw.Container(
                                padding: pw.EdgeInsets.only(left: 40),
                                child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                        _textoBody('Área Finca: ${finca.areaFinca} ($labelMedidaFinca)', font),
                                        _textoBody('Área Parcela: ${parcela.areaLote} ($labelMedidaFinca)', font),
                                        _textoBody('N de plantas: ${parcela.numeroPlanta}', font),                    
                                        _textoBody('Fecha: ${testPiso.fechaTest}', font),                    
                                    ]
                                ),
                            )
                        ]
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                        'Datos consolidados',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, font: font)
                    ),
                    pw.SizedBox(height: 10),
                    _tablaPoda(listaMalezadanina, totales, font),
                    pw.SizedBox(height: 30),
                    _pregunta('Hierbas que consideran problematicas', font, listDecisiones, 1, hierbaProblematica),
                    _pregunta('Competencia entre hierbas y cacao', font, listDecisiones, 2, itemCompetencia),
                    _pregunta('Valoración de cobertura del piso', font, listDecisiones, 3, itemValoracion),
                    _pregunta('Observaciones de suelo', font, listDecisiones, 4, itemObsSuelo),
                    _pregunta('Observaciones de sombra', font, listDecisiones, 5, itemObsSombra),
                    _pregunta('Observaciones de manejo', font, listDecisiones, 6, itemObsManejo),
                    _accionesMeses(listAcciones, listSoluciones, _meses, font)                 
                    
                ],
                footer: (context) {
                    final text = 'Page ${context.pageNumber} of ${context.pagesCount}';

                    return Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(top: 1 * PdfPageFormat.cm),
                        child: Text(
                            text,
                            style: TextStyle(color: PdfColors.black, font: font),
                        ),
                    );
                },
            )
        
        );

        return saveDocument(name: 'Reporte ${finca!.nombreFinca} ${testPiso.fechaTest}.pdf', pdf: pdf);
    }

    static Future<File> saveDocument({
        required String name,
        required pw.Document pdf,
    }) async {
        final bytes = await pdf.save();

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$name');

        await file.writeAsBytes(bytes);

        return file;
    }

    static Future openFile(File file) async {
        final url = file.path;

        await OpenFile.open(url);
    }

    static pw.Widget _encabezado(String? titulo, pw.Font fuente){
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
                pw.Text(
                    titulo as String,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, font: fuente)
                ),
                pw.Divider(color: PdfColors.black),
            
            ]
        );

    }

    static pw.Widget _textoBody(String? contenido, pw.Font fuente){
        return pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Text(contenido as String,style: pw.TextStyle(fontSize: 12, font: fuente))
        );

    }

    static pw.Widget _pregunta(String? titulo, pw.Font fuente, List<Decisiones> listDecisiones, int idPregunta, List<Map<String, dynamic>>? listaItem){

        List<pw.Widget> listWidget = [];

        listWidget.add(
            _encabezado(titulo, fuente)
        );

        for (var item in listDecisiones) {

            if (item.idPregunta == idPregunta) {
                String? label= listaItem!.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];

                listWidget.add(
                    pw.Column(
                        children: [
                            pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                    _textoBody(label, fuente),
                                    pw.Container(
                                        decoration: pw.BoxDecoration(
                                            border: pw.Border.all(color: PdfColors.green900),
                                            borderRadius: pw.BorderRadius.all(
                                                pw.Radius.circular(5.0)
                                            ),
                                            color: item.repuesta == 1 ? PdfColors.green900 : PdfColors.white,
                                        ),
                                        width: 10,
                                        height: 10,
                                        padding: pw.EdgeInsets.all(2),
                                        
                                    )
                                ]
                            ),
                            pw.SizedBox(height: 10)
                        ]
                    ),

                    
                    
                );
            }
        }


        return pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Column(children:listWidget)
        );

    }

    static pw.Widget _tablaPoda( Map<int,List> listaMalezadanina , List<double?> totales, Font font){
        return pw.Column(
            children: [
                pw.Table(
                    columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        1:FixedColumnWidth(65),
                    },
                    // border: TableBorder(
                    //     bottom: BorderSide(color: PdfColors.black, width: 1), 
                    //     horizontalInside: BorderSide(color: PdfColors.black, width: 1),
                    //     verticalInside: BorderSide(color: PdfColors.black, width: 1),
                    //     left: BorderSide(color: PdfColors.black, width: 1),
                    //     right: BorderSide(color: PdfColors.black, width: 1),
                    // ),
                    border: TableBorder.all(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: _filasPoda(listaMalezadanina, totales, font)
                ),
                
            ]
        );

    }

    static pw.TableRow _crearFila(dynamic value, String titulo, Font font, bool fondo){
        List<Widget> celdas = [];
        
        celdas.add(_cellText('$titulo', font));
        celdas.add(_cellText( value.runtimeType == String ? '$value' : '${value.toStringAsFixed(2)} %' , font) );
        
        return pw.TableRow(children: celdas,decoration: pw.BoxDecoration(color: fondo ? PdfColors.grey300 : PdfColors.white));

    }

    static List<pw.TableRow> _filasPoda(Map<int,List> listaMalezadanina , List<double?> totales, Font font){
        List<pw.TableRow> filas = [];
        final List<Map<String, dynamic>>?  itemEnContato = selectMap.itemContacto();

        filas.add(_crearFila('Cobertura','Malezas dañinas', font, true));

        listaMalezadanina.forEach((key, value) {
            String nameItem = itemEnContato!.firstWhere((e) => e['value'] == '$key', orElse: () => {"value": "1","label": "No data"})['label'];
            if(key == 6) {
                filas.add(_crearFila(value[0], '$nameItem', font, false));
                filas.add(_crearFila(totales[0], 'Total', font, true));
                filas.add(_crearFila('Cobertura','Coberturas vivas', font, true));  
            }

            else if(key == 8) {
                filas.add(_crearFila(value[0], '$nameItem', font, false));
                filas.add(_crearFila(totales[1], 'Total', font, true));
                filas.add(_crearFila('Cobertura','Coberturas muertas', font, true));  
            }

            else if(key == 11) {
                filas.add(_crearFila(value[0], '$nameItem', font, false));
                filas.add(_crearFila(totales[1], 'Total', font, true));
            }
            else{
                filas.add(_crearFila(value[0], '$nameItem', font, false));
            }
        
        });
        return filas;

    }

    static pw.Widget _cellText( String texto, pw.Font font){
        return pw.Container(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text(texto,
                style: pw.TextStyle(font: font)
            )
        );
    }

    static pw.Widget _accionesMeses( List<Acciones>? listAcciones, List<Map<String, dynamic>>?  listSoluciones, List<Map<String, dynamic>>?  _meses, Font font){
        List<pw.Widget> listPrincipales = [];

        listPrincipales.add(_encabezado('¿Qué acciones vamos a realizar y cuando?', font));
        
        
        for (var item in listAcciones!) {

                List<String?> meses = [];
                
                String? label= listSoluciones!.firstWhere((e) => e['value'] == '${item.idItem}', orElse: () => {"value": "1","label": "No data"})['label'];
                List listaMeses = jsonDecode(item.repuesta!);
                if (listaMeses.length==0) {
                    meses.add('Sin aplicar');
                }
                for (var item in listaMeses) {
                    String? mes = _meses!.firstWhere((e) => e['value'] == '$item', orElse: () => {"value": "1","label": "No data"})['label'];
                    
                    meses.add(mes);
                }
                

                listPrincipales.add(
                    pw.Column(
                        children: [
                            _textoBody('$label : ${meses.join(","+" ")}', font),
                            pw.SizedBox(height: 10)
                        ]
                    )
                                    
                    
                );
            
            
            
            
        }
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:listPrincipales);
    }


}


