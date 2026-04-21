
List<String> tokens = new List<String>{'RAFAEL', 'IZQUIERDO'};
String q = 'SELECT ssot__FirstName__c, ssot__LastName__c, Apellido_Paterno__c, Apellido_Materno__c, Id_POS__c, Email__c ' +
           'FROM UnifiedssotIndividualDev2__dlm WHERE ';

List<String> andConds = new List<String>();
for(String t : tokens) {
    String p = '%' + t + '%';
    andConds.add('(ssot__FirstName__c LIKE \'' + p + '\' OR ssot__LastName__c LIKE \'' + p + '\' OR Apellido_Paterno__c LIKE \'' + p + '\' OR Apellido_Materno__c LIKE \'' + p + '\')');
}
q += String.join(andConds, ' AND ') + ' LIMIT 100';

System.debug('--- BUSCANDO RAFAEL IZQUIERDO ---');
List<SObject> results = Database.query(q);
System.debug('TOTAL ENCONTRADOS: ' + results.size());
for(SObject r : results) {
    System.debug('Cliente: ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + 
                 ' | Pat: ' + r.get('Apellido_Paterno__c') + ' | Mat: ' + r.get('Apellido_Materno__c') + 
                 ' | ID: ' + r.get('Id_POS__c'));
}
