import 'package:app_piso/src/bloc/fincas_bloc.dart';
import 'package:app_piso/src/models/decisiones_model.dart';
import 'package:app_piso/src/models/finca_model.dart';
import 'package:app_piso/src/models/parcela_model.dart';
import 'package:app_piso/src/models/paso_model.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/titulos.dart';
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
                    appBar: AppBar(),
                    body: Column(
                        children: [
                            escabezadoCaminata( context, piso ),
                            TitulosPages(titulo: 'Caminatas'),
                            Divider(),
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
                    
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
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
                                                style: TextStyle(color: kLightBlackColor),
                                            ),
                                        ),
                                        
                                    ],  
                                ),
                            ),
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
        return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                        BoxShadow(
                                color: Color(0xFF3A5160)
                                    .withOpacity(0.05),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 17.0),
                        ],
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        
                        Flexible(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                
                                    Padding(
                                        padding: EdgeInsets.only(top: 10, bottom: 10.0),
                                        child: Text(
                                            "Caminata $caminata",
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.headline6,
                                        ),
                                    ),
                                    
                                    
                                    Padding(
                                        padding: EdgeInsets.only( bottom: 10.0),
                                        child: Text(
                                            '$estado',
                                            style: TextStyle(color: kLightBlackColor),
                                        ),
                                    ),
                                ],  
                            ),
                        ),
                        Container(
                            child: CircularPercentIndicator(
                                radius: 70.0,
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
                                child: RaisedButton.icon(
                                    icon:Icon(Icons.add_circle_outline_outlined),
                                    
                                    label: Text('Toma de decisiones',
                                        style: Theme.of(context).textTheme
                                            .headline6!
                                            .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)
                                    ),
                                    padding:EdgeInsets.all(13),
                                    onPressed: () => Navigator.pushNamed(context, 'decisiones', arguments: piso),
                                )
                            ),
                        );
                        
                    }


                    return Container(
                        color: kBackgroundColor,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                            child: RaisedButton.icon(
                                icon:Icon(Icons.receipt_rounded),
                            
                                label: Text('Consultar decisiones',
                                    style: Theme.of(context).textTheme
                                        .headline6!
                                        .copyWith(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)
                                ),
                                padding:EdgeInsets.all(13),
                                onPressed: () => Navigator.pushNamed(context, 'reporte', arguments: piso.id),
                            )
                        ),
                    );
                                       
                },  
            );
        }
        

        return Container(
            color: kBackgroundColor,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                    "Complete las caminatas",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.w900, color: kRedColor, fontSize: 22)
                ),
            ),
        );
    }
}