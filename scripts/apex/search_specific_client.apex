String term = 'jose rafael rochin burgueno';
String searchWildcard = '%' + term + '%';
List<UnifiedssotIndividualDev2__dlm> results = [
    SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Email__c, Id_POS__c 
    FROM UnifiedssotIndividualDev2__dlm 
    WHERE ssot__FirstName__c LIKE '%jose%' 
      AND ssot__LastName__c LIKE '%rochin%'
    LIMIT 10
];

System.debug('--- RESULTADOS DE BÚSQUEDA ---');
for(UnifiedssotIndividualDev2__dlm r : results) {
    System.debug('ID: ' + r.ssot__Id__c);
    System.debug('Nombre: ' + r.ssot__FirstName__c);
    System.debug('Apellido: ' + r.ssot__LastName__c);
    System.debug('Email: ' + r.Email__c);
    System.debug('---------------------------');
}
if(results.isEmpty()) System.debug('No se encontraron resultados.');
