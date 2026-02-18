String targetId = '11472417';
String searchWildcard = '%' + targetId + '%';
try {
    System.debug('--- AUDITORÍA DE COTIZACIONES EN CORE ---');
    String[] objectsToTest = new String[]{'Quote', 'Presupuesto__c', 'Cotizacion__c'};
    for(String obj : objectsToTest) {
        try {
            // Buscamos registros vinculados por ID POS o nombre
            String searchQ = 'SELECT Id, Name FROM ' + obj + ' WHERE Name LIKE :searchWildcard LIMIT 5';
            List<SObject> records = Database.query(searchQ);
            if(!records.isEmpty()) {
                System.debug('¡COTIZACIONES ENCONTRADAS EN ' + obj + '!');
                for(SObject s : records) System.debug(' - Folio: ' + s.get('Name') + ' | ID: ' + s.get('Id'));
            }
        } catch(Exception e) {}
    }
} catch(Exception e) {}
