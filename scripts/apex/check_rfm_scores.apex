String posId = '11607739';
List<UnifiedssotIndividualDev2__dlm> profiles = [SELECT ssot__Id__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :posId LIMIT 1];

if (profiles.isEmpty()) {
    System.debug('RFM_CHECK: Perfil no encontrado.');
} else {
    String uid = profiles[0].ssot__Id__c;
    System.debug('RFM_CHECK: UnifiedID = ' + uid);
    
    // Consultamos los 3 modelos de RFM Retail
    String[] cios = new String[]{'RFM_Retail_Solar__cio', 'RFM_Retail_LC__cio', 'RFM_Retail_Oftalmicos__cio'};
    for(String cio : cios) {
        try {
            String q = 'SELECT score__c, label__c FROM ' + cio + ' WHERE unified_individual_id__c = :uid LIMIT 1';
            List<SObject> res = Database.query(q);
            if(!res.isEmpty()) {
                System.debug('RFM_DATA_FOUND in ' + cio + ': ' + res[0]);
            } else {
                System.debug('RFM_DATA_EMPTY in ' + cio);
            }
        } catch(Exception e) {
            System.debug('RFM_ERROR in ' + cio + ': ' + e.getMessage());
        }
    }
}
