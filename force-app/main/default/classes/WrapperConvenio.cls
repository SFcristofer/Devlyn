public with sharing class WrapperConvenio {
    public Convenio convenio;
	public String token;

	public class Convenio {
		public String customId;
		public Integer NumeroConvenio;
		public String NombreConvenio;
		public Integer NumeroCuentaContable;
		public String VigenciaInicial;
		public String VigenciaFinal;
		public String MontoMinimo;
		public String MontoMaximo;
		public String MontoCreditoAsignado;
		public String TipoMovimiento;
		public String TipoConvenio;
	}

    public class Response{
        
        public String customId;
        public String ESTATUS;
        public String MENSAJE;
        public String TRABAJO;
        public String IDREFERENCIA;
        
    }
	public static Response parseResponse(String json) {
        json = json.replaceAll('\\$id', 'customId');
		return (Response) System.JSON.deserialize(json, Response.class);
	}

    public static Opportunity getConvenio(String recordId){
        return [SELECT Id,
            Name,
            Numero_de_convenio__c,
            Account.ExternalId__c,
            Monto_del_cr_dito__c,
            Fecha_de_inicio_de_vigencia__c,
            Fecha_de_fin_de_vigencia__c,
            Monto_Minimo__c,
            Monto_Maximo__c,
            TipoMovimiento__c,
            Numero_de_Cuenta_Contable__c,
            RecordType.DeveloperName
        FROM Opportunity WHERE Id =: recordId LIMIT 1];
    }

    public static String getBody(String recordId, String token){
        WrapperConvenio wrapper = new WrapperConvenio();
        wrapper.token = token;
        Opportunity opportunity = getConvenio(recordId);
        wrapper.convenio = new Convenio();
        wrapper.convenio.customId = String.valueOf(opportunity.Numero_de_convenio__c);
        wrapper.convenio.NumeroConvenio = Integer.valueOf(opportunity.Numero_de_convenio__c);
        wrapper.convenio.NombreConvenio = opportunity.Name;
        wrapper.convenio.NumeroCuentaContable = Integer.valueOf(opportunity.Numero_de_Cuenta_Contable__c);
        wrapper.convenio.VigenciaInicial = opportunity.Fecha_de_inicio_de_vigencia__c != null ?ETC_UtilityCallout.getDateTime(opportunity.Fecha_de_inicio_de_vigencia__c).format('yyyy-MM-dd'):null;
        wrapper.convenio.VigenciaFinal = opportunity.Fecha_de_fin_de_vigencia__c != null ?ETC_UtilityCallout.getDateTime(opportunity.Fecha_de_fin_de_vigencia__c).format('yyyy-MM-dd'):null;
        wrapper.convenio.MontoMinimo = String.valueOf(opportunity.Monto_Minimo__c);
        wrapper.convenio.MontoMaximo = String.valueOf(opportunity.Monto_Maximo__c);
        wrapper.convenio.MontoCreditoAsignado = String.valueOf(opportunity.Monto_del_cr_dito__c);
        wrapper.convenio.TipoMovimiento = opportunity.TipoMovimiento__c;
        wrapper.convenio.TipoConvenio = opportunity.RecordType.DeveloperName.toUpperCase();
        String json = JSON.serialize(wrapper).replaceAll('customId','\\$id');
        return json;
    }
}