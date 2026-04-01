String objectName = 'ssot__SalesOrder__dlm';
Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
for(String f : fields.keySet()) {
    System.debug('FIELD_FOUND: ' + f);
}
