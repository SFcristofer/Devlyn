// Buscamos IDs que tengan diagnóstico
String queryDiag = 'SELECT ID_CLIENTE__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm LIMIT 100';
List<SObject> diags = Database.query(queryDiag);
Set<String> idsWithDiag = new Set<String>();
for(SObject s : diags) idsWithDiag.add((String)s.get('ID_CLIENTE__c'));

if(idsWithDiag.isEmpty()) {
    System.debug('BUSQUEDA: No se encontraron diagnósticos en la base.');
} else {
    // De esos, ¿quiénes tienen Driver Visual?
    String queryDriver = 'SELECT ID_CLIENTE__c FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm WHERE ID_CLIENTE__c IN :idsWithDiag LIMIT 100';
    List<SObject> drivers = Database.query(queryDriver);
    Set<String> idsWithBoth = new Set<String>();
    for(SObject s : drivers) idsWithBoth.add((String)s.get('ID_CLIENTE__c'));
    
    if(idsWithBoth.isEmpty()) {
        System.debug('BUSQUEDA: No hay clientes con Diagnóstico + Driver Visual. Mostrando solo IDs con Diagnóstico: ' + idsWithDiag);
    } else {
        // ¿Y Preguntas Poder?
        String queryPower = 'SELECT ID_CLIENTE__c FROM POS_POS_CLIENTE_PREG_PODER__dlm WHERE ID_CLIENTE__c IN :idsWithBoth LIMIT 50';
        List<SObject> powers = Database.query(queryPower);
        Set<String> idsFull = new Set<String>();
        for(SObject s : powers) idsFull.add((String)s.get('ID_CLIENTE__c'));
        
        if(idsFull.isEmpty()) {
            System.debug('BUSQUEDA: Clientes con Diag + Driver: ' + idsWithBoth);
        } else {
            System.debug('PERFILES_COMPLETOS_ENCONTRADOS: ' + idsFull);
            
            // Traer nombres para el usuario
            List<UnifiedssotIndividualDev2__dlm> names = [SELECT ssot__FirstName__c, ssot__LastName__c, Id_POS__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c IN :idsFull LIMIT 5];
            for(UnifiedssotIndividualDev2__dlm p : names) {
                System.debug('PERFIL_DATA: ' + p.ssot__FirstName__c + ' ' + p.ssot__LastName__c + ' | ID POS: ' + p.Id_POS__c);
            }
        }
    }
}
