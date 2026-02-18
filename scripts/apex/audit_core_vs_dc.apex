String targetId = '11472417'; // ID POS de Horacio
try {
    System.debug('--- BUSCANDO EN SALESFORCE CORE (TRADICIONAL) ---');
    
    // 1. Buscamos en Contactos (Origen común de Marketing Cloud Connect)
    List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Id_POS__c = :targetId OR Id = :targetId LIMIT 1];
    if(!contacts.isEmpty()) {
        Id conId = contacts[0].Id;
        System.debug('Contacto encontrado en Core: ' + conId);
        
        // 2. Buscamos resultados de Email (MC Connect suele usar este objeto)
        // Intentamos una consulta dinámica por si el paquete no está instalado
        try {
            String mcQuery = 'SELECT Name, et4ae5__Date_Sent__c FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__Contact__c = :conId LIMIT 5';
            List<SObject> mcResults = Database.query(mcQuery);
            System.debug('RESULTADOS MC CONNECT ENCONTRADOS: ' + mcResults.size());
        } catch(Exception e) {
            System.debug('MC Connect (et4ae5) no está instalado o no tiene datos.');
        }
    } else {
        System.debug('No hay contacto en Core con este ID.');
    }

    // 3. Verificamos Data Cloud de nuevo pero con un conteo total sin filtros de usuario
    String dcQ = 'SELECT count() FROM ssot__EmailEngagement__dlm';
    System.debug('TOTAL GLOBAL DE EMAILS EN DATA CLOUD: ' + Database.countQuery(dcQ));

} catch(Exception e) {
    System.debug('Error en auditoría Core: ' + e.getMessage());
}
