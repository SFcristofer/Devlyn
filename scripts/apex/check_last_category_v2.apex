// Script para encontrar clientes cuya ÚLTIMA compra no sea Oftálmicos
Map<String, String> resultados = new Map<String, String>();

// 1. Buscamos órdenes recientes
List<SObject> recientes = Database.query('SELECT ssot__SoldToCustomerId__c, ssot__Id__c, ssot__OrderNumber__c FROM ssot__SalesOrder__dlm ORDER BY ssot__CreatedDate__c DESC LIMIT 100');

Set<String> clientesProcesados = new Set<String>();

for(SObject o : recientes) {
    String posId = (String)o.get('ssot__SoldToCustomerId__c');
    String orderId = (String)o.get('ssot__Id__c');
    
    if(clientesProcesados.contains(posId)) continue; // Solo nos importa la más reciente de cada uno
    clientesProcesados.add(posId);
    
    // 2. Verificamos productos de esa ÚLTIMA orden
    List<SObject> prods = Database.query('SELECT ssot__Description__c FROM ssot__SalesOrderProduct__dlm WHERE ssot__SalesOrderId__c = \'' + orderId + '\'');
    
    String catEncontrada = 'Oftálmicos';
    for(SObject p : prods) {
        String d = ((String)p.get('ssot__Description__c') ?? '').toLowerCase();
        if(d.contains('solar') || d.contains('sun')) {
            catEncontrada = 'Solares';
            break; 
        } else if(d.contains('contacto') || d.contains(' lc') || d.contains('pupilente')) {
            catEncontrada = 'Lentes de Contacto';
            break;
        }
    }
    
    if(catEncontrada != 'Oftálmicos') {
        // 3. Obtenemos el nombre del cliente unificado
        List<UnifiedssotIndividualDev2__dlm> profs = [SELECT ssot__FirstName__c, ssot__LastName__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :posId LIMIT 1];
        if(!profs.isEmpty()) {
            String nombre = profs[0].ssot__FirstName__c + ' ' + profs[0].ssot__LastName__c;
            System.debug('REGISTRO_ENCONTRADO: ' + nombre + ' | ID_POS: ' + posId + ' | CATEGORIA: ' + catEncontrada);
        }
    }
    if(clientesProcesados.size() > 50) break;
}
