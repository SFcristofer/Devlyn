// Script de Búsqueda de Precisión usando SOQL Directo (Igual que el LWC)
String searchName = '%Juan Pérez%';
String posId = '12388500';

System.debug('--- BUSCANDO DATOS REALES DE JUAN PÉREZ ---');

try {
    // 1. Buscamos el Perfil Unificado (DMO Real)
    List<UnifiedssotIndividualDev2__dlm> profiles = [
        SELECT ssot__Id__c, ssot__FirstName__c, ssot__LastName__c, Id_POS__c 
        FROM UnifiedssotIndividualDev2__dlm 
        WHERE ssot__FirstName__c LIKE :searchName OR Id_POS__c = :posId 
        LIMIT 1
    ];

    if(!profiles.isEmpty()) {
        UnifiedssotIndividualDev2__dlm p = profiles[0];
        String uniId = p.ssot__Id__c;
        System.debug('PERFIL_ENCONTRADO: Name=' + p.ssot__FirstName__c + ' ' + p.ssot__LastName__c + ' | UnifiedID=' + uniId + ' | POS_ID=' + p.Id_POS__c);

        // 2. Buscamos el Diagnóstico Médico (Usando el Unified ID que es el que manda)
        // Probamos con la tabla que Mulesoft está intentando usar
        List<SObject> diags = Database.query(
            'SELECT ID_CLIENTE__c, FECHA__c, MIOPIA__c, ASTIGMATISMO__c ' +
            'FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm ' +
            'WHERE ID_CLIENTE__c = \'' + uniId + '\' OR ID_CLIENTE__c = \'' + p.Id_POS__c + '\''
        );
        
        if(!diags.isEmpty()) {
            System.debug('DIAGNOSTICO_REAL: ' + JSON.serialize(diags[0]));
        } else {
            System.debug('DIAGNOSTICO_NO_ENCONTRADO: El diagnóstico no está en esta tabla bajo esos IDs.');
        }

        // 3. Buscamos las Órdenes (Para confirmar que vemos lo que tú ves)
        List<SObject> orders = Database.query(
            'SELECT ssot__OrderNumber__c, ssot__TotalAmount__c ' +
            'FROM ssot__SalesOrder__dlm ' +
            'WHERE ssot__SoldToCustomerId__c = \'' + p.Id_POS__c + '\' OR ssot__SoldToCustomerId__c = \'' + uniId + '\''
        );
        System.debug('ORDENES_REALES: ' + JSON.serialize(orders));

    } else {
        System.debug('ERROR: No se encontró a Juan Pérez en el modelo unificado mediante SOQL.');
    }
} catch (Exception e) {
    System.debug('ERROR_TECNICO: ' + e.getMessage());
}
