public with sharing class DataCloudSQLControler {

    @AuraEnabled
    public static List<Object> getAntMedico(id recordId){
        //Antecedente Medico
        ConnectApi.CdpQueryInput inputAM = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputAM;
        String sqlStatementAM;
        sqlStatementAM = 'SELECT A.DataSource__c, FECHA__c, A.ARDOR_IRRITACION__c, A.COMEZON__c, A.DESTELLOS_DE_LUZ__c, A.DIABETES__c, A.DOLOR_CABEZA__c, A.EMBARAZO__c, A.INFECCION__c, A.HIPERTENSION__c,  A.LAGRIMEO__c, A.LEGANA__c, A.VISION_BORROSA__c, A.RESEQUEDAD_OCULAR__c, A.NOTAS__c FROM POS_POS_CLIENTE_ANTECEDENTES_ME_7087__dlm A, UnifiedssotIndividualDev2__dlm B, UnifiedLinkssotIndividualDev2__dlm C WHERE A.ID_CLIENTE__c = B.Id_POS__c AND C.UnifiedRecordId__c = B.ssot__Id__c AND B.Id_POS__c <> \'\' AND C.SourceRecordId__c = \'' + recordId + '\'';
        inputAM.sql = sqlStatementAM;
        if(!Test.isRunningTest())
        {
            outputAM = ConnectApi.CdpQuery.queryANSISql(inputAM);
        }
        return outputAM?.data;
    }

    @AuraEnabled
    public static List<Object> getPregPoder(id recordId){
        //Preguntas Poder
        ConnectApi.CdpQueryInput inputPP = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputPP;
        String sqlStatementPP;
        sqlStatementPP = 'SELECT A.DataSource__c, A.FECHA_ALTA__c, A.ACTIVIDAD_AIRE_LIBRE__c, A.ATRIBUTOS_DESEMPENO__c, A.ATRIBUTOS_ESTETICA__c, A.ATRIBUTOS_NINGUNA__c, A.ATRIBUTOS_NOTAS__c, A.ATRIBUTOS_PROTECCION__c, A.CIRCUNSTANCIA_CERCANA__c, A.CIRCUNSTANCIA_INTERMEDIA__c, A.CIRCUNSTANCIA_LEJANA__c, A.CIRCUNSTANCIA_NOTAS__c, A.COLOR_VESTUARIO__c, A.ESTORBAN_LENTES__c,  A.IMPORTANCIA_ESTILO_LENTES__c, A.LENTES_EMERGENCIA__c, A.MOLESTIAS_PROVENIENTES_SOL__c, A.MOLESTIAS_REFLEJO_MANEJAR__c, A.NECESIDAD_CORRECION__c, A.NECESIDAD_NINGUNA__c, A.NECESIDAD_NOTAS__c, A.NECESIDAD_OPTIMIZACION__c, A.NECESIDAD_PROTECCION__c, A.PROTEGE_SUS_OJOS__c, A.TIEMPO_CLARAMENTE_LENTES__c, A.TRANSPARENCIA_LENTES__c FROM POS_POS_CLIENTE_PREG_PODER__dlm A, UnifiedssotIndividualDev2__dlm B,  UnifiedLinkssotIndividualDev2__dlm C WHERE A.ID_CLIENTE__c = B.Id_POS__c AND C.UnifiedRecordId__c = B.ssot__Id__c AND B.Id_POS__c <> \'\' AND C.SourceRecordId__c = \'' + recordId + '\'';
        inputPP.sql = sqlStatementPP;
        if(!Test.isRunningTest())
        {            
            outputPP = ConnectApi.CdpQuery.queryANSISql(inputPP);
        }
        return outputPP?.data;
    }

    @AuraEnabled
    public static List<Object> getDriVisual(id recordId){
        //Driver Visual
        ConnectApi.CdpQueryInput inputDV = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputDV;
        String sqlStatementDV;
        sqlStatementDV = 'SELECT A.DataSource__c, A.FECHA__c, A.ID_CLIENTE__c, A.ID_RAZON_VISITA__c, A.ID_TIEMPO_EXAMEN__c, A.NIVEL_VISION__c, A.SOLUCION_VISUAL_BUSCA__c, A.TIPO_USUARIO__c, A.UTILIZA_SOLUCION_VISUAL__c, A.VALOR_RAZON_VISITA__c, A.VALOR_TIEMPO_EXAMEN__c FROM POS_POS_CLIENTE_DRIVER_VISUAL_708C22__dlm A,  UnifiedssotIndividualDev2__dlm B, UnifiedLinkssotIndividualDev2__dlm C WHERE A.ID_CLIENTE__c = B.Id_POS__c AND C.UnifiedRecordId__c = B.ssot__Id__c AND B.Id_POS__c <> \'\' AND C.SourceRecordId__c = \'' + recordId + '\'';
        inputDV.sql = sqlStatementDV;
        if(!Test.isRunningTest())
        {            
            outputDV = ConnectApi.CdpQuery.queryANSISql(inputDV);
        }
        return outputDV?.data;
    }

    @AuraEnabled
    public static List<Object> getGraduacion(String recordId){
        //Graduacion
        ConnectApi.CdpQueryInput inputGr = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputGr;
        String sqlStatementGr; 
        sqlStatementGr = 'SELECT B.FECHA_ENTREGA__c as "fecha", A.ID_PEDIDO__c as "ID_Ped", A.ID_GRAD_PEDIDO__c as "ID_GradPed", A.VALOR_1__c as "Valor1", A.VALOR_2__c as "Valor2", A.VALOR_3__c as "Valor3", A.VALOR_4__c as "Valor4", A.VALOR_5__c as "Valor5", A.VALOR_6__c as "Valor6", A.VALOR_7__c as "Valor7", A.VALOR_8__c as "Valor8" FROM POS_POS_GRADUACION_PEDIDO__dlm A, ssot__SalesOrder__dlm B, UnifiedssotIndividualDev2__dlm C, UnifiedLinkssotIndividualDev2__dlm D WHERE A.ID_PEDIDO__c = B.ssot__Id__c AND B.ssot__SoldToCustomerId__c = C.Id_POS__c AND D.UnifiedRecordId__c = C.ssot__Id__c AND C.Id_POS__c <> \'\' AND D.SourceRecordId__c = \'' + recordId + '\' order by B.FECHA_ENTREGA__c DESC';
        inputGr.sql = sqlStatementGr;
        if(!Test.isRunningTest())
            {
                outputGr = ConnectApi.CdpQuery.queryANSISql(inputGr);
            }
        return outputGr?.data;
    }

    @AuraEnabled
    public static List<Object> getDiagnostico(id recordId){
        //Diagnostico
        ConnectApi.CdpQueryInput inputDiag = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputDiag;
        String sqlStatementDiag; 
        sqlStatementDiag = 'SELECT A.DataSource__c, A.FECHA__c, A.ASTIGMATISMO__c, A.EXPERIENCIA_LC__c, A.HIPERMETROPIA__c, A.MIOPIA__c, A.NO_PRESENTA_ERROR__c, A.PRESBICIA__c FROM POS_POS_CLIENTE_DIAGNOSTICO_70881450__dlm A, UnifiedssotIndividualDev2__dlm B, UnifiedLinkssotIndividualDev2__dlm C WHERE A.ID_CLIENTE__c = B.Id_POS__c AND C.UnifiedRecordId__c = B.ssot__Id__c AND B.Id_POS__c <> \'\' AND C.SourceRecordId__c = \'' + recordId + '\'';
        inputDiag.sql = sqlStatementDiag;
        if(!Test.isRunningTest())
        {
            outputDiag = ConnectApi.CdpQuery.queryANSISql(inputDiag);
        }
        return outputDiag?.data;
    } 

    @AuraEnabled
    public static List<Object> getCitas(id recordId){
        //Citas
        ConnectApi.CdpQueryInput inputCita = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputCita;
        String sqlStatementCita;
        sqlStatementCita = 'SELECT A.start_date__c, A.end_date__c, A.activity_lid__c, A.activityTitle__c, A.areaTitle__c, A.resources_notes__c, A.estatus_cita__c FROM TUOTEMPO_CITA__dlm A, UnifiedssotIndividualDev2__dlm B, UnifiedLinkssotIndividualDev2__dlm C WHERE A.memberid__c = B.Id_TuoTempo__c AND C.UnifiedRecordId__c = B.ssot__Id__c AND B.Id_TuoTempo__c <> \'\' AND C.SourceRecordId__c = \'' + recordId + '\'';
        inputCita.sql = sqlStatementCita;
        if(!Test.isRunningTest())
        {            
            outputCita = ConnectApi.CdpQuery.queryANSISql(inputCita);
        }
        return outputCita?.data;
    }
	
    @AuraEnabled
    public static List<Object> getOrderData(id recordId){
            //Ordenes
            ConnectApi.CdpQueryInput input = new ConnectApi.CdpQueryInput();
            ConnectApi.CdpQueryOutput output;
            String sqlStatement;
            sqlStatement = 'SELECT DISTINCT(A.ssot__Id__c) as "Orden", C.ssot__Id__c as "Pedido", A.ssot__GrandTotalAmount__c as "Total", A.IVA__c as "IVA", C.ENTREGADO__c as "Entregado", C.FECHA_ENTREGA__c as "FEntrega", C.ssot__PromiseDate__c as "PrEntrega", C.FUENTE__c as "Fuente", C.HOME_DELIVERY__c as "EntDom", C.ID_PEDIDO_VTEX__c as "ID_VTEX", D.ssot__Name__c as "sucursal" FROM ssot__SalesOrder__dlm A, UnifiedssotIndividualDev2__dlm B, ssot__SalesOrder__dlm C, ssot__SalesStore__dlm D, UnifiedLinkssotIndividualDev2__dlm E WHERE A.ssot__SoldToCustomerId__c = B.Id_POS__c AND A.ssot__Id__c = C.ssot__OriginalOrderId__c AND RTRIM(C.ssot__SalesStoreId__c) = D.ssot__Id__c AND E.UnifiedRecordId__c = B.ssot__Id__c AND (B.Id_POS__c <> \'\' OR  B.Id_VTEX__c <> \'\') AND E.SourceRecordId__c = \'' + recordId + '\'';
        	input.sql = sqlStatement;
            
            if(!Test.isRunningTest())
            {               
                output = ConnectApi.CdpQuery.queryANSISql(input);
            }
            return output?.data;
    }

    @AuraEnabled
    public static List<Object> getProductData(String orderId){
        //Productos de la orden
        ConnectApi.CdpQueryInput inputP = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputP;
        String sqlStatementP; 
        sqlStatementP = 'SELECT ssot__ProductId__c, ssot__Description__c, ssot__OrderedQuantity__c, ssot__TotalLineAmount__c FROM ssot__SalesOrderProduct__dlm Where ssot__SalesOrderId__c  = \'' + orderId + '\'';
        inputP.sql = sqlStatementP;
        if(!Test.isRunningTest())
            {
                outputP = ConnectApi.CdpQuery.queryANSISql(inputP);
            }
        return outputP?.data;
    }
    
    @AuraEnabled
    public static List<Object> getProductPayment(String orderId){
        //Pagos de la orden
        ConnectApi.CdpQueryInput inputPago = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputPago;
        String sqlStatementPago; 
        sqlStatementPago = 'SELECT distinct(A.ID_CUENTA_POR_COBRAR__c) as "ID_CTA", A.FECHA__c as "Fecha", A.DOCUMENTO_1__c as "Doc1", A.DOCUMENTO_2__c as "Doc2", A.DOCUMENTO_3__c as "Doc3", A.DOCUMENTO_4__c as "Doc4", A.DOCUMENTO_5__c as "Doc5", A.ID_PAGO__c as "ID_Pago", A.ID_TIPO_PAGO__c as "ID_Tipo_Pago", A.ssot__PaymentAmount__c as "Pago", A.ssot__PaymentMethodId__c as "Metodo" FROM ssot__SalesOrderPaymentSummary__dlm A, ssot__SalesOrder__dlm B WHERE A.ID_CUENTA_POR_COBRAR__c IS NOT NULL AND B.ssot__OriginalOrderId__c = A.ssot__SalesOrderId__c AND B.ssot__Id__c = \'' + orderId + '\'';
        inputPago.sql = sqlStatementPago;
        if(!Test.isRunningTest())
            {
                outputPago = ConnectApi.CdpQuery.queryANSISql(inputPago);
            }
        return outputPago?.data;
    }
    
     @AuraEnabled
    public static List<Object> getProductDev(String recordId){
        //Devoluciones
        ConnectApi.CdpQueryInput inputDev = new ConnectApi.CdpQueryInput();
        ConnectApi.CdpQueryOutput outputDev;
        String sqlStatementDev;
        String strType = 'Devolución';
        sqlStatementDev = 'SELECT DISTINCT (A.PRODUCTO__c) as "ProdId", A.FECHA_DEVOLUCION__c as "Fecha", A.ID_PEDIDO__c as "ID_Ped", A.ORDEN_VENTA__c as "Orden", A.VALOR_ID_CAUSA__c as "Causa", C.ssot__Description__c as "Descripcion", A.MONTO__c as "Monto", A.CANTIDAD__c "Cantidad" FROM POS_POS_DEVOL_DET_PEDIDO_6C793920__dlm A, ssot__SalesOrderProduct__dlm B, ssot__MasterProduct__dlm C, UnifiedssotIndividualDev2__dlm D, UnifiedLinkssotIndividualDev2__dlm E, ssot__SalesOrder__dlm F WHERE B.ssot__SalesOrderId__c = A.ID_PEDIDO__c AND E.UnifiedRecordId__c = D.ssot__Id__c AND B.Estado_Producto__c = \'' + strType + '\' AND c.ssot__Id__c = A.PRODUCTO__c AND F.ssot__SoldToCustomerId__c = D.Id_POS__c AND F.ssot__Id__c = B.ssot__SalesOrderId__c AND E.SourceRecordId__c = \'' + recordId + '\'';
        inputDev.sql = sqlStatementDev;
        if(!Test.isRunningTest())
            {
                outputDev = ConnectApi.CdpQuery.queryANSISql(inputDev);
            }
        return outputDev?.data;
    }
    
}