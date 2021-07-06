import 'package:app_piso/src/bloc/fincas_bloc.dart';
import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/finca_model.dart';
import 'package:app_piso/src/models/parcela_model.dart';
import 'package:app_piso/src/models/paso_model.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/button.dart';
import 'package:app_piso/src/utils/widget/titulos.dart';
import 'package:app_piso/src/utils/widget/varios_widget.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CaminatasPage extends StatefulWidget {
    const CaminatasPage({Key? key}) : super(key: key);

  @override
  _CaminatasPageState createState() => _CaminatasPageState();
}

class _CaminatasPageState extends State<CaminatasPage> {

    final fincasBloc = new FincasBloc();

    Future _getdataFinca(TestPiso textPiso) async{
        Finca? finca = await DBProvider.db.getFincaId(textPiso.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(textPiso.idLote);
        List<Decisiones> desiciones = await DBProvider.db.getDecisionesIdTest(textPiso.id);
        
        return [finca, parcela, desiciones];
    }

    @override
    Widget build(BuildContext context) {
        
        TestPiso piso = ModalRoute.of(context)!.settings.arguments as TestPiso;
        fincasBloc.obtenerPasos(piso.id);
        

       return StreamBuilder<List<Paso>>(
            stream: fincasBloc.countPaso,
            builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                List<Paso> pasos = snapshot.data;
                fincasBloc.obtenerDecisiones(piso.id);
                int caminata1 = 0;
                int caminata2 = 0;
                int caminata3 = 0;
                List countCaminatas = [];

                for (var item in pasos) {
                    if (item.caminata == 1) {
                        caminata1 ++;
                    } else if (item.caminata == 2){
                        caminata2 ++;
                    }else{
                        caminata3 ++;
                    }
                }
                countCaminatas = [caminata1,caminata2,caminata3];
                
                return Scaffold(
                    appBar: AppBar(title: Text('Completar datos'),),
                    body: Column(
                        children: [
                            escabezadoCaminata( context, piso ),
                            TitulosPages(titulo: 'Lista de caminatas'),
                            Expanded(
                                child: SingleChildScrollView(
                                    child: _listaDeCaminatas( context, piso, countCaminatas ),
                                ),
                            ),
                        ],
                    ),
                    bottomNavigationBar: BottomAppBar(
                        child: _tomarDecisiones(countCaminatas, piso)
                    ),
                );
            },
        );
    }

    Widget escabezadoCaminata( BuildContext context, TestPiso piso ){


        return FutureBuilder(
            future: _getdataFinca(piso),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                }
                Finca finca = snapshot.data[0];
                Parcela parcela = snapshot.data[1];

                return Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            encabezadoCard('Área finca: ${finca.nombreFinca}','Productor: ${finca.nombreProductor}', 'assets/icons/finca.svg'),
                            Wrap(
                                spacing: 20,
                                children: [
                                    textoCardBody('Área finca: ${finca.areaFinca}'),
                                    textoCardBody('Área parcela: ${parcela.areaLote} ${finca.tipoMedida == 1 ? 'Mz': 'Ha'}'), 
                                ],
                            )
                        ],
                    ),
                );
            },
        );        
    }

    Widget  _listaDeCaminatas( BuildContext context, TestPiso piso, List countCaminatas){
        return ListView.builder(
            itemBuilder: (context, index) {
                String estadoConteo;
                if (countCaminatas[index] >= 10){
                    estadoConteo =  'Completo';
                }else{
                   estadoConteo =  'Incompleto'; 
                }
                return GestureDetector(
                    
                    child: _cardTest(index+1,countCaminatas[index], estadoConteo),
                    onTap: () => Navigator.pushNamed(context, 'pasos', arguments: [piso, index]),
                );
                
               
            },
            shrinkWrap: true,
            itemCount:  piso.caminatas,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }

    Widget _cardTest(int caminata, int numeroPasos, String estado){
        return cardDefault(
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                    
                    Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                tituloCard('Caminata $caminata'),
                                subtituloCardBody('$estado')
                            ],  
                        ),
                    ),
                    Container(
                        child: CircularPercentIndicator(
                            radius: 70,
                            lineWidth: 5.0,
                            animation: true,
                            percent: numeroPasos/20,
                            center: new Text("${(numeroPasos/20)*100}%"),
                            progressColor: Color(0xFF498C37),
                        ),
                    )
                    
                ],
            ), 
                
        );
    }
   
    Widget  _tomarDecisiones(List countCaminatas, TestPiso piso){
        
        if(countCaminatas[0] >= 20 && countCaminatas[1] >= 20 && countCaminatas[2] >= 20){
            
            return StreamBuilder(
            stream: fincasBloc.decisionesStream ,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                    }
                    List<Decisiones> desiciones = snapshot.data;

                    //print(desiciones);

                    if (desiciones.length == 0){

                        return Container(
                            color: kBackgroundColor,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                                child: ButtonMainStyle(
                                    title: 'Toma de decisiones',
                                    icon: Icons.post_add,
                                    press:() => Navigator.pushNamed(context, 'decisiones', arguments: piso),
                                )
                            ),
                        );
                        
                    }

                    return Container(
                        color: kBackgroundColor,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                            child: ButtonMainStyle(
                                    title: 'Consultar decisiones',
                                    icon: Icons.receipt_rounded,
                                    press: () => Navigator.pushNamed(context, 'reporte', arguments: piso.id),
                                
                            
                            ),
                        )
                    );
                                       
                },  
            );
        }

        return Container(
            color: kBackgroundColor,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                    "Complete los sitios",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900, color: kRedColor, fontSize: 18)
                ),
            ),
        );
    }
}