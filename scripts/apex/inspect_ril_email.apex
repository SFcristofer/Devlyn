
List<SObject> res = Database.query('SELECT ssot__FirstName__c, ssot__LastName__c, Apellido_Paterno__c, Apellido_Materno__c, Email__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Email__c = \'ril_14@hotmail.com\' LIMIT 1');
if(!res.isEmpty()) {
    SObject r = res[0];
    System.debug('--- DATOS REALES DEL CLIENTE ---');
    System.debug('Nombre: ' + r.get('ssot__FirstName__c'));
    System.debug('Apellido (Genérico): ' + r.get('ssot__LastName__c'));
    System.debug('Pat: ' + r.get('Apellido_Paterno__c'));
    System.debug('Mat: ' + r.get('Apellido_Materno__c'));
    System.debug('Email: ' + r.get('Email__c'));
    System.debug('ID POS: ' + r.get('Id_POS__c'));
} else {
    System.debug('NO SE ENCONTRÓ EL EMAIL: ril_14@hotmail.com');
}
