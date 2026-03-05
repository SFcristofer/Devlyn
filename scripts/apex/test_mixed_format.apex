System.debug('--- TEST DE FORMATO VISUAL (MIXTO) ---');
List<Map<String, Object>> results = TechProfile360Controller.searchProfilesGlobal('Alejandro');
for(Integer i=0; i<Math.min(results.size(), 10); i++) {
    System.debug('REGISTRO ' + (i+1) + ': ' + results[i].get('ssot__FirstName__c') + ' ' + results[i].get('ssot__LastName__c'));
}