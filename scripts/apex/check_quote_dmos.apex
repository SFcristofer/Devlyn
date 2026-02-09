// Humberto Castillo Muñoz (Perfil de prueba)
String posId = '10461454';

// Lista de DMOs probables para presupuestos/cotizaciones en Devlyn
List<String> quoteDMOs = new List<String>{
    'POS_POS_CLIENTE_PRESUPUESTO_708324__dlm',
    'POS_POS_CLIENTE_PRESUPUESTO_70871439__dlm',
    'POS_POS_CLIENTE_COTIZACION_708324__dlm'
};

for(String dmo : quoteDMOs) {
    try {
        String q = 'SELECT ID_CLIENTE__c, FECHA__c, TOTAL__c FROM ' + dmo + ' WHERE ID_CLIENTE__c = :posId LIMIT 1';
        List<SObject> res = Database.query(q);
        System.debug('QUOTE_DMO_CHECK: ' + dmo + ' existe!');
    } catch(Exception e) { /* Ignorar */ }
}
