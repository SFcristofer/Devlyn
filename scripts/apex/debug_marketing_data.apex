String targetPos = '10461454';
try {
    // 1. Buscamos el perfil unificado para ver qué UnifiedId tiene
    List<UnifiedssotIndividualDev2__dlm> profs = [SELECT ssot__Id__c, Email__c FROM UnifiedssotIndividualDev2__dlm WHERE Id_POS__c = :targetPos LIMIT 1];
    
    if(profs.isEmpty()) {
        System.debug('ERROR: No se encontró Perfil Unificado para ID POS ' + targetPos);
    } else {
        String uid = profs[0].ssot__Id__c;
        String email = profs[0].Email__c;
        System.debug('PERFIL ENCONTRADO: UnifiedId=' + uid + ' | Email=' + email);

        // 2. Probamos la consulta de Marketing directamente
        String eq = 'SELECT count() FROM ssot__EmailEngagement__dlm WHERE ssot__IndividualId__c = :uid OR ssot__IndividualId__c = :targetPos OR ssot__IndividualId__c = :email';
        Integer count = Database.countQuery(eq);
        System.debug('CONTEO DE EMAILS: ' + count);

        // 3. Probamos la nueva clase directamente para ver qué devuelve
        Map<String, Object> result = TechMarketingHelper.getMarketingAndQuotes(uid);
        System.debug('RESULTADO CLASE HELPER: ' + JSON.serialize(result));
    }
} catch(Exception e) {
    System.debug('ERROR DIAGNÓSTICO: ' + e.getMessage());
}
