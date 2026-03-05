System.debug('--- VALIDACIÓN RESTAURACIÓN: ALEJANDRO RIVAS ---');
List<Map<String, Object>> results = TechProfile360Controller.searchProfilesGlobal('alejandro rivas');
System.debug('RESULTADOS: ' + results.size());
for(Integer i=0; i<Math.min(results.size(), 3); i++) {
    System.debug('POS ' + (i+1) + ': ' + results[i].get('ssot__FirstName__c') + ' ' + results[i].get('ssot__LastName__c'));
}