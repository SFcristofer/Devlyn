List<Map<String, Object>> results = TechProfile360Controller.searchProfilesGlobal('Ximena Hernandez');
for(Map<String, Object> r : results) {
    System.debug('RANKING: ' + r.get('ssot__FirstName__c') + ' ' + r.get('ssot__LastName__c') + ' [ID: ' + r.get('Id_POS__c') + ']');
}