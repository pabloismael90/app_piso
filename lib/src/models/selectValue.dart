List<Map<String, dynamic>> dimenciones(){

    
    final List<Map<String, dynamic>> medidaItem = [
            {
                'value': '1',
                'label': 'Mz',
                
            },
            {
                'value': '2',
                'label': 'Ha',
            },
    ];

    return medidaItem;
}

List<Map<String, dynamic>> listMeses(){

    
    final List<Map<String, dynamic>> medidaItem = [
        {
            'value': '1',
            'label': 'Enero',
        },
        {
            'value': '2',
            'label': 'Febrero',
        },
        {
            'value': '3',
            'label': 'Marzo',
        },
        {
            'value': '4',
            'label': 'Abril',
        },
        {
            'value': '5',
            'label': 'Mayo',
        },
        {
            'value': '6',
            'label': 'Junio',
        },
        {
            'value': '7',
            'label': 'Julio',
        },
        {
            'value': '8',
            'label': 'Agosto',
        },
        {
            'value': '9',
            'label': 'Septiembre',
        },
        {
            'value': '10',
            'label': 'Octubre',
        },
        {
            'value': '11',
            'label': 'Noviembre',
        },
        {
            'value': '12',
            'label': 'Diciembre',
        },
    ];

    return medidaItem;
}


List<Map<String, dynamic>> variedadCacao(){
    final List<Map<String, dynamic>>  variedadesCacao = [
            {
                'value': '1', 
                'label': 'Clones'
            },
            {
                'value': '2', 
                'label': 'Plantas por semillas'
            },
            {
                'value': '3', 
                'label': 'Mezcla patrones y clones'
            },
        ];

    return variedadesCacao;
}

List<Map<String, dynamic>> itemContacto(){
    final List<Map<String, dynamic>>  contactoCacao = [
            
        {
            'value' : '0',
            'label' : 'Zacate anual',
        },
        {
            'value' : '1',
            'label' : 'Zacate perene',
        },
        {
            'value' : '2',
            'label' : 'Hoja ancha anual',
        },
        {
            'value' : '3',
            'label' : 'Hoja ancha perenne',
        },
        {
            'value' : '4',
            'label' : 'Ciperácea o Coyolillo',
        },
        {
            'value' : '5',
            'label' : 'Bejucos en suelo',
        },
        {
            'value' : '6',
            'label' : 'Tanda o planta parasítica',
        },


        
        {
            'value' : '7',
            'label' : 'Cobertura hoja ancha',
        },
        {
            'value' : '8',
            'label' : 'Cobertura hoja angosta',
        },


        {
            'value' : '9',
            'label' : 'Suelo desnudo',
        },
        {
            'value' : '10',
            'label' : 'Hojarasca',
        },
        {
            'value' : '11',
            'label' : 'Coberturas muertas',
        },

    ];

    return contactoCacao;
}

List<Map<String, dynamic>> hierbaProblematica(){
    final List<Map<String, dynamic>>  hierbaProblematica = [
            
        {
        'value' : '0',
        'label' : 'Zacate anual',
        },
        {
        'value' : '1',
        'label' : 'Zacate perene',
        },
        {
        'value' : '2',
        'label' : 'Hoja ancha anual',
        },
        {
        'value' : '3',
        'label' : 'Hoja ancha perenne',
        },
        {
        'value' : '4',
        'label' : 'Ciperácea o Coyolillo',
        },
        {
        'value' : '5',
        'label' : 'Bejucos',
        },
        {
        'value' : '6',
        'label' : 'Tanda o planta parasitica',
        },

        {
        'value' : '7',
        'label' : 'Suelo desnudo',
        },

    ];

    return hierbaProblematica;
}


List<Map<String, dynamic>> competenciaHierba(){
    final List<Map<String, dynamic>>  competenciaHierba = [
        {
            'value': '0',
            'label': 'Alta Competencia'
        },
        {
            'value': '1',
            'label': 'Media competencia'
        },
        {
            'value': '2',
            'label': 'Sin Competencia'
        },

    ];

    return competenciaHierba;
}
List<Map<String, dynamic>> valoracionCobertura(){
    final List<Map<String, dynamic>>  valoracionCobertura = [
        {
            'value': '0',
            'label': 'Piso cubierto pero compite'
        },
        {
            'value': '1',
            'label': 'Piso medio cubierto y compite'
        },
        {
            'value': '2',
            'label': 'Piso cubierto pero no compite'
        },
        {
            'value': '3',
            'label': 'Piso no cubierto'
        },
        {
            'value': '4',
            'label': 'Piso con mucho bejuco'
        },
        {
            'value': '5',
            'label': 'Muchas plantas con bejuco'
        },
        {
            'value': '6',
            'label': 'Plantas con tanda'
        }

    ];

    return valoracionCobertura;
}
List<Map<String, dynamic>> observacionSuelo(){
    final List<Map<String, dynamic>>  observacionSuelo = [
        {
            'value': '0',
            'label': 'Suelo erosionado'
        },
        {
            'value': '1',
            'label': 'Suelo poco fértil'
        },
        {
            'value': '2',
            'label': 'Mal drenaje'
        },
        {
            'value': '3',
            'label': 'Suelo compacto'
        },
        {
            'value': '4',
            'label': 'Suelo  con poco Materia orgánica'
        },
        {
            'value': '5',
            'label': 'No usa abobo o fertilizante'
        }

    ];

    return observacionSuelo;
}
List<Map<String, dynamic>> observacionSombra(){
    final List<Map<String, dynamic>>  observacionSombra = [
        {
            'value': '0',
            'label': 'Sombra muy rala'
        },
        {
            'value': '1',
            'label': 'Sombra mal distribuida'
        },
        {
            'value': '2',
            'label': 'Árboles de sombra no adecuadas'
        },
        {
            'value': '3',
            'label': 'Poco banano o plátano'
        }

    ];

    return observacionSombra;
}

List<Map<String, dynamic>> observacionManejo(){
    final List<Map<String, dynamic>>  observacionManejo = [
        {
            'value': '0',
            'label': 'Chapoda no adecuada'
        },
        {
            'value': '1',
            'label': 'Chapodas tardías'
        },
        {
            'value': '2',
            'label': 'No hay manejo selectivo'
        },
        {
            'value': '3',
            'label': 'Plantas desnutridas'
        },
        {
            'value': '4',
            'label': 'Plantas viejas'
        },
        {
            'value': '5',
            'label': 'Mala selección de herbicidas'
        }

    ];

    return observacionManejo;
}

List<Map<String, dynamic>> solucionesXmes(){
    final List<Map<String, dynamic>>  solucionesXmes = [
        {
            'value': '0',
            'label': 'Recuento de maleza o piso'
        },
        {
            'value': '1',
            'label': 'Chapoda tendida'
        },
        {
            'value': '2',
            'label': 'Chapoda selectiva'
        },
        {
            'value': '3',
            'label': 'Aplicar herbicida en toda la parcela'
        },
        {
            'value': '4',
            'label': 'Aplicar herbicidas en parches'
        },
        {
            'value': '5',
            'label': 'Manejo de bejuco'
        },
        {
            'value': '6',
            'label': 'Manejo de tanda'
        },
        {
            'value': '7',
            'label': 'Regulación de sombra'
        },
        {
            'value': '8',
            'label': 'Abonar las plantas de cacao'
        }

    ];

    return solucionesXmes;
}





















