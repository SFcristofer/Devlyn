System.debug('--- TEST DE ESTRÉS: CASO ANA KAREN ---');

String[] tests = new List<String>{'Ana Karen 97850', 'Ana Karen 97850 Rivas Romero'};

for(String t : tests) {
    List<Map<String, Object>> results = TechProfile360Controller.searchProfilesGlobal(t);
    System.debug('BÚSQUEDA [' + t + ']: ' + results.size() + ' resultados.');
    if(!results.isEmpty()) {
        for(Integer i=0; i<Math.min(results.size(), 3); i++) {
            System.debug('POS ' + (i+1) + ': ' + results[i].get('ssot__FirstName__c') + ' ' + results[i].get('ssot__LastName__c') + ' [ID POS: ' + results[i].get('Id_POS__c') + ']');
        }
    }
}

System.debug('--- FIN TEST ---');