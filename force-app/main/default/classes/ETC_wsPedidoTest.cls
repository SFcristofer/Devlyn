@IsTest
public with sharing class ETC_wsPedidoTest {
    @isTest
    private static void ETC_RestPedidoTest() {
        // Test data setup
        Opportunity opp = ETC_UtilityDataFactory.addOpportunity('name');
        // Actual test
        Test.startTest();
        
        ETC_RestPedido.addRecord(WrapperPedido.parse('{"wrapperOrder":{"FECHA_MOVIMIENTO":"2022-12-05T00:00:00.000Z","MONTO":3000,"ID_CENTRO":"IDC","ID_CLIENTE":74,"NOMBRE":"TestNOMBRE","PATERNO":"TestPATERNO","MATERNO":"TestMATERNO","EMAIL":"test@gmail.com","TELEFONO":"9512327805","ID_ASOCIADO":1,"OPERACION":"Compra","PEDIDO":"1","ORDEN_VENTA":"1","ID_CONVENIO":1,"MetodoPago":[{"ID_TIPO_PAGO":0,"MONTO":1000},{"ID_TIPO_PAGO":1,"MONTO":2000}]}}').wrapperOrder);
        ETC_RestPedido.getResponseError('1','1');
        ETC_RestPedido.getResponseSuccess('1','1');
        Test.stopTest();
    
        // Asserts
    }
}