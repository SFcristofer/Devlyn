
String term = 'Rafael Lopez';
List<Map<String, Object>> results = TechProfile360Controller.searchProfilesGlobal(term);

System.debug('--- RESULTADOS DE BÚSQUEDA: ' + term + ' ---');
System.debug('TOTAL ENCONTRADOS: ' + results.size());

for(Integer i=0; i < Math.min(results.size(), 10); i++) {
    Map<String, Object> r = results[i];
    System.debug('Resultado #' + (i+1) + ': ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + 
                 ' | ID: ' + r.get('Id_POS__c') + ' | Email: ' + r.get('Email__c'));
}
if(results.size() > 10) System.debug('... y ' + (results.size() - 10) + ' más.');
