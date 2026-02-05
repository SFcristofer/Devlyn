
List<String> objectsToInspect = new List<String>{
    'UnifiedssotIndividualDev2__dlm',
    'UnifiedLinkssotIndividualDev2__dlm',
    'ssot__SalesOrder__dlm',
    'ssot__SalesOrderProduct__dlm'
};

for (String objName : objectsToInspect) {
    System.debug('--- Inspecting Object: ' + objName + ' ---');
    try {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        for (String fieldName : fields.keySet()) {
            System.debug('Field: ' + fieldName);
        }
    } catch (Exception e) {
        System.debug('Error inspecting ' + objName + ': ' + e.getMessage());
    }
}
