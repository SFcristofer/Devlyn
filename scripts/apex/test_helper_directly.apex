String horacioUnifiedId = 'a0fb46bfd6d09a4baf2711edda812dd7'; // UID Real de Horacio
try {
    Map<String, Object> result = TechMarketingHelper.getMarketingAndQuotes(horacioUnifiedId);
    System.debug('RESULTADO_HELPER_HORACIO: ' + JSON.serialize(result));
} catch(Exception e) {
    System.debug('ERROR_INVOCACION: ' + e.getMessage());
}
