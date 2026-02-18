String targetId = '11472417';
String searchWildcard = '%' + targetId + '%';
try {
    System.debug('--- AUDITORÍA DE COTIZACIONES EN CORE ---');
    String[] objectsToTest = new String[]{'Quote', 'Order', 'Opportunity'};
    for(String obj : objectsToTest) {
        try {
            // Buscamos registros vinculados por ID POS o nombre
            String searchQ = 'SELECT count() FROM ' + obj + ' WHERE Name LIKE :searchWildcard LIMIT 5'; 
            Integer c = Database.countQuery(searchQ);
            if(c > 0) {
                System.debug('¡REGISTROS ENCONTRADOS EN CORE!: ' + obj + ' (Cantidad: ' + c + ')');
            }
        } catch(Exception e) {}
    }
    
    // Buscamos objetos personalizados
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    for(String name : gd.keySet()) {
        if((name.contains('presupuesto') || name.contains('cotizacion')) && name.endsWith('__c')) {
            try {
                Integer c = Database.countQuery('SELECT count() FROM ' + name);
                if(c > 0) System.debug('OBJETO PERSONALIZADO CON DATOS: ' + name + ' (Total: ' + c + ')');
            } catch(Exception e) {}
        }
    }
} catch(Exception e) {}
