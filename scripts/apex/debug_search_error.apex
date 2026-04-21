try {
    String testTerm = '10964349';
    System.debug('--- INICIANDO PRUEBA DE BÚSQUEDA ---');
    List<Map<String, Object>> results = TechProfile360Controller.searchProfilesGlobal(testTerm);
    System.debug('Resultados encontrados: ' + results.size());
    for(Map<String, Object> r : results) {
        System.debug('Cliente: ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c'));
    }
} catch (Exception e) {
    System.debug('¡ERROR DETECTADO!');
    System.debug('Tipo: ' + e.getTypeName());
    System.debug('Mensaje: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
}
