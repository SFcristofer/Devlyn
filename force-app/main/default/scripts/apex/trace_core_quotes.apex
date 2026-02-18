try {
    System.debug('--- BUSCANDO COTIZACIONES EN SALESFORCE CORE ---');
    
    // 1. Buscamos registros de Horacio en objetos comunes de cotización
    String targetId = '11472417'; // Horacio
    
    // Lista de objetos a probar en Core
    String[] coreObjects = new String[]{'Quote', 'Order', 'Opportunity'};
    for(String obj : coreObjects) {
        try {
            String q = 'SELECT count() FROM ' + obj + ' WHERE Name LIKE '%' + targetId + '%' OR Id_POS__c = :targetId';
            Integer c = Database.countQuery(q);
            if(c > 0) System.debug('¡REGISTROS ENCONTRADOS EN CORE!: ' + obj + ' (Cantidad: ' + c + ')');
        } catch(Exception e) {}
    }

    // 2. Buscamos cualquier objeto personalizado que tenga "Presupuesto" o "Cotizacion" en el nombre
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    for(String name : gd.keySet()) {
        if((name.contains('presupuesto') || name.contains('cotizacion')) && !name.endsWith('__dlm')) {
            try {
                String q = 'SELECT count() FROM ' + name;
                Integer c = Database.countQuery(q);
                if(c > 0) System.debug('OBJETO PERSONALIZADO CON DATOS: ' + name + ' (Registros: ' + c + ')');
            } catch(Exception e) {}
        }
    }
} catch(Exception e) {}
