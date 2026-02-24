String term = 'rochin';
String searchWildcard = '%' + term + '%';
List<UnifiedssotIndividualDev2__dlm> results = [
    SELECT ssot__FirstName__c, ssot__LastName__c, Email__c, Id_POS__c 
    FROM UnifiedssotIndividualDev2__dlm 
    WHERE ssot__LastName__c LIKE :searchWildcard
       OR ssot__FirstName__c LIKE :searchWildcard
    LIMIT 20
];

System.debug('--- REGISTROS ENCONTRADOS CON "ROCHIN" ---');
for(UnifiedssotIndividualDev2__dlm r : results) {
    System.debug('Nombre: ' + r.ssot__FirstName__c + ' | Apellido: ' + r.ssot__LastName__c + ' | POS: ' + r.Id_POS__c);
}
if(results.isEmpty()) System.debug('No se encontraron registros con ese apellido.');
