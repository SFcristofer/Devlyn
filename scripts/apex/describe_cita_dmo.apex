// Script to describe TUOTEMPO_CITA__dlm
try {
    Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('TUOTEMPO_CITA__dlm').getDescribe().fields.getMap();
    for (String fieldName : fields.keySet()) {
        System.debug('FIELD: ' + fieldName);
    }
} catch (Exception e) {
    System.debug('Error describiendo objeto: ' + e.getMessage());
}
