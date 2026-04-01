// Describe UnifiedssotIndividualDev2__dlm to find email and phone fields
try {
    Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('UnifiedssotIndividualDev2__dlm').getDescribe().fields.getMap();
    for (String fieldName : fields.keySet()) {
        if (fieldName.contains('email') || fieldName.contains('phone') || fieldName.contains('id')) {
            System.debug('FIELD_CONTACT: ' + fieldName);
        }
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}
