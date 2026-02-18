String targetId = '11472417'; // Horacio
try {
    System.debug('--- AUDITORÍA DE COTIZACIONES EN CORE ---');
    
    // 1. Buscamos en objetos estándar y probables personalizados
    // Intentamos describir para ver si existen
    String[] objectsToTest = new String[]{'Quote', 'Presupuesto__c', 'Cotizacion__c'};
    for(String obj : objectsToTest) {
        try {
            String q = 'SELECT Id, Name FROM ' + obj + ' LIMIT 1';
            Database.query(q);
            System.debug('OBJETO_CORE_ENCONTRADO: ' + obj);
            
            // Si el objeto existe, buscamos registros vinculados
            // Nota: El campo de vínculo puede variar, intentaremos con campos comunes
            String searchQ = 'SELECT Id, Name FROM ' + obj + ' WHERE Name LIKE '%' + targetId + '%' OR Id_POS__c = :targetId LIMIT 5';
            List<SObject> records = Database.query(searchQ);
            System.debug('Registros en ' + obj + ': ' + records.size());
        } catch(Exception e) {}
    }

} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
}
