List<Map<String, Object>> results = TechProfile360Controller.searchProfilesGlobal('alejandro rivas');
System.debug('RESULTADOS ENCONTRADOS: ' + results.size());
for(Integer i=0; i<Math.min(results.size(), 5); i++) {
    Map<String, Object> r = results[i];
    System.debug('POS ' + (i+1) + ': ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c'));
}