// Humberto Castillo Muñoz
String posId = '10461454';

// Consultamos diagnósticos con una consulta dinámica que intente traer lo más posible
String query = 'SELECT ASTIGMATISMO__c, HIPERMETROPIA__c, MIOPIA__c, PRESBICIA__c, FECHA__c, ID_CLIENTE__c ' +
               'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
               'WHERE ID_CLIENTE__c = :posId LIMIT 1';

List<SObject> results = Database.query(query);
if(!results.isEmpty()) {
    SObject d = results[0];
    System.debug('FULL_DIAG_DATA: ' + d);
}

// Probamos con el objeto de Antecedentes
String qAnt = 'SELECT ARDOR_IRRITACION__c, COMEZON__c, DIABETES__c, HIPERTENSION__c, NOTAS__c FROM POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm WHERE ID_CLIENTE__c = :posId LIMIT 1';
List<SObject> antRes = Database.query(qAnt);
if(!antRes.isEmpty()) {
    System.debug('FULL_ANT_DATA: ' + antRes[0]);
}
