import 'package:app_piso/src/bloc/fincas_bloc.dart';
import 'package:app_piso/src/models/testPiso_model.dart';
import 'package:app_piso/src/providers/db_provider.dart';
import 'package:app_piso/src/utils/constants.dart';
import 'package:app_piso/src/utils/widget/dialogDelete.dart';
import 'package:app_piso/src/utils/widget/titulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


final fincasBloc = new FincasBloc();

class TestPage extends StatefulWidget {

    

  @override
  _TestPageState createState() => _TestPageState();
}


class _TestPageState extends State<TestPage> {

    
    Future _getdataFinca(TestPiso textPiso) async{
        Finca? finca = await DBProvider.db.getFincaId(textPiso.idFinca);
        Parcela? parcela = await DBProvider.db.getParcelaId(textPiso.idLote);
        return [finca, parcela];
    }

    @override
    Widget build(BuildContext context) {
        var size = MediaQuery.of(context).size;
        fincasBloc.obtenerPisos();

        return Scaffold(
                appBar: AppBar(),
                body: StreamBuilder<List<TestPiso>>(
                    stream: fincasBloc.pisoStream,

                    
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());

                        }

                        List<TestPiso> textPisos= snapshot.data;
                        if (textPisos.length == 0) {
                            return Column(
                                children: [
                                    TitulosPages(titulo: 'Parcelas'),
                                    Divider(),
                                    Expanded(child: Center(
                                        child: Text('No hay datos: \nIngrese una toma de datos', 
                                        textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.headline6,
                                            )
                                        )
                                    )
                                ],
                            );
                        }
                        return Column(
                            children: [

                                TitulosPages(titulo: 'Parcelas'),
                                Divider(),
                                Expanded(child: SingleChildScrollView(child: _listaDePisos(textPisos, size, context)))
                            ],
                        );
                        
                        
                    },
                ),
                bottomNavigationBar: BottomAppBar(
                    child: Container(
                        color: kBackgroundColor,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                            child: _addtest(context)
                        ),
                    ),
                ),
        );
        
    }

    Widget _addtest(BuildContext context){
        return RaisedButton.icon(
            icon:Icon(Icons.add_circle_outline_outlined),
            
            label: Text('Escoger parcelas',
                style: Theme.of(context).textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white)
            ),
            padding:EdgeInsets.all(13),
            onPressed:() => Navigator.pushNamed(context, 'addTest'),
        );
    }

    Widget  _listaDePisos(List textPisos, Size size, BuildContext context){
        return ListView.builder(
            itemBuilder: (context, index) {
                return Dismissible(
                    key: UniqueKey(),
                    child: GestureDetector(
                        child: FutureBuilder(
                            future: _getdataFinca(textPisos[index]),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) {
                                    return Center(child: CircularProgressIndicator());
                                }
                                Finca finca = snapshot.data[0];
                                Parcela parcela = snapshot.data[1];

                                return _cardTest(size, textPisos[index], finca, parcela);
                            },
                        ),
                        onTap: () => Navigator.pushNamed(context, 'caminatas', arguments: textPisos[index]),
                    ),
                    confirmDismiss: (direction) => confirmacionUser(direction, context),
                    direction: DismissDirection.endToStart,
                    background: backgroundTrash(context),
                    movementDuration: Duration(milliseconds: 500),
                    onDismissed: (direction) => fincasBloc.borrarTestPiso(textPisos[index].id),
                );
               
            },
            shrinkWrap: true,
            itemCount: textPisos.length,
            padding: EdgeInsets.only(bottom: 30.0),
            controller: ScrollController(keepScrollOffset: false),
        );

    }

    Widget _cardTest(Size size, TestPiso textPiso, Finca finca, Parcela parcela){
        
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
                child: Column(
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: SvgPicture.asset('assets/icons/test.svg', height:80,),
                                ),
                                Flexible(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                        
                                            Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 5.0),
                                                child: Text(
                                                    "${finca.nombreFinca}",
                                                    softWrap: true,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: Theme.of(context).textTheme.headline6,
                                                ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only( bottom: 4.0),
                                                child: Text(
                                                    "${parcela.nombreLote}",
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: kLightBlackColor),
                                                ),
                                            ),
                                            
                                            Padding(
                                                padding: EdgeInsets.only( bottom: 10.0),
                                                child: Text(
                                                    'Fecha: ${textPiso.fechaTest}',
                                                    style: TextStyle(color: kLightBlackColor),
                                                ),
                                            ),
                                        ],  
                                    ),
                                ),
                            ],
                        ),
                        Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                                Icon(Icons.touch_app, color: kRedColor,),
                                Text(' Tocar para completar datos', style: TextStyle(color: kRedColor),)
                            ],
                        )
                    ],
                ),
        );
    }




}